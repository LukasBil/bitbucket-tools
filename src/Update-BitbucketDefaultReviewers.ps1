param(
    [Parameter(Mandatory = $true)][string]$userName,
    [Parameter(Mandatory = $true)][string]$apiToken,
    [Parameter(Mandatory = $true)][string]$workspace,
    [Parameter(Mandatory = $true)][string]$usersList,
    [Parameter(Mandatory = $false)][string]$baseUrl = "https://api.bitbucket.org/2.0"
)

. "$PSScriptRoot\Get-BitBucketAuthorizationHeaders.ps1"

function Get-WorkspaceMembers(){
    try{
        $result = Invoke-RestMethod -Uri "$baseUrl/workspaces/$workspace/members" `
                    -ContentType "application/json" `
                    -Method Get `
                    -Headers $headers `
                    -ErrorAction Stop `

        return $result
    }
    catch{
        Write-Host "Failed to retrieve workspace members for workspace: $workspace"
        Write-Host "Status code: " $_.Exception.Response.StatusCode.Value__
        Write-Host "Description" $_.Exception.Response.StatusDescription
        Exit 1
    }
}

function Get-WorkspaceRepositories(){
    try{
        $result = Invoke-RestMethod -Uri "$baseUrl/repositories/$workspace" `
                    -ContentType "application/json" `
                    -Method Get `
                    -Headers $headers `
                    -ErrorAction Stop `

        return $result
    }
    catch{
        Write-Host "Failed to retrieve repositories for workspace: $workspace"
        Write-Host "Status code: " $_.Exception.Response.StatusCode.Value__
        Write-Host "Description" $_.Exception.Response.StatusDescription
        Exit 1
    }

}

function Update-DefaultReviewers{
    param(
        [string] $accountUUID,
        [string] $repositorySlug
    )
    $body = '{
        "uuid": "' + $accountUUID + '"
    }'

    try{
        $result = Invoke-RestMethod -Uri "$baseUrl/repositories/$workspace/$repositorySlug
        /default-reviewers/$accountUUID" `
        -ContentType "application/json" `
        -Method PUT `
        -Body $body `
        -Headers $headers `
        -ErrorAction Stop `

        Write-Host "Succesfully updated $repositorySlug with $accountUUID"
    }
    catch{
        Write-Host "Failed to update $repositorySlug repository with $accountUUID"
        Write-Host "Status code: " $_.Exception.Response.StatusCode.Value__
        Write-Host "Description" $_.Exception.Response.StatusDescription
    }
}

$global:headers = Get-BitBucketAuthorizationHeaders $userName $apiToken
$usersWithDetails = New-Object System.Collections.Generic.List[System.Object]
$workspaceMembers = Get-WorkspaceMembers
$repositories = Get-WorkspaceRepositories

$usersList.Split(',') | ForEach-Object {
    $userTemp = $_
    $userDetails = $workspaceMembers.values | Where-Object {$_.user.nickname -eq $userTemp } | Select-Object -Property user
    $usersWithDetails.Add($userDetails)
}

$repositories.values | ForEach-Object {
    $tempRepositorySlug = $_.slug
    $usersWithDetails | ForEach-Object {
        Update-DefaultReviewers $_.user.uuid $tempRepositorySlug
    }
}