function Get-BitBucketAuthorizationHeaders{
    param(
        [Parameter(Mandatory = $true)][string]$userName,
        [Parameter(Mandatory = $true)][string]$apiToken,
        [Parameter(Mandatory = $false)][string]$baseUrl = "https://api.bitbucket.org/2.0"
    )

    $pair = "$($userName):$($apiToken)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

    $basicAuthValue = "Basic $encodedCreds"

    $headers = @{ Authorization = $basicAuthValue }

    try{
        $result = Invoke-RestMethod `
                    -Uri "$baseUrl/workspaces" `
                    -Headers $headers `
                    -ErrorAction Stop
    }
    catch{
        Write-Host "Status code: " $_.Exception.Response.StatusCode.Value__
        Write-Host "Description" $_.Exception.Response.StatusDescription
        Exit 1
    }

    return $headers
}