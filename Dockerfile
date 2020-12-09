# escape=`
ARG BASE
FROM mcr.microsoft.com/windows/servercore:$BASE
ENV VERSION 2.274.2

USER ContainerAdministrator
RUN powershell -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
    choco install -y docker-cli; `
    choco install -y git ; `
    choco install -y jq; "

WORKDIR c:/actions-runner

RUN powershell -Command "`
    Invoke-WebRequest -Uri \"https://github.com/actions/runner/releases/download/v$env:VERSION/actions-runner-win-x64-$env:VERSION.zip\" -OutFile actions-runner.zip -UseBasicParsing; `
    Expand-Archive actions-runner.zip -DestinationPath .; `
    Remove-Item actions-runner.zip; "

CMD powershell -Command "`
    $headers = @{ `
    Authorization=\"token $env:GITHUBPAT\" `
    }; `
    $tokenLevel = \"orgs\"; `
    if ($env:GITHUBREPO_OR_ORG.IndexOf('/') -gt 0) { `
    $tokenLevel = \"repos\" `
    }; `
    $token = ($(Invoke-WebRequest -UseBasicParsing -Uri \"https://api.github.com/$tokenLevel/$env:GITHUBREPO_OR_ORG/actions/runners/registration-token\" -Headers $headers -Method POST).Content | ConvertFrom-Json).token; `
    .\config.cmd --url \"https://github.com/$env:GITHUBREPO_OR_ORG\" --token \"$token\" ; `
    .\run.cmd"