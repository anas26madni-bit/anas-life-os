$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repositoryRoot "app\android\gradle\wrapper\gradle-wrapper.jar"
$expected = "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172"

if (-not (Test-Path $target)) {
    Invoke-WebRequest `
        -Uri "https://raw.githubusercontent.com/gradle/gradle/v8.14.5/gradle/wrapper/gradle-wrapper.jar" `
        -OutFile $target
}

$actual = (Get-FileHash -Algorithm SHA256 $target).Hash.ToLowerInvariant()
if ($actual -ne $expected) {
    Remove-Item -LiteralPath $target -Force
    throw "Gradle wrapper checksum validation failed."
}
