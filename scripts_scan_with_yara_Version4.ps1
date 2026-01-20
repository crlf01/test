Param(
  [string]$Rules = ".\all_rules_combined.yar",
  [string]$Target = "C:\inetpub\wwwroot",
  [string]$YaraExe = ".\out\bin\yara.exe"
)
if (-not (Test-Path $YaraExe)) { Write-Error "yara not found: $YaraExe"; exit 2 }
Get-ChildItem -Path $Target -Recurse -File | ForEach-Object {
  $path = $_.FullName
  $res = & $YaraExe -r $Rules $path 2>$null
  if ($res) {
    Write-Host "MATCH: $path"
    Write-Host $res
  }
}