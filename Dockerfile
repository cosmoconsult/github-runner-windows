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
    .\config.cmd --url \"$env:GITHUBURL\" --token \"$env:GITHUBTOKEN\" ; `
    .\run.cmd"