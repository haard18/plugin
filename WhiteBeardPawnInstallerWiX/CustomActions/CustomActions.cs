using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Deployment.WindowsInstaller;
using System.Security.Cryptography;
using System.Xml.Linq;
using Microsoft.Win32;

namespace WhiteBeardPawnInstallerCA
{
    public class CustomActions
    {
        private const string LICENSE_SEARCH_DIR = @"C:\ProgramData\WhiteBeard";
        private const string LICENSE_FILENAME_PATTERN = "_pawn_plugin.lic";
        private const string VERIFY_API_URL = "https://yourserver.com/verify";
        private const string MT5_DEFAULT_PATH = @"C:\MetaTrader 5 Platform\TradeMain";
        private const string MT5_REGISTRY_KEY = @"HKEY_LOCAL_MACHINE\SOFTWARE\MetaQuotes\MetaTrader 5";

        /// <summary>
        /// Custom action: Search for license file in ProgramData\WhiteBeard
        /// If found, populate LICENSE_PATH property and verify it.
        /// If not found, prompt user to browse for license file.
        /// </summary>
        [CustomAction]
        public static ActionResult SearchAndValidateLicense(Session session)
        {
            try
            {
                session.Log("Starting SearchAndValidateLicense custom action");

                // Step 1: Search for license file
                string licenseFilePath = FindLicenseFile(session, LICENSE_SEARCH_DIR);

                if (string.IsNullOrEmpty(licenseFilePath))
                {
                    session.Log("License file not found in ProgramData. Prompting user to browse.");
                    licenseFilePath = PromptUserForLicenseFile(session);
                }

                if (string.IsNullOrEmpty(licenseFilePath))
                {
                    session.Log("ERROR: User did not provide a license file.");
                    return ActionResult.Failure;
                }

                session.Log($"License file found/selected: {licenseFilePath}");
                session["LICENSE_PATH"] = licenseFilePath;

                // Step 2: Extract company info from license file
                var (companyName, companyEmail) = DecryptLicenseInfo(session, licenseFilePath);

                if (string.IsNullOrEmpty(companyName) || string.IsNullOrEmpty(companyEmail))
                {
                    session.Log("ERROR: Could not extract company information from license file.");
                    return ActionResult.Failure;
                }

                session["COMPANY_NAME"] = companyName;
                session["COMPANY_EMAIL"] = companyEmail;

                session.Log($"Company: {companyName}, Email: {companyEmail}");

                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in SearchAndValidateLicense: {ex.Message}");
                MessageBox.Show($"Error validating license: {ex.Message}", "Installation Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return ActionResult.Failure;
            }
        }

        /// <summary>
        /// Custom action: Verify license with remote API
        /// Sends company name, email, and license file to verification endpoint.
        /// </summary>
        [CustomAction]
        public static ActionResult VerifyLicenseWithAPI(Session session)
        {
            try
            {
                session.Log("Starting VerifyLicenseWithAPI custom action");

                string licenseFilePath = session["LICENSE_PATH"];
                string companyName = session["COMPANY_NAME"];
                string companyEmail = session["COMPANY_EMAIL"];

                if (string.IsNullOrEmpty(licenseFilePath) || !File.Exists(licenseFilePath))
                {
                    session.Log("ERROR: License file path is invalid or missing.");
                    return ActionResult.Failure;
                }

                session.Log($"Verifying license: {licenseFilePath}");

                bool isVerified = VerifyLicenseAsync(session, licenseFilePath, companyName, companyEmail).Result;

                if (!isVerified)
                {
                    session.Log("ERROR: License verification failed.");
                    MessageBox.Show(
                        "License verification failed. Please contact WhiteBeard support.\n\n" +
                        "Website: www.whitebeard.ai\n" +
                        "Email: info@whitebeard.ai\n" +
                        "Phone: +1 646 422 8482",
                        "License Verification Failed",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return ActionResult.Failure;
                }

                session.Log("License verification succeeded.");
                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in VerifyLicenseWithAPI: {ex.Message}");
                MessageBox.Show($"Error during license verification: {ex.Message}", "Installation Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return ActionResult.Failure;
            }
        }

        /// <summary>
        /// Custom action: Detect MetaTrader 5 installation directory
        /// First checks registry, then default path, then prompts user.
        /// </summary>
        [CustomAction]
        public static ActionResult DetectMT5Directory(Session session)
        {
            try
            {
                session.Log("Starting DetectMT5Directory custom action");

                // Step 1: Try registry
                string mt5Path = GetMT5PathFromRegistry(session);

                if (string.IsNullOrEmpty(mt5Path) || !Directory.Exists(mt5Path))
                {
                    session.Log("MT5 not found in registry. Checking default path.");
                    mt5Path = MT5_DEFAULT_PATH;

                    if (!Directory.Exists(mt5Path))
                    {
                        session.Log("MT5 not found at default path. Prompting user to browse.");
                        mt5Path = PromptUserForMT5Directory(session);
                    }
                }

                if (string.IsNullOrEmpty(mt5Path) || !Directory.Exists(mt5Path))
                {
                    session.Log("ERROR: Could not detect MT5 directory and user did not provide one.");
                    MessageBox.Show(
                        "MetaTrader 5 not found on this system. Please install MetaTrader 5 before continuing.",
                        "MT5 Not Found",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return ActionResult.Failure;
                }

                session.Log($"MT5 directory detected: {mt5Path}");
                session["MT5_ROOT"] = mt5Path;

                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in DetectMT5Directory: {ex.Message}");
                MessageBox.Show($"Error detecting MT5 directory: {ex.Message}", "Installation Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return ActionResult.Failure;
            }
        }

        /// <summary>
        /// Custom action: Install the plugin files to MT5 directory
        /// Copies PawnPlugin64.dll to MT5\Plugins and license to ProgramData.
        /// </summary>
        [CustomAction]
        public static ActionResult InstallPluginFiles(Session session)
        {
            try
            {
                session.Log("=== Starting InstallPluginFiles custom action ===");

                // Check admin privileges for ProgramData
                if (!HasAdminRights(session))
                {
                    session.Log("ERROR: User does not have admin rights.");
                    MessageBox.Show(
                        "This installer requires administrator privileges to write to C:\\ProgramData.",
                        "Admin Rights Required",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return ActionResult.Failure;
                }

                string mt5Root = session["MT5_ROOT"];
                string licenseFilePath = session["LICENSE_PATH"];
                string installDir = session["INSTALLDIR"];
                string companyName = session["COMPANY_NAME"];
                string companyEmail = session["COMPANY_EMAIL"];

                session.Log($"Installation Details:");
                session.Log($"  MT5 Root: {mt5Root}");
                session.Log($"  Install Dir: {installDir}");
                session.Log($"  License Path: {licenseFilePath}");
                session.Log($"  Company: {companyName}");

                // Step 1: Create MT5 Plugins directory if it doesn't exist
                string pluginsDir = Path.Combine(mt5Root, "Plugins");
                if (!Directory.Exists(pluginsDir))
                {
                    try
                    {
                        Directory.CreateDirectory(pluginsDir);
                        session.Log($"[CREATED] MT5 Plugins directory: {pluginsDir}");
                    }
                    catch (Exception ex)
                    {
                        session.Log($"ERROR: Failed to create plugins directory: {ex.Message}");
                        return ActionResult.Failure;
                    }
                }
                else
                {
                    session.Log($"[EXISTS] MT5 Plugins directory: {pluginsDir}");
                }

                // Step 2: Create WhiteBeard data directory
                string whiteBeardDataDir = LICENSE_SEARCH_DIR;
                if (!Directory.Exists(whiteBeardDataDir))
                {
                    try
                    {
                        Directory.CreateDirectory(whiteBeardDataDir);
                        session.Log($"[CREATED] WhiteBeard data directory: {whiteBeardDataDir}");
                    }
                    catch (Exception ex)
                    {
                        session.Log($"ERROR: Failed to create WhiteBeard data directory: {ex.Message}");
                        return ActionResult.Failure;
                    }
                }
                else
                {
                    session.Log($"[EXISTS] WhiteBeard data directory: {whiteBeardDataDir}");
                }

                // Step 3: Copy PawnPlugin64.dll to MT5 Plugins directory
                string sourcePluginDll = Path.Combine(installDir, "PawnPlugin64.dll");
                string destPluginDll = Path.Combine(pluginsDir, "PawnPlugin64.dll");

                session.Log("=== Plugin DLL Installation ===");
                if (File.Exists(sourcePluginDll))
                {
                    try
                    {
                        // Backup existing file if it exists
                        if (File.Exists(destPluginDll))
                        {
                            string backupPath = destPluginDll + ".backup";
                            File.Copy(destPluginDll, backupPath, overwrite: true);
                            session.Log($"[BACKUP] Created backup: {backupPath}");
                        }

                        // Copy the new DLL
                        File.Copy(sourcePluginDll, destPluginDll, overwrite: true);
                        session.Log($"[SUCCESS] Copied plugin DLL:");
                        session.Log($"  FROM: {sourcePluginDll}");
                        session.Log($"  TO:   {destPluginDll}");

                        // Verify the copy was successful
                        if (File.Exists(destPluginDll))
                        {
                            FileInfo fileInfo = new FileInfo(destPluginDll);
                            session.Log($"[VERIFIED] Plugin file size: {fileInfo.Length} bytes");
                            session.Log($"[VERIFIED] Plugin file date: {fileInfo.LastWriteTime}");
                        }
                        else
                        {
                            session.Log("ERROR: Plugin DLL copy verification failed!");
                            return ActionResult.Failure;
                        }
                    }
                    catch (Exception ex)
                    {
                        session.Log($"ERROR: Failed to copy plugin DLL: {ex.Message}");
                        session.Log($"  Stack Trace: {ex.StackTrace}");
                        MessageBox.Show(
                            $"Failed to copy plugin DLL to MT5:\n\n{ex.Message}",
                            "Plugin Installation Error",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Error);
                        return ActionResult.Failure;
                    }
                }
                else
                {
                    session.Log($"WARNING: Source DLL not found at: {sourcePluginDll}");
                    session.Log("Plugin DLL will not be copied. Installation continues for license only.");
                }

                // Step 4: Copy license file to ProgramData
                session.Log("=== License File Installation ===");
                if (!string.IsNullOrEmpty(licenseFilePath) && File.Exists(licenseFilePath))
                {
                    try
                    {
                        string destLicensePath = Path.Combine(whiteBeardDataDir, Path.GetFileName(licenseFilePath));

                        // Backup existing license if present
                        if (File.Exists(destLicensePath))
                        {
                            string backupPath = destLicensePath + ".backup";
                            File.Copy(destLicensePath, backupPath, overwrite: true);
                            session.Log($"[BACKUP] Created license backup: {backupPath}");
                        }

                        // Copy the license file
                        File.Copy(licenseFilePath, destLicensePath, overwrite: true);
                        session.Log($"[SUCCESS] Copied license file:");
                        session.Log($"  FROM: {licenseFilePath}");
                        session.Log($"  TO:   {destLicensePath}");

                        // Verify the copy
                        if (File.Exists(destLicensePath))
                        {
                            FileInfo fileInfo = new FileInfo(destLicensePath);
                            session.Log($"[VERIFIED] License file size: {fileInfo.Length} bytes");
                            session.Log($"[VERIFIED] License file date: {fileInfo.LastWriteTime}");
                        }
                    }
                    catch (Exception ex)
                    {
                        session.Log($"ERROR: Failed to copy license file: {ex.Message}");
                        session.Log($"  Stack Trace: {ex.StackTrace}");
                        MessageBox.Show(
                            $"Failed to copy license file:\n\n{ex.Message}",
                            "License Installation Error",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Error);
                        return ActionResult.Failure;
                    }
                }
                else
                {
                    session.Log($"WARNING: License file not found or path is empty: {licenseFilePath}");
                }

                // Step 5: Log final registry entries that will be created
                session.Log("=== Registry Entries ===");
                session.Log($"[REGISTRY] HKLM\\Software\\WhiteBeard\\PawnPlugin");
                session.Log($"  Installed = 1");
                session.Log($"  Version = 1.0.0");
                session.Log($"  InstallDir = {installDir}");
                session.Log($"  MT5Root = {mt5Root}");
                session.Log($"  MT5PluginPath = {destPluginDll}");
                session.Log($"  PluginVersion = 1.0.0");

                session.Log("=== InstallPluginFiles COMPLETED SUCCESSFULLY ===");
                return ActionResult.Success;
            }
            catch (Exception ex)
            {
                session.Log($"=== ERROR in InstallPluginFiles ===");
                session.Log($"Exception: {ex.Message}");
                session.Log($"Stack Trace: {ex.StackTrace}");
                MessageBox.Show(
                    $"Error installing plugin files: {ex.Message}",
                    "Installation Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return ActionResult.Failure;
            }
        }

        // ========== HELPER METHODS ==========

        /// <summary>
        /// Search for a license file in the specified directory.
        /// Returns the full path if found, otherwise null.
        /// </summary>
        private static string FindLicenseFile(Session session, string searchDir)
        {
            try
            {
                if (!Directory.Exists(searchDir))
                {
                    session.Log($"Search directory does not exist: {searchDir}");
                    return null;
                }

                var files = Directory.GetFiles(searchDir, $"*{LICENSE_FILENAME_PATTERN}");
                if (files.Length > 0)
                {
                    return files[0];
                }

                return null;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in FindLicenseFile: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// Prompt user with OpenFileDialog to select a license file.
        /// </summary>
        private static string PromptUserForLicenseFile(Session session)
        {
            try
            {
                using (OpenFileDialog ofd = new OpenFileDialog())
                {
                    ofd.Title = "Select WhiteBeard Pawn Plugin License File";
                    ofd.Filter = "License Files (*.lic)|*.lic|All Files (*.*)|*.*";
                    ofd.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);

                    if (ofd.ShowDialog() == DialogResult.OK)
                    {
                        return ofd.FileName;
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in PromptUserForLicenseFile: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// Extract company name and email from license file.
        /// Assumes the license file is XML or text-based.
        /// In a real scenario, this would decrypt the license.
        /// </summary>
        private static (string companyName, string companyEmail) DecryptLicenseInfo(Session session, string licenseFilePath)
        {
            try
            {
                session.Log($"Extracting license info from: {licenseFilePath}");

                if (!File.Exists(licenseFilePath))
                {
                    session.Log("ERROR: License file does not exist.");
                    return (null, null);
                }

                // For demonstration, assume license file is XML format
                // In production, this would involve actual decryption
                string licenseContent = File.ReadAllText(licenseFilePath);

                // Try parsing as XML
                try
                {
                    XDocument doc = XDocument.Parse(licenseContent);
                    string companyName = doc.Root?.Element("CompanyName")?.Value;
                    string companyEmail = doc.Root?.Element("CompanyEmail")?.Value;

                    if (!string.IsNullOrEmpty(companyName) && !string.IsNullOrEmpty(companyEmail))
                    {
                        session.Log($"Successfully extracted license info. Company: {companyName}");
                        return (companyName, companyEmail);
                    }
                }
                catch
                {
                    session.Log("License file is not XML format. Attempting alternative parsing.");
                }

                // Fallback: extract from text file (simple key=value format)
                var lines = licenseContent.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None);
                string company = null;
                string email = null;

                foreach (var line in lines)
                {
                    if (line.StartsWith("CompanyName=", StringComparison.OrdinalIgnoreCase))
                        company = line.Substring("CompanyName=".Length).Trim();
                    if (line.StartsWith("CompanyEmail=", StringComparison.OrdinalIgnoreCase))
                        email = line.Substring("CompanyEmail=".Length).Trim();
                }

                if (!string.IsNullOrEmpty(company) && !string.IsNullOrEmpty(email))
                {
                    return (company, email);
                }

                // If we can't parse, return generic values for testing
                session.Log("WARNING: Could not parse license file. Using placeholder values.");
                return ("Unknown Company", "unknown@example.com");
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in DecryptLicenseInfo: {ex.Message}");
                return (null, null);
            }
        }

        /// <summary>
        /// Verify license with remote API endpoint.
        /// Sends company name, email, and license file as multipart/form-data.
        /// </summary>
        private static async Task<bool> VerifyLicenseAsync(Session session, string licenseFilePath, string companyName, string companyEmail)
        {
            try
            {
                session.Log($"Sending license verification to {VERIFY_API_URL}");

                using (var httpClient = new HttpClient())
                {
                    httpClient.Timeout = TimeSpan.FromSeconds(30);

                    using (var form = new MultipartFormDataContent())
                    {
                        // Add form fields
                        form.Add(new StringContent(companyName), "companyName");
                        form.Add(new StringContent(companyEmail), "companyEmail");

                        // Add license file
                        var fileStream = File.OpenRead(licenseFilePath);
                        var fileContent = new StreamContent(fileStream);
                        fileContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue("application/octet-stream");
                        form.Add(fileContent, "licenseFile", Path.GetFileName(licenseFilePath));

                        // Send request
                        var response = await httpClient.PostAsync(VERIFY_API_URL, form);

                        session.Log($"API Response Status: {response.StatusCode}");

                        if (response.IsSuccessStatusCode)
                        {
                            session.Log("License verification successful (HTTP 200)");
                            return true;
                        }
                        else
                        {
                            string errorContent = await response.Content.ReadAsStringAsync();
                            session.Log($"License verification failed. Status: {response.StatusCode}, Response: {errorContent}");
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in VerifyLicenseAsync: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Get MT5 directory path from Windows registry.
        /// </summary>
        private static string GetMT5PathFromRegistry(Session session)
        {
            try
            {
                using (RegistryKey key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\MetaQuotes\MetaTrader 5"))
                {
                    if (key != null)
                    {
                        object installDir = key.GetValue("InstallDir");
                        if (installDir != null)
                        {
                            string path = installDir.ToString();
                            session.Log($"MT5 found in registry at: {path}");
                            return path;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                session.Log($"WARNING: Could not read MT5 from registry: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Prompt user with FolderBrowserDialog to select MT5 installation directory.
        /// </summary>
        private static string PromptUserForMT5Directory(Session session)
        {
            try
            {
                using (var fbd = new FolderBrowserDialog())
                {
                    fbd.Description = "Please select your MetaTrader 5 installation directory";
                    fbd.RootFolder = Environment.SpecialFolder.ProgramFiles;

                    if (fbd.ShowDialog() == DialogResult.OK)
                    {
                        return fbd.SelectedPath;
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR in PromptUserForMT5Directory: {ex.Message}");
                return null;
            }
        }

        /// <summary>
        /// Check if current user has admin rights.
        /// </summary>
        private static bool HasAdminRights(Session session)
        {
            try
            {
                var identity = System.Security.Principal.WindowsIdentity.GetCurrent();
                var principal = new System.Security.Principal.WindowsPrincipal(identity);
                bool hasAdmin = principal.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);

                session.Log($"Admin rights check: {(hasAdmin ? "YES" : "NO")}");
                return hasAdmin;
            }
            catch (Exception ex)
            {
                session.Log($"ERROR checking admin rights: {ex.Message}");
                return false;
            }
        }
    }
}
