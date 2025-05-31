# 📊 extractReportMfaUsers

Este repositório contém um script em PowerShell moderno que se conecta à Microsoft Graph API para **extrair um relatório completo de usuários do Microsoft Entra ID (Azure AD)** com foco em autenticação multifator (MFA).

## 🔍 Objetivo

Gerar um relatório detalhado em `.csv` ou `.xlsx` com os seguintes campos:
- UserPrincipalName
- DisplayName
- BlockCredential
- WhenCreated
- EmployeeID
- MFAState
- MFADefaultMethod
- MFAPhoneNumber
- MFAPhoneDevice
- PrimarySMTP
- Aliases

## 🚀 Funcionalidades

- Conexão via Microsoft Graph com **client_id/client_secret** (autenticação do tipo confidential client)
- Exportação para CSV ou Excel
- Compatível com PowerShell 7+

## 🛠️ Pré-requisitos

- PowerShell 7.2+
- Permissões de aplicativo no Entra ID:
  - `User.Read.All`
  - `Directory.Read.All`
  - `UserAuthenticationMethod.Read.All`
- Módulos PowerShell:
  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  Install-Module ImportExcel -Scope CurrentUser
  ```

## ⚙️ Configuração no Entra ID

1. Registre um novo aplicativo em **Microsoft Entra ID**
2. Gere um **Client Secret**
3. Conceda as permissões acima via **Permissões de API**
4. Faça o consentimento do administrador
5. Copie as seguintes informações para usar no script:
   - Tenant ID
   - Client ID
   - Client Secret

## ▶️ Como usar

1. Clone o repositório:
   ```bash
   git clone https://github.com/ErickMedeiros/extractReportMfaUsers.git
   cd extractReportMfaUsers
   ```

2. Abra o script `.ps1` e edite com suas credenciais:
   ```powershell
   $tenantId = "<SEU_TENANT_ID>"
   $clientId = "<SEU_CLIENT_ID>"
   $clientSecret = "<SEU_CLIENT_SECRET>"
   ```

3. Execute o script:
   ```powershell
   ./Relatorio_MFA_ConfidencialClient.ps1
   ```

4. O resultado será exportado para:
   ```
   C:\Export\MFA_Report.csv
   ```

## 📂 Estrutura do Repositório

```
extractReportMfaUsers/
├── Relatorio_MFA_ConfidencialClient.ps1
├── Documentacao_Script_MFA_ClientSecret.docx
├── README.md
```

## 🙋‍♂️ Contribuições

Sinta-se à vontade para abrir issues, sugestões e pull requests!

## 📄 Licença

[MIT](LICENSE)
