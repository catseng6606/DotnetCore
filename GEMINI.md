# 專案資訊（通用版）

- 本專案採用 ASP.NET Core MVC 架構（版本依專案實際設定）。
- 所有頁面預設不驗證登入；僅針對需要保護的頁面或功能明確加上授權限制。
- 檔案編碼請使用 UTF-8 BOM（若團隊另有規範，依團隊規範為準）。
- 請維持 `.editorconfig` 設定一致，確保專案編碼與格式統一。
- 請使用台灣正體中文（zh-TW）進行回應與記錄。
- 除非有特殊需求，否則請避免使用最上層語句（Top-level statements）。
- **依賴注入 (DI)**：請善用內建 DI 容器，依據服務無狀態/有狀態特性，正確配置 `AddTransient`、`AddScoped` 或 `AddSingleton`。
- **組態管理 (Configuration)**：建議使用 [Options Pattern](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/configuration/options) (`IOptions<T>`, `IOptionsSnapshot<T>`) 進行強型別組態綁定，避免直接散落存取 `IConfiguration`。

# 前端與 UI 規範

- 全站可使用 Bootstrap、jQuery、DataTables 等常見前端元件。
- 強調語意化 HTML (Semantic HTML) 與無障礙網頁設計 (Accessibility, a11y) 基礎規範。
- 前端資源管理優先使用 LibMan，並將資源放置於 `/wwwroot/lib`。
- 下拉選單 `<select>` 預設可使用 `select2` 並提供過濾功能。
- 介面設計請以一致性、可用性、可維護性及響應式 (Responsive Design) 為優先。
- **非同步載入**：若頁面或區塊資料載入需要花費比較久的時間，請一律使用 API 搭配 Axios 處理，提升畫面流暢度與使用者體驗。

# 套件管理

- 前端套件管理請優先使用 LibMan，並記得 restore。
- 後端套件使用 NuGet，建議採用[集中套件管理 (Central Package Management)](https://learn.microsoft.com/en-us/nuget/consume-packages/central-package-management) 維護跨專案版本。
- 若無特殊需求，避免直接依賴外部 CDN，以利版本嚴格控管與離線或內網環境部署。

# 系統安全與防護原則

- 盡可能在專案中依循符合資安規則的開發方式，優先採用安全預設（Secure by Default）。
- **機密保護**：不得將密碼、金鑰、Connection String、Access Token、憑證或其他敏感資訊硬編碼於程式碼或前端頁面，應使用環境變數、Secret Manager 或 Key Vault。
- **資料防護**：所有資料庫查詢必須使用參數化 (如 Dapper) 避免 SQL Injection；所有輸入資料不論來源 (Query, Form, Header) 皆須視為不可信，並進行驗證與清洗 (Sanitization)。
- **Web 防護機制 (必備)**：
  - 啟用與設置合理的 **CORS (Cross-Origin Resource Sharing)**，嚴禁使用 `AllowAnyOrigin()` 放行所有來源。
  - 對敏感操作加上防偽造憑證 (Anti-Forgery Token, CSRF)。
  - 設定嚴格的 **CSP (Content Security Policy)** 標頭，防止 XSS 攻擊。
  - 視需要啟用 **Rate Limiting** 或 Throttling 防護，防範暴力破解及 DDoS。
- **紀錄與追蹤 (Logging)**：
  - 使用結構化日誌 (Structured Logging, 如 Serilog 或 NLog)。
  - 僅在必要時揭露錯誤訊息；正式環境**絕對避免**直接回傳堆疊資訊 (Stack Trace) 或內部例外細節。
  - 記錄日誌時，需實作**資料遮蔽 (Data Redaction)**，禁止寫入密碼、全碼身分證字號、信用卡號等高敏感個資。

# 資料處理與資料庫

- **ORM 選型**：本專案一律使用 **Dapper** 進行資料操作，**不使用 Entity Framework Core (EF Core)**。
- 使用 Dapper 時，請先於 `Program.cs` 透過 `AddScoped` 注入資料庫連線 (`IDbConnection`)。
- Dapper 執行 SQL 時，優先使用非同步（`async`）與預存程序（Stored Procedures）。
- 任何非同步 DB 操作，請盡可能支援傳遞 `CancellationToken` 以利提早終止超時請求。
- 請確保 SQL 呼叫具備安全性（參數化）與效能。若有瞬態連線錯誤重試的需求，建議手動搭配 Polly 等套件實作 Retry Policy。
- 若團隊有 DBA 權限控管需求，請在 SP 腳本中附上必要的授權註記。
- 除非另有指示，資料寫入流程優先採用 POST。
- **PRG 模式 (Post-Redirect-Get)**：儲存後建議留在可持續編輯的頁面，且避免表單重複提交：
  - 新增完成後：`RedirectToAction` 導向編輯頁（帶入新資料 id）。
  - 更新完成後：`RedirectToAction` 導回同一編輯頁（帶入既有 id）。
- 送出資料後，使用共用 Toast Partial 呈現結果回饋。

# Model 與 ViewModel 開發規範

## 設計原則：ViewModel as PageModel

採用「一個 View 對應一個 ViewModel」原則，參考 Razor Pages 的 `PageModel` 設計思維：ViewModel 除了資料載體，也可包含頁面資料載入邏輯。

- **檔案位置**：建議置於 `Models/ViewModels`。
- **命名規範**：`[Action]ViewModel.cs` 或 `[Controller][Action]ViewModel.cs`。
- **DTO 定義規範**：
  - **內部 DTO**：僅供單一 View 使用者，宣告為 ViewModel 內部類別（Nested Class）。
  - **外部 DTO**：跨多個 View 或功能重複使用者，獨立為檔案。
  - **不可變性 (Immutability)**：建議 DTO 使用 C# 的 `record` 型別（或 `init` 的屬性），以保證資料傳遞間不可被竄改。
- **裝載職責**：將資料載入邏輯隔離在靜態非同步方法 `public static async Task<XxxViewModel> GetAsync(...)`，減輕 Controller 負擔。

## InputModel 與 DTO 驗證

- InputModel 僅承接「輸入資料」，必須經過嚴格驗證。
- C# 11+ 建議對必填且無預設值的屬性標記 `required` 修飾詞。
- 運用內建 `DataAnnotations` 限定長度、格式、範圍與必填。
- Nullable Reference Types 啟用時，非必填字串應標示為 `string?`。
- 驗證失敗應回傳原頁面並攜帶 `ModelState` 錯誤，不應將例外直接拋出。

# 全域例外處理 (Global Exception Handling)

- 取代 Controller 內大量重複的 `try-catch`，應實作 Middleware 或使用 .NET 8 內建的 `IExceptionHandler` 進行全域例外捕捉。
- 若針對 API 回應，錯誤格式皆應符合 **RFC 7807 (Problem Details)** 規範，維持一致的錯誤結構。

# 登入機制與身分識別

- 若啟用身分驗證，建議使用 Cookie Authentication 或標準的 OAuth/OIDC。
- 使用者識別應封裝為擴充方法 (Extension Methods) 供全站統一使用。
- 建議設定 `SecurityStampValidator`，當使用者密碼或核心權限被更改時，系統能強制使既有 Session 立即失效。
- 登入導向的 `returnUrl` **必須**驗證為站內路徑 (`Url.IsLocalUrl`) 以阻擋 Open Redirect 漏洞。

# 分頁與共用渲染處理

- **前端分頁**：預設可使用 DataTables 處理列表分頁與搜尋。
- **後端分頁**：巨量資料情境，建議改採**游標分頁 (Cursor-based Pagination)**，或於 SP 實作 `OFFSET/FETCH` 並同步回傳 `TotalRecords`。
- **共用 UI 渲染**：
  - 中至高複雜度的共用商業邏輯（包含 DB 查詢），應封裝為 **View Component**。
  - 輕量級的 HTML 輸出與屬性封裝（例如客製化外觀的按鈕、狀態標籤），建議封裝為 **Tag Helper**，讓 Razor 語法更為簡潔。

# AI Agent 協作規範

- 每次對專案程式碼做出具體修改與優化，應將「執行成果」與「異動摘要」記錄於指定的進度追蹤檔案（如 `README.md`），並附上時間標記，採用「由新到舊」排序。
- 在回答問題或修改代碼前，若無法確定專案現有架構或慣例，請主動透過搜尋先查詢既有檔案與作法，避免覆寫或提供風格分歧的寫法。
- 不需特別執行建置 (`dotnet build`) 或運行指令 (`dotnet run`)，確保變更聚焦在程式與架構層面。
