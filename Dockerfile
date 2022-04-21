# escape=`
ARG BASE
FROM mcr.microsoft.com/windows/servercore:$BASE
ENV VERSION 2.290.1

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
USER ContainerAdministrator
RUN iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
    choco install -y docker-cli; `
    choco install -y git ; `
    choco install -y jq; 

WORKDIR c:/actions-runner

RUN Invoke-WebRequest -Uri \"https://github.com/actions/runner/releases/download/v$env:VERSION/actions-runner-win-x64-$env:VERSION.zip\" -OutFile actions-runner.zip -UseBasicParsing; `
    Expand-Archive actions-runner.zip -DestinationPath .; `
    Remove-Item actions-runner.zip; 

COPY cmd.ps1 .

CMD .\cmd.ps1
