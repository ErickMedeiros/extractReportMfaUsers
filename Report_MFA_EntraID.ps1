
<#
.SYNOPSIS
    Script PowerShell para geração de relatório de MFA com autenticação baseada em client_id + client_secret.

.REQUISITOS:
    - Aplicativo empresarial registrado no Entra ID com permissões:
        * Application (não delegadas): User.Read.All, Directory.Read.All, UserAuthenticationMethod.Read.All
    - Configurar as variáveis abaixo: $tenantId, $clientId, $clientSecret

.EXPORTA:
    - C:\Export\MFA_Report.csv
#>

# Variáveis do App Registrado
$tenantId     = "<TENANT ID>"
$clientId     = "<CLIENT ID>"
$clientSecret = "<Value - Secret ID>"

# Autenticação via MSAL
$body = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $clientId
    client_secret = $clientSecret
}

$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Body $body
$token = $tokenResponse.access_token

if (-not $token) {
    Write-Host "❌ Erro ao obter token de acesso." -ForegroundColor Red
    exit
}

# Cabeçalhos para Graph API
$headers = @{ Authorization = "Bearer $token" }

# Inicializar relatório
$Report = [System.Collections.Generic.List[Object]]::new()

# Obter usuários
$uri = "https://graph.microsoft.com/v1.0/users?$top=999"
do {
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    foreach ($User in $response.value) {
        Write-Host "🔍 Processando: $($User.userPrincipalName)" -ForegroundColor Yellow

        $UPN          = $User.userPrincipalName
        $DisplayName  = $User.displayName
        $Blocked      = -not $User.accountEnabled
        $Created      = $User.createdDateTime
        $Aliases      = ($User.proxyAddresses | Where-Object { $_ -like "smtp:*" }) -replace "smtp:", ""
        $PrimarySMTP  = ($User.proxyAddresses | Where-Object { $_ -like "SMTP:*" }) -replace "SMTP:", ""
        $EmployeeID   = $User.employeeId

        $uriAuth = "https://graph.microsoft.com/v1.0/users/$($User.id)/authentication/methods"
        $methods = Invoke-RestMethod -Method Get -Uri $uriAuth -Headers $headers

        $MFAState = if ($methods.value.Count -gt 0) { "Enabled" } else { "Disabled" }
        $MFADefaultMethod = "Not Set"
        $MFAPhoneNumber   = ""
        $MFAPhoneDevice   = ""

        foreach ($method in $methods.value) {
            switch ($method.'@odata.type') {
                "#microsoft.graph.phoneAuthenticationMethod" {
                    $MFAPhoneNumber = $method.phoneNumber
                    $MFADefaultMethod = "SMS/Call"
                }
                "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" {
                    $MFADefaultMethod = "Authenticator App"
                    $MFAPhoneDevice = $method.displayName
                }
                default {
                    $MFADefaultMethod = "Outro: $($method.'@odata.type')"
                }
            }
        }

        $ReportLine = [PSCustomObject]@{
            UserPrincipalName = $UPN
            DisplayName       = $DisplayName
            BlockCredential   = $Blocked
            WhenCreated       = $Created
            EmployeeID        = $EmployeeID
            MFAState          = $MFAState
            MFADefaultMethod  = $MFADefaultMethod
            MFAPhoneNumber    = $MFAPhoneNumber
            MFAPhoneDevice    = $MFAPhoneDevice
            PrimarySMTP       = ($PrimarySMTP -join ',')
            Aliases           = ($Aliases -join ',')
        }

        $Report.Add($ReportLine)
    }

    $uri = $response.'@odata.nextLink'
} while ($uri)

# Exportar CSV
$exportPath = "C:\Export\MFA_Report.csv"
$Report | Sort-Object UserPrincipalName | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8
Write-Host "`n✅ Exportado para: $exportPath" -ForegroundColor Green
