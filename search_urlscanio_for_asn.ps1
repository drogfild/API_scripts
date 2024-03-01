param (
    [Parameter(Mandatory=$true)]
    [string]$asnNumber
)

$apiKey = ""
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

