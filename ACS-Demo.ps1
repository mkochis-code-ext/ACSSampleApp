# Azure Communication Services Demo Script
# This script demonstrates sending Email and SMS using Azure Communication Services

#Requires -Version 5.1

# Function to generate HMAC-SHA256 signature for ACS authentication
function Get-ACSAuthSignature {
    param(
        [string]$Method,
        [string]$PathAndQuery,
        [string]$HostName,
        [string]$AccessKey,
        [string]$ContentHash = "",
        [string]$Date
    )

    # Construct the string to sign
    $stringToSign = "$Method`n$PathAndQuery`n$Date;$HostName;$ContentHash"
    
    # Decode the access key from base64
    $keyBytes = [Convert]::FromBase64String($AccessKey)
    
    # Create HMAC-SHA256 hash
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keyBytes
    $hashBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
    
    # Encode to base64
    $signature = [Convert]::ToBase64String($hashBytes)
    
    return "HMAC-SHA256 SignedHeaders=x-ms-date;host;x-ms-content-sha256&Signature=$signature"
}

# Function to display the main menu
function Show-MainMenu {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Azure Communication Services Demo" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Send Email" -ForegroundColor Green
    Write-Host "2. Send SMS" -ForegroundColor Green
    Write-Host "3. Configure ACS Settings" -ForegroundColor Yellow
    Write-Host "4. Exit" -ForegroundColor Red
    Write-Host ""
}

# Function to display email method selection menu
function Show-EmailMethodMenu {
    Write-Host ""
    Write-Host "Select Email Method:" -ForegroundColor Cyan
    Write-Host "1. ACS Email API" -ForegroundColor Green
    Write-Host "2. ACS SMTP Relay" -ForegroundColor Green
    Write-Host "3. Back to Main Menu" -ForegroundColor Yellow
    Write-Host ""
}

# Function to send email via Azure Communication Services
function Send-ACSEmail {
    param(
        [string]$Endpoint,
        [string]$AccessKey,
        [string]$FromAddress,
        [string]$ToAddress,
        [string]$Subject,
        [string]$Body
        
    )

    try {
        # API version for Email
        $apiVersion = "2023-03-31"
        $pathAndQuery = "/emails:send?api-version=$apiVersion"
        $url = "$Endpoint$pathAndQuery"
        
        # Create the request body
        $emailBody = @{
            senderAddress = $FromAddress
            recipients = @{
                to = @(
                    @{
                        address = $ToAddress
                    }
                )
            }
            content = @{
                subject = $Subject
                plainText = $Body
            }
        } | ConvertTo-Json -Depth 10

        # Generate authentication
        $dateString = [DateTime]::UtcNow.ToString("r")
        $hostName = ([System.Uri]$Endpoint).Host
        
        # Calculate SHA256 hash of the request body
        $sha256 = [System.Security.Cryptography.SHA256]::Create()
        $bodyBytes = [Text.Encoding]::UTF8.GetBytes($emailBody)
        $hashBytes = $sha256.ComputeHash($bodyBytes)
        $contentHash = [Convert]::ToBase64String($hashBytes)
        
        $authSignature = Get-ACSAuthSignature -Method "POST" -PathAndQuery $pathAndQuery -HostName $hostName -AccessKey $AccessKey -ContentHash $contentHash -Date $dateString

        # Prepare headers
        $headers = @{
            "Content-Type" = "application/json"
            "x-ms-date" = $dateString
            "host" = $hostName
            "x-ms-content-sha256" = $contentHash
            "Authorization" = $authSignature
        }

        # Send the request
        Write-Host "`nSending email..." -ForegroundColor Yellow
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $emailBody -ContentType "application/json"
        
        Write-Host "`nEmail sent successfully!" -ForegroundColor Green
        Write-Host "Message ID: $($response.id)" -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Host "`nError sending email:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $false
    }
}

# Function to send email via ACS SMTP Relay
function Send-ACSSMTPEmail {
    param(
        [string]$SmtpServer,
        [int]$SmtpPort,
        [string]$SmtpUsername,
        [string]$SmtpPassword,
        [string]$FromAddress,
        [string]$ToAddress,
        [string]$Subject,
        [string]$Body
    )

    try {
        Write-Host "`nSending email via ACS SMTP Relay..." -ForegroundColor Yellow
        
        # Create the email message
        $message = New-Object System.Net.Mail.MailMessage
        $message.From = $FromAddress
        $message.To.Add($ToAddress)
        $message.Subject = $Subject
        $message.Body = $Body
        $message.IsBodyHtml = $false

        # Create SMTP client for ACS SMTP Relay
        $smtp = New-Object System.Net.Mail.SmtpClient($SmtpServer, $SmtpPort)
        $smtp.EnableSsl = $true  # ACS SMTP requires TLS
        
        # ACS SMTP requires authentication
        if (-not [string]::IsNullOrWhiteSpace($SmtpUsername)) {
            $securePassword = ConvertTo-SecureString $SmtpPassword -AsPlainText -Force
            $smtp.Credentials = New-Object System.Management.Automation.PSCredential($SmtpUsername, $securePassword)
        }
        else {
            Write-Host "Warning: ACS SMTP requires authentication credentials." -ForegroundColor Yellow
        }

        # Send the email
        $smtp.Send($message)
        
        Write-Host "`nEmail sent successfully via ACS SMTP Relay!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "`nError sending email via ACS SMTP Relay:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return $false
    }
    finally {
        if ($message) { $message.Dispose() }
        if ($smtp) { $smtp.Dispose() }
    }
}

# Function to send SMS via Azure Communication Services
function Send-ACSSMS {
    param(
        [string]$Endpoint,
        [string]$AccessKey,
        [string]$FromNumber,
        [string]$ToNumber,
        [string]$Message
    )

    try {
        # API version for SMS
        $apiVersion = "2021-03-07"
        $pathAndQuery = "/sms?api-version=$apiVersion"
        $url = "$Endpoint$pathAndQuery"

        # Create the request body
        $smsBody = @{
            from = $FromNumber
            smsRecipients = @(
                @{
                    to = $ToNumber
                }
            )
            message = $Message
            smsSendOptions = @{
                enableDeliveryReport = $true
            }
        } | ConvertTo-Json -Depth 10

        # Generate authentication
        $dateString = [DateTime]::UtcNow.ToString("r")
        $hostName = ([System.Uri]$Endpoint).Host
        
        # Calculate SHA256 hash of the request body
        $sha256 = [System.Security.Cryptography.SHA256]::Create()
        $bodyBytes = [Text.Encoding]::UTF8.GetBytes($smsBody)
        $hashBytes = $sha256.ComputeHash($bodyBytes)
        $contentHash = [Convert]::ToBase64String($hashBytes)
        
        $authSignature = Get-ACSAuthSignature -Method "POST" -PathAndQuery $pathAndQuery -HostName $hostName -AccessKey $AccessKey -ContentHash $contentHash -Date $dateString

        # Prepare headers
        $headers = @{
            "Content-Type" = "application/json"
            "x-ms-date" = $dateString
            "host" = $hostName
            "x-ms-content-sha256" = $contentHash
            "Authorization" = $authSignature
        }

        # Send the request
        Write-Host "`nSending SMS..." -ForegroundColor Yellow
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $smsBody -ContentType "application/json"
        
        Write-Host "`nSMS sent successfully!" -ForegroundColor Green
        Write-Host "Message ID: $($response.messageId)" -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Host "`nError sending SMS:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
        return $false
    }
}

# Function to handle email sending workflow
function Start-EmailWorkflow {
    param(
        [hashtable]$ACSConfig
    )

    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host "Send Email" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan

    if ($null -eq $ACSConfig) {
        Write-Host "`nACS not configured. Please configure ACS settings first." -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }

    Show-EmailMethodMenu
    $method = Read-Host "Select an option (1-3)"

    if ($method -eq "3") {
        return
    }

    $useAPI = ($method -eq "1")
    $useSMTP = ($method -eq "2")

    # Check if SMTP credentials are configured when using SMTP
    if ($useSMTP) {
        if ([string]::IsNullOrWhiteSpace($ACSConfig.SmtpUsername) -or [string]::IsNullOrWhiteSpace($ACSConfig.SmtpPassword)) {
            Write-Host "`nACS SMTP credentials not configured. Please configure ACS settings with SMTP credentials." -ForegroundColor Red
            Read-Host "Press Enter to continue"
            return
        }
    }

    Write-Host ""

    # Collect email details
    $defaultFrom = $ACSConfig.DefaultFromEmail
    $fromAddress = Read-Host "From Email Address [$defaultFrom]"
    if ([string]::IsNullOrWhiteSpace($fromAddress)) {
        $fromAddress = $defaultFrom
    }

    $toAddress = Read-Host "To Email Address"
    if ([string]::IsNullOrWhiteSpace($toAddress)) {
        Write-Host "To address is required!" -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }

    $subject = Read-Host "Subject"
    if ([string]::IsNullOrWhiteSpace($subject)) {
        $subject = "Test Email from Azure Communication Services"
    }

    $body = Read-Host "Message Body"
    if ([string]::IsNullOrWhiteSpace($body)) {
        $body = "This is a test email sent from Azure Communication Services."
    }

    # Confirm before sending
    Write-Host "`n----- Email Summary -----" -ForegroundColor Yellow
    Write-Host "From: $fromAddress"
    Write-Host "To: $toAddress"
    Write-Host "Subject: $subject"
    Write-Host "Body: $body"
    Write-Host "------------------------" -ForegroundColor Yellow
    Write-Host ""

    $confirm = Read-Host "Send this email? (Y/N)"
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        if ($useAPI) {
            Send-ACSEmail -Endpoint $ACSConfig.Endpoint -AccessKey $ACSConfig.AccessKey -FromAddress $fromAddress -ToAddress $toAddress -Subject $subject -Body $body
        }
        elseif ($useSMTP) {
            Send-ACSSMTPEmail -SmtpServer $ACSConfig.SmtpEndpoint -SmtpPort $ACSConfig.SmtpPort -SmtpUsername $ACSConfig.SmtpUsername -SmtpPassword $ACSConfig.SmtpPassword -FromAddress $fromAddress -ToAddress $toAddress -Subject $subject -Body $body
        }
    }
    else {
        Write-Host "Email cancelled." -ForegroundColor Yellow
    }

    Read-Host "`nPress Enter to continue"
}

# Function to handle SMS sending workflow
function Start-SMSWorkflow {
    param(
        [string]$Endpoint,
        [string]$AccessKey,
        [string]$DefaultFromNumber
    )

    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host "Send SMS" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""

    # Collect SMS details
    $fromNumber = Read-Host "From Phone Number (E.164 format, e.g., +1234567890) [$DefaultFromNumber]"
    if ([string]::IsNullOrWhiteSpace($fromNumber)) {
        $fromNumber = $DefaultFromNumber
    }

    $toNumber = Read-Host "To Phone Number (E.164 format, e.g., +1234567890)"
    if ([string]::IsNullOrWhiteSpace($toNumber)) {
        Write-Host "To phone number is required!" -ForegroundColor Red
        Read-Host "Press Enter to continue"
        return
    }

    $message = Read-Host "Message Text"
    if ([string]::IsNullOrWhiteSpace($message)) {
        $message = "This is a test SMS from Azure Communication Services."
    }

    # Confirm before sending
    Write-Host "`n----- SMS Summary -----" -ForegroundColor Yellow
    Write-Host "From: $fromNumber"
    Write-Host "To: $toNumber"
    Write-Host "Message: $message"
    Write-Host "----------------------" -ForegroundColor Yellow
    Write-Host ""

    $confirm = Read-Host "Send this SMS? (Y/N)"
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        Send-ACSSMS -Endpoint $Endpoint -AccessKey $AccessKey -FromNumber $fromNumber -ToNumber $toNumber -Message $message
    }
    else {
        Write-Host "SMS cancelled." -ForegroundColor Yellow
    }

    Read-Host "`nPress Enter to continue"
}

# Function to configure ACS settings
function Set-ACSConfiguration {
    Write-Host "`n=====================================" -ForegroundColor Cyan
    Write-Host "Configure ACS Settings" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""

    $endpoint = Read-Host "ACS Endpoint (e.g., https://your-acs-resource.communication.azure.com)"
    $accessKey = Read-Host "Access Key" -AsSecureString
    $accessKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($accessKey))
    
    $fromEmail = Read-Host "Default From Email Address (e.g., donotreply@your-domain.com)"
    $fromPhone = Read-Host "Default From Phone Number (E.164 format, e.g., +1234567890)"

    Write-Host ""
    Write-Host "--- SMTP Relay Configuration (Optional) ---" -ForegroundColor Cyan
    Write-Host "For ACS SMTP Relay, get credentials from Azure Portal > Communication Service > Email > Settings" -ForegroundColor Gray
    $smtpUsername = Read-Host "ACS SMTP Username (leave blank to skip)"
    $smtpPassword = ""
    if (-not [string]::IsNullOrWhiteSpace($smtpUsername)) {
        $secureSmtpPassword = Read-Host "ACS SMTP Password" -AsSecureString
        $smtpPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSmtpPassword))
    }

    # Save to a secure configuration file
    $config = @{
        Endpoint = $endpoint
        AccessKey = $accessKeyPlain
        DefaultFromEmail = $fromEmail
        DefaultFromPhone = $fromPhone
        SmtpEndpoint = "smtp.azurecomm.net"
        SmtpPort = 587
        SmtpUsername = $smtpUsername
        SmtpPassword = $smtpPassword
    } | ConvertTo-Json

    $configPath = Join-Path $PSScriptRoot "acs-config.json"
    $config | Out-File -FilePath $configPath -Force

    Write-Host "`nConfiguration saved to: $configPath" -ForegroundColor Green
    Write-Host "NOTE: This file contains sensitive information. Keep it secure!" -ForegroundColor Yellow
    
    Read-Host "`nPress Enter to continue"
    
    return @{
        Endpoint = $endpoint
        AccessKey = $accessKeyPlain
        DefaultFromEmail = $fromEmail
        DefaultFromPhone = $fromPhone
        SmtpEndpoint = "smtp.azurecomm.net"
        SmtpPort = 587
        SmtpUsername = $smtpUsername
        SmtpPassword = $smtpPassword
    }
}

# Function to load configuration
function Get-ACSConfiguration {
    $configPath = Join-Path $PSScriptRoot "acs-config.json"
    
    if (Test-Path $configPath) {
        try {
            $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
            return @{
                Endpoint = $config.Endpoint
                AccessKey = $config.AccessKey
                DefaultFromEmail = $config.DefaultFromEmail
                DefaultFromPhone = $config.DefaultFromPhone
                SmtpEndpoint = if ($config.SmtpEndpoint) { $config.SmtpEndpoint } else { "smtp.azurecomm.net" }
                SmtpPort = if ($config.SmtpPort) { $config.SmtpPort } else { 587 }
                SmtpUsername = if ($config.SmtpUsername) { $config.SmtpUsername } else { "" }
                SmtpPassword = if ($config.SmtpPassword) { $config.SmtpPassword } else { "" }
            }
        }
        catch {
            Write-Host "Error loading ACS configuration file." -ForegroundColor Red
            return $null
        }
    }
    return $null
}

# Main script execution
function Start-ACSDemo {
    $acsConfig = Get-ACSConfiguration

    $running = $true
    while ($running) {
        Show-MainMenu
        $choice = Read-Host "Select an option (1-4)"

        switch ($choice) {
            "1" {
                Start-EmailWorkflow -ACSConfig $acsConfig
            }
            "2" {
                if ($null -eq $acsConfig) {
                    Write-Host "Please configure ACS settings first." -ForegroundColor Red
                    Read-Host "Press Enter to continue"
                }
                else {
                    Start-SMSWorkflow -Endpoint $acsConfig.Endpoint -AccessKey $acsConfig.AccessKey -DefaultFromNumber $acsConfig.DefaultFromPhone
                }
            }
            "3" {
                $acsConfig = Set-ACSConfiguration
            }
            "4" {
                Write-Host "`nGoodbye!" -ForegroundColor Cyan
                $running = $false
            }
            default {
                Write-Host "`nInvalid option. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

# Start the demo
Start-ACSDemo
