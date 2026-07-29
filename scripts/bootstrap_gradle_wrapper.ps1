$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repositoryRoot "app\android\gradle\wrapper\gradle-wrapper.jar"
$expected = "81a82aaea5abcc8ff68b3dfcb58b3c3c429378efd98e7433460610fecd7ae45f"

if (-not (Test-Path $target)) {
    Invoke-WebRequest `
        -Uri "https://raw.githubusercontent.com/gradle/gradle/v8.13.0/gradle/wrapper/gradle-wrapper.jar" `
        -OutFile $target
}

$actual = (Get-FileHash -Algorithm SHA256 $target).Hash.ToLowerInvariant()
if ($actual -ne $expected) {
    Remove-Item -LiteralPath $target -Force
    throw "Gradle wrapper checksum validation failed."
}
