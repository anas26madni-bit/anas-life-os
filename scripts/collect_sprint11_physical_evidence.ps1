param(
  [Parameter(Mandatory = $true)][string]$Serial,
  [Parameter(Mandatory = $true)][string]$OutputDirectory,
  [ValidateSet('baseline','endurance','idle8h','representative24h')]
  [string]$Phase = 'baseline',
  [string]$Package = 'com.anaslifeos.app'
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

function Invoke-Adb([string[]]$Arguments) {
  & adb -s $Serial @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) { throw "adb failed: $($Arguments -join ' ')" }
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$prefix = Join-Path $OutputDirectory "$Phase-$stamp"
Invoke-Adb @('shell','getprop') | Set-Content "$prefix-device-properties.txt"
Invoke-Adb @('shell','dumpsys','package',$Package) | Set-Content "$prefix-package.txt"
Invoke-Adb @('shell','dumpsys','meminfo',$Package) | Set-Content "$prefix-meminfo.txt"
Invoke-Adb @('shell','dumpsys','gfxinfo',$Package,'framestats') | Set-Content "$prefix-gfxinfo.txt"
Invoke-Adb @('shell','dumpsys','batterystats',$Package) | Set-Content "$prefix-batterystats.txt"
Invoke-Adb @('shell','dumpsys','power') | Set-Content "$prefix-power.txt"
Invoke-Adb @('shell','dumpsys','alarm') | Set-Content "$prefix-alarms.txt"
Invoke-Adb @('shell','dumpsys','jobscheduler') | Set-Content "$prefix-jobscheduler.txt"

if ($Phase -eq 'baseline') {
  $launches = for ($index = 1; $index -le 10; $index++) {
    Invoke-Adb @('shell','am','force-stop',$Package) | Out-Null
    $result = Invoke-Adb @('shell','am','start','-W','-a','android.intent.action.MAIN','-c','android.intent.category.LAUNCHER',$Package)
    $total = ($result | Select-String '^TotalTime:').Line.Split(':')[-1].Trim()
    [pscustomobject]@{ Run = $index; TotalTimeMs = [int]$total }
  }
  $launches | Export-Csv "$prefix-warm-launches.csv" -NoTypeInformation
}

Invoke-Adb @('logcat','-d') | Set-Content "$prefix-logcat.txt"
Get-FileHash "$prefix-*" -Algorithm SHA256 | Export-Csv "$prefix-sha256.csv" -NoTypeInformation
