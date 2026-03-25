#!/usr/bin/env bash
# Usage:
#   bash init-mvc-generic.sh [ProjectName] [TargetFramework] [AuthMode]
#
# Make executable:
#   chmod +x init-mvc-generic.sh
#   ./init-mvc-generic.sh [ProjectName] [TargetFramework] [AuthMode]
#
# Example:
#   ./init-mvc-generic.sh MyMvcCms net10.0 none
#   ./init-mvc-generic.sh MyMvcCms net10.0 individual
#   ./init-mvc-generic.sh MyMvcCms net10.0 singleorg
#
# Optional Microsoft Entra ID example:
#   ./init-mvc-generic.sh MyMvcCms net10.0 o365
#
# Then update appsettings.json or appsettings.Development.json:
#   "AzureAd": {
#     "Instance": "https://login.microsoftonline.com/",
#     "Domain": "o365.tku.edu.tw",
#     "TenantId": "<tenant-id>",
#     "ClientId": "<client-id>",
#     "CallbackPath": "/signin-oidc"
#   }
#
# If you want to enable login, configure Program.cs with Microsoft.Identity.Web, for example:
#   builder.Services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
#       .AddMicrosoftIdentityWebApp(builder.Configuration.GetSection("AzureAd"));
#   builder.Services.AddControllersWithViews();
#   builder.Services.AddRazorPages().AddMicrosoftIdentityUI();
#   app.UseAuthentication();
#   app.UseAuthorization();
#
# Optional authentication guideline:
#   Pages are anonymous by default.
#   Enable authentication only when the project requires login.
#   Only add [Authorize] or [Authorize(Roles = "...")] on controllers/actions that require login.

set -euo pipefail

PROJECT_NAME="${1:-MyMvcCms}"
TARGET_FRAMEWORK="${2:-net10.0}"
AUTH_MODE="${3:-none}"
DOMAIN_SUFFIX="@o365.tku.edu.tw"
AZURE_AD_DOMAIN="o365.tku.edu.tw"

if [[ -e "$PROJECT_NAME" ]]; then
  echo "Directory '$PROJECT_NAME' already exists." >&2
  exit 1
fi

# mkdir -p "$PROJECT_NAME"
# cd "$PROJECT_NAME"

dotnet new sln -n "$PROJECT_NAME"

if [[ "${AUTH_MODE}" == "individual" ]]; then
  dotnet new mvc -n "$PROJECT_NAME" -f "$TARGET_FRAMEWORK" -au Individual --use-program-main
elif [[ "${AUTH_MODE}" == "o365" || "${AUTH_MODE}" == "singleorg" ]]; then
  dotnet new mvc -n "$PROJECT_NAME" -f "$TARGET_FRAMEWORK" -au SingleOrg --use-program-main
else
  dotnet new mvc -n "$PROJECT_NAME" -f "$TARGET_FRAMEWORK" --use-program-main
fi

dotnet sln add "$PROJECT_NAME/$PROJECT_NAME.csproj"
cd "$PROJECT_NAME"

dotnet add package Dapper
dotnet add package Microsoft.Data.SqlClient
dotnet add package Newtonsoft.Json

dotnet add package Microsoft.Identity.Web
dotnet add package Microsoft.Identity.Web.UI

mkdir -p Models/ViewModels
mkdir -p SQL
mkdir -p Services
mkdir -p Extensions
mkdir -p wwwroot/lib

if [[ ! -f appsettings.Development.json ]]; then
  cat > appsettings.Development.json <<'EOF'
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=MyMvcCms;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Auth": {
    "DomainSuffix": "$DOMAIN_SUFFIX",
    "PostLogoutRedirectPath": "/"
  },
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "Domain": "$AZURE_AD_DOMAIN",
    "TenantId": "00000000-0000-0000-0000-000000000000",
    "ClientId": "00000000-0000-0000-0000-000000000000",
    "CallbackPath": "/signin-oidc"
  }
}
EOF
fi

cat > appsettings.json <<'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=MyMvcCms;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Auth": {
    "DomainSuffix": "$DOMAIN_SUFFIX",
    "PostLogoutRedirectPath": "/"
  },
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "Domain": "$AZURE_AD_DOMAIN",
    "TenantId": "00000000-0000-0000-0000-000000000000",
    "ClientId": "00000000-0000-0000-0000-000000000000",
    "CallbackPath": "/signin-oidc"
  }
}
EOF

if command -v libman >/dev/null 2>&1; then
  libman init -p cdnjs
  libman install jquery@3.7.1 -d wwwroot/lib/jquery
  libman install twitter-bootstrap@5.3.3 -d wwwroot/lib/bootstrap
  libman install select2@4.1.0-rc.0 -d wwwroot/lib/select2
  libman install datatables.net-bs5@2.3.4 -d wwwroot/lib/datatables
else
  echo "libman CLI not found; skipping LibMan package install."
  echo "Install later with: dotnet tool install -g Microsoft.Web.LibraryManager.Cli"
fi

cat > .editorconfig <<'EOF'
root = true

[*]
charset = utf-8-bom
end_of_line = crlf
insert_final_newline = true
indent_style = space
indent_size = 4
trim_trailing_whitespace = true

[*.cshtml]
indent_size = 4

[*.{json,yml,yaml,md}]
indent_size = 2
EOF

cat > README.md <<EOF
# $PROJECT_NAME

## 初始化資訊

- Project: $PROJECT_NAME
- Framework: $TARGET_FRAMEWORK
- Auth Mode: $AUTH_MODE
- Architecture: ASP.NET Core MVC
- Data Access: Dapper + Microsoft.Data.SqlClient
- Package Frontend: LibMan
- Default Domain Suffix: $DOMAIN_SUFFIX

## 後續建議

1. 調整 appsettings.json 與 appsettings.Development.json
2. 若使用 singleorg，請填入正確的 Microsoft Entra ID TenantId / ClientId
3. 若需登入功能，再於 Program.cs 加入驗證、授權、資料庫注入；頁面預設匿名，僅對需要保護的頁面加上 [Authorize]
4. 建立 Models/ViewModels、Services、Extensions、SQL 結構
5. 建立共用 Toast Partial、登入登出流程、returnUrl 驗證
EOF

dotnet restore

echo
echo "Initialization completed: $(pwd)"
echo "Next step: cd '$PROJECT_NAME' and start implementing Program.cs / authentication / Dapper wiring."
