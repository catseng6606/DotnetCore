# 專案說明

本專案為採用 ASP.NET Core MVC 架構開發之專案。專案的開發過程嚴格遵循一套內部定義的架構、資安以及程式碼風格規範，確保專案具備一致性、高安全性及易於維護的特性。

## 開發規範摘要 (`GEMINI.md` 摘要)

本專案的核心開發規範記錄於 [`GEMINI.md`](GEMINI.md) 檔案中，以下為重點摘要：

- **系統架構與基礎**：採用 ASP.NET Core MVC，依賴注入 (DI) 分配準確，組態管理採用 Options Pattern。
- **前端與 UI 設計**：重視前端資源管理 (LibMan) 及語意化 HTML。耗時的資料需採 API 搭配 Axios 非同步載入，提升使用者體驗。
- **安全性與防護**：全面落實「Secure by Default」。嚴禁硬編碼機密資訊；各層級需具備防護機制 (CORS、CSP、CSRF 等) 並對輸入資料進行充分驗證與清洗。日誌記錄須實作個資遮蔽。
- **資料庫存取**：唯一指定使用 **Dapper** 進行資料操作 (不使用 EF Core)，並優先採用非同步方法及預存程序 (Stored Procedures)。寫入後應遵循 PRG (Post-Redirect-Get) 模式。
- **Model 與 ViewModel**：遵循「ViewModel as PageModel」的設計模式，並將資料載入邏輯封裝於靜態非同步方法。InputModel 必須實作嚴格的資料驗證。
- **錯誤處理與身分驗證**：實作全域例外捕捉機制，API 錯誤遵循 RFC 7807 規範。登入機制建議使用安全的 Cookie Auth 或是 OAuth/OIDC。
- **AI Agent 協作規範**：所有的具體修改皆需記錄於本檔案 (`README.md`) 中的「執行成果與異動摘要」區塊，並加上時間標記，採「由新到舊」排序。

---

## 執行成果與異動摘要

### 2026-03-26
- **異動摘要**：
    - 建立 `README.md` 檔案，新增專案的基本說明以及 `GEMINI.md` 的開發規範重點摘要。
    - 建立並套用 ASP.NET Core 標準 `.gitignore` 檔案，並保留 `.vs`、`.agent` 及 `.github` 等自定義排除路徑。
