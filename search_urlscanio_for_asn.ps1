<#
.SYNOPSIS
This script searches urlscan.io for domains associated with a given ASN (Autonomous System Number) and outputs the results to a CSV file.

.DESCRIPTION
The script requires an ASN number as input. It makes a call to the urlscan.io API, retrieves up to 10,000 domain results for the specified ASN, and exports the unique domains to a CSV file named result_urlscanio_[asnNumber].csv.

.PARAMETER asnNumber
The Autonomous System Number (ASN) for which the search will be conducted.

.EXAMPLE
PS> .\YourScriptName.ps1 -asnNumber AS200593

.NOTES
Ensure you have a valid urlscan.io API key and set it in the script before running.

#>

param (
    [Parameter(Mandatory=$true, HelpMessage="You must provide an ASN number. For example, AS200593.")]
    [string]$asnNumber
)

if (-not $asnNumber) {
    Write-Host "No ASN number provided. Use the -asnNumber parameter to specify the ASN. For example: -asnNumber AS200593"
    exit
}

$apiKey = ""
if (-not $apiKey) {
    Write-Host "API Key is required. Please set your urlscan.io API key in the script."
    exit
}

$headers = @{
    "API-Key" = $apiKey
    "Content-Type" = "application/json"
}

$fileName = "result_urlscanio_$($asnNumber.ToLower()).csv"
$asnSearchTerm = "page.asn:$asnNumber"

Write-Host "Output file: $fileName"
Write-Host "Search term: $asnSearchTerm"

# Adjust the size according to the maximum allowed by the API in a single call
$size = 10000 # Assuming the API could handle this size; adjust based on actual max limit

$uri = "https://urlscan.io/api/v1/search/?q=$asnSearchTerm&size=$size"

try {
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ErrorAction Stop
    $results = $response.results

    if ($results.Count -gt 0) {
        $domains = $results | ForEach-Object { $_.page.domain }
        # Ensure unique domains and write to CSV
        $uniqueDomains = $domains | Sort-Object -Unique
        $uniqueDomains | ForEach-Object { [PSCustomObject]@{Domain = $_} } | Export-Csv -Path $fileName -NoTypeInformation
        Write-Host "Search completed. Results are saved in $fileName"
    } else {
        Write-Host "No results found for the given ASN number."
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $statusDescription = $_.Exception.Response.StatusDescription
    Write-Host "An error occurred: $statusDescription ($statusCode)"
}
