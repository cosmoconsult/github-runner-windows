$headers = @{
    Authorization = "token $env:GITHUBPAT"
};
$tokenLevel = "orgs";
if ($env:GITHUBREPO_OR_ORG.IndexOf('/') -gt 0) {
    $tokenLevel = "repos"
};
$token = ($(Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/$tokenLevel/$env:GITHUBREPO_OR_ORG/actions/runners/registration-token" -Headers $headers -Method POST).Content | ConvertFrom-Json).token;
.\config.cmd --url "https://github.com/$env:GITHUBREPO_OR_ORG" --token "$token" --name $env:GITHUBRUNNERNAME --replace --unattended ;
Start-Process -FilePath ".\run.cmd"

$failureCount = 0
$maxFailureCount = 3
while ($failureCount -lt $maxFailureCount) {
    Start-Sleep -Seconds 10;
    if ($Null -eq (get-process "Runner.Listener" -ea SilentlyContinue)) {
        $failureCount++;
        Write-Host "not running ($failureCount / $maxFailureCount)"
    }
    else {
        $failureCount = 0;
    }
}
