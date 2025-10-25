### 🧠 **Final Copilot Workspace Prompt (WhiteBeard Pawn Plugin Installer)**

> **Goal:**
> Build a **WiX Toolset 4 Windows Installer** for the product **“WhiteBeard Pawn Plugin”** that validates a license file, verifies it with a remote API, and installs the plugin into the correct MetaTrader 5 (MT5) directory.
>
> ---
>
> **Functional Requirements:**
>
> 1. **Product Info**
>
>    * Product: **WhiteBeard Pawn Plugin**
>    * Company: `<Company Name>` — initially blank; populated by decrypting the license file.
>    * Email: `<Company Email>` — initially blank; populated by decrypting the license file.
>    * License Key Path: read-only input field showing the `.lic` file path.
> 2. **License Handling**
>
>    * Installer checks for a file ending with `_pawn_plugin.lic` inside `C:\ProgramData\WhiteBeard`.
>    * If found, load it into the License Key Path input and verify its authenticity.
>    * If not found, prompt the user to manually browse for `WhiteBeardPawnPlugin.lic`.
>    * Once loaded and verified, populate Company Name and Email fields from decrypted data.
>    * Only after successful verification, the **Next** button is enabled.
> 3. **Verification**
>
>    * Calls an HTTP POST to `https://yourserver.com/verify` sending:
>
>      * Company name
>      * Company email
>      * License file as multipart/form-data
>    * If verification succeeds (`HTTP 200`), proceed.
>    * If not, show an error and abort installation.
> 4. **Installer Notes**
>
>    * If the user does **not** have admin rights to write to `C:\ProgramData`, prompt for elevated privileges or display an error.
>    * Display license terms and require user agreement before continuing.
> 5. **MT5 Detection and Installation**
>
>    * Detect whether **MetaTrader 5** is installed.
>    * Default check path: `C:\MetaTrader 5 Platform\TradeMain`
>    * If not found, prompt the user to browse to the MT5 root folder manually.
>    * Once located, copy:
>
>      * `PawnPlugin64.dll` → `[MT5Root]\Plugins\`
>      * License file → `C:\ProgramData\WhiteBeard\`
>    * Log all file operations to the installer log.
> 6. **Company Info for Support**
>
>    * If license not found or invalid, show:
>
>      ```
>      To obtain a license, please contact WhiteBeard:
>      Website: www.whitebeard.ai
>      Email: info@whitebeard.ai
>      Phone: +1 646 422 8482
>      ```
> 7. **Front-End License Generation (Contextual Info)**
>
>    * Admins use app.whitebeard.ai → License panel:
>
>      * Input: Company Name
>      * Input: Company Email
>      * Button: Generate New License
>      * Result: pawn.lic auto-downloads and emails to customer.
>
> ---
>
> **Technical Requirements:**
>
> * Built using **WiX Toolset 4**.
> * Uses **C# DTF Custom Actions** (`CustomActions.cs`).
> * Targets **.NET Framework 4.8**.
> * Use `System.Windows.Forms.OpenFileDialog` for file selection.
> * Use `HttpClient` for API verification.
> * Use `MessageBox.Show()` for user prompts and errors.
> * Log every critical step with `session.Log()`.
> * Define installer properties:
>
>   * `LICENSE_PATH`
>   * `COMPANY_NAME`
>   * `COMPANY_EMAIL`
>   * `MT5_ROOT`
>
> ---
>
> **Deliverables:**
>
> 1. `Product.wxs` — defines features, directories, UI, custom actions, and file components.
> 2. `CustomActions.cs` — implements:
>
>    * License search + browse
>    * Decrypt license for company name/email
>    * Verify via API
>    * Detect MT5 directory
>    * Handle admin permission checks
> 3. `CustomDialog.wxs` — custom UI for license selection and company info display.
> 4. `CustomActions.csproj` — includes reference to `WixToolset.Dtf.WindowsInstaller`.
> 5. `README.md` — how to build and test on Windows (Visual Studio or WiX CLI).
>
> ---
>
> **Extra:**
>
> * Add registry- and filesystem-based autodetection for MT5 directory (typical keys: `HKEY_LOCAL_MACHINE\SOFTWARE\MetaQuotes\MetaTrader 5` or default path fallback).
> * Abort gracefully with clear user messages if any validation fails.
> * Ensure UI disables "Next" until license verification passes.
> * All dialogs styled consistently with standard WiX look.
>
> ---
>
> **Output:**
> A ready-to-build WiX + C# project containing all installer source files, working end-to-end logic, and clear comments for future modification.


