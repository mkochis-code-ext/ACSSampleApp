# Azure Communication Services Demo Script

A PowerShell script for sending emails and SMS messages using Azure Communication Services (ACS). Supports both ACS Email API and ACS SMTP Relay methods.

## Features

- **Email Sending**
  - ACS Email API (REST-based)
  - ACS SMTP Relay (SMTP protocol)
- **SMS Sending** via ACS
- **Interactive Configuration** with secure credential storage
- **Persistent Settings** saved to `acs-config.json`

## Requirements

- PowerShell 5.1 or later
- Azure Communication Services resource
- For email: Verified email domain in ACS
- For SMS: Phone number provisioned in ACS
- For SMTP: Entra ID App Registration with proper permissions

## Configuration Settings

All settings are stored in `acs-config.json`:

| Setting | Description | Example |
|---------|-------------|---------|
| `Endpoint` | ACS resource endpoint URL | `https://your-acs.communication.azure.com` |
| `AccessKey` | ACS access key for API authentication | `your-base64-encoded-key` |
| `DefaultFromEmail` | Default sender email address | `noreply@yourdomain.com` |
| `DefaultFromPhone` | Default sender phone number (E.164 format) | `+15551234567` |
| `SmtpEndpoint` | ACS SMTP relay endpoint | `smtp.azurecomm.net` |
| `SmtpPort` | SMTP port (TLS) | `587` |
| `SmtpUsername` | SMTP username format | `<ACSResourceName>.<AppID>.<TenantID>` |
| `SmtpPassword` | App Registration client secret | `your-client-secret` |

## ACS SMTP Relay Setup

The ACS SMTP Relay requires authentication through an Entra ID App Registration:

### 1. Create App Registration

1. Go to **Azure Portal** → **Entra ID** → **App registrations**
2. Click **New registration**
3. Enter a name (e.g., "ACS-SMTP-App")
4. Select supported account types
5. Click **Register**
6. Note the **Application (client) ID** and **Directory (tenant) ID**

### 2. Create Client Secret

1. In your App Registration, go to **Certificates & secrets**
2. Click **New client secret**
3. Add a description and set expiration
4. Click **Add**
5. **Copy the secret value immediately** (it won't be shown again)

### 3. Create Custom Role with ACS Permissions

1. Go to **Azure Portal** → **Subscriptions** → Select your subscription
2. Click **Access control (IAM)** → **Roles**
3. Click **Add** → **Add custom role**
4. Enter role name (e.g., "ACS Email Sender")
5. Click **Permissions** → **Add permissions**
6. Search for **Microsoft.Communication** and add:
   - `Microsoft.Communication/CommunicationServices/read`
   - `Microsoft.Communication/EmailServices/write`
7. Click **Review + create**

### 4. Assign Role to App Registration

1. Go to your **Communication Services resource**
2. Click **Access control (IAM)**
3. Click **Add** → **Add role assignment**
4. Select your custom role (e.g., "ACS Email Sender")
5. Click **Next**
6. Select **User, group, or service principal**
7. Click **Select members** and search for your App Registration name
8. Select it and click **Review + assign**

### 5. Configure SMTP Username

The SMTP username format is: `<ACSResourceName>.<AppID>.<TenantID>`

**Example:**
```
myacsresource.12345678-1234-1234-1234-123456789abc.87654321-4321-4321-4321-cba987654321
```

Where:
- `myacsresource` = Your ACS resource name
- `12345678-...` = Application (client) ID from step 1
- `87654321-...` = Directory (tenant) ID from step 1

### 6. Update Configuration

Run the script and select **Configure ACS Settings** to enter:
- SMTP Username: `<ACSResourceName>.<AppID>.<TenantID>`
- SMTP Password: Your client secret from step 2

## Usage

### Running the Script

```powershell
.\ACS-Demo.ps1
```

### Main Menu Options

1. **Send Email** - Choose between ACS Email API or ACS SMTP Relay
2. **Send SMS** - Send SMS message via ACS
3. **Configure ACS Settings** - Set up or update all configuration
4. **Exit** - Close the application

### Sending Email

1. Select **Send Email** from main menu
2. Choose email method:
   - **ACS Email API** - Uses REST API with access key
   - **ACS SMTP Relay** - Uses SMTP with App Registration credentials
3. Enter email details (from, to, subject, body)
4. Confirm and send

### Sending SMS

1. Select **Send SMS** from main menu
2. Enter phone numbers in E.164 format (e.g., +15551234567)
3. Enter message text
4. Confirm and send

## Getting ACS Credentials

### ACS Endpoint and Access Key

1. Go to **Azure Portal** → **Communication Services**
2. Select your resource
3. Go to **Keys** under Settings
4. Copy:
   - **Endpoint** (e.g., `https://your-acs.communication.azure.com`)
   - **Primary key** or **Secondary key**

### Email Domain

1. In your Communication Services resource
2. Go to **Email** → **Domains**
3. Add and verify a domain
4. Configure sender addresses (e.g., `noreply@yourdomain.com`)

### Phone Number

1. In your Communication Services resource
2. Go to **Phone numbers**
3. Get a phone number with SMS capabilities
4. Copy the number in E.164 format

## Security Considerations

⚠️ **Important**: The `acs-config.json` file contains sensitive credentials:
- Access keys
- Client secrets
- Configuration details

**Best practices:**
- Add `acs-config.json` to `.gitignore`
- Restrict file permissions
- Never commit credentials to source control
- Rotate secrets regularly
- Use Azure Key Vault for production scenarios

## Troubleshooting

### SMTP Authentication Failed

- Verify App Registration client secret is correct and not expired
- Check SMTP username format: `<ACSResourceName>.<AppID>.<TenantID>`
- Ensure custom role has correct permissions
- Verify role is assigned to the App Registration on the ACS resource

### Email API Errors

- Verify endpoint URL is correct
- Check access key is valid
- Ensure sender email address is verified in ACS
- Confirm email domain is properly configured

### SMS Errors

- Verify phone number format is E.164 (+15551234567)
- Check that sender phone number has SMS capabilities
- Ensure destination number can receive SMS

## Example Configuration

```json
{
    "Endpoint": "https://myacsresource.communication.azure.com",
    "AccessKey": "abc123...",
    "DefaultFromEmail": "noreply@mydomain.com",
    "DefaultFromPhone": "+15551234567",
    "SmtpEndpoint": "smtp.azurecomm.net",
    "SmtpPort": 587,
    "SmtpUsername": "myacsresource.12345678-abcd-1234-abcd-123456789abc.87654321-dcba-4321-dcba-cba987654321",
    "SmtpPassword": "your-client-secret-value"
}
```
