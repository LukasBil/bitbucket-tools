## Bitbucket service tools
Powershell script set intended to service and maintain Atlassian BitBucket projects with higher amount of repositories.
Currently repository contains scripts for:
- Default reviewers update for each repository.

#### Prerequisites
1. Service user which is added to workspace, project and each repository.
2. API Token. As for now, authentication with API Tokens works only with Atlassian Cloud, while Atlassian server does not. If that's the case, it's possible so use user password instead of API Token.
**Password support for Atlassian basic authentication is deprecated and will be removed in the future.**

#### Usage
These scripts can be used in your CI/CD tools, to service you repositories nightly, for example. Of course, you can run these scripts localy.

*Update default reviewers for your repositories:*
1. To execute the script you need to serve *service account username*, *apiToken*,
*workspace*, *comma separated list of public names of users who should be default reviewers for your repositories*.

```powershell
./Update-BitbucketDefaultReviewers.ps1 "ServiceAccountUsername" "ApiToken" "WorkspaceName" "Skywalker,DarthVader,R2D2"
```

#### Notes
All API requests forces basic authentication on the first request and Auhentication headers are set explicitly.
This is done due to the reason that some of Atlassian endpoints require credentials
to be sent on the first request and doesn't send authentication challenge request.

Alternatively, you could use  *-Credential* parameter in *Invoke-RestMethod* cmdlet.

```powershell
$apiTokenSecure = ConvertTo-SecureString -String $apiToken -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential($userName, $apiTokenSecure)
```