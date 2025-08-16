param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('clean-room','build','optimisation')]
  [string]$Mode
)
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$path = Join-Path $root 'contexts\mode.json'
@{ mode = $Mode } | ConvertTo-Json | Out-File -Encoding UTF8 $path
Write-Host "Updated $path to mode=$Mode"
# Optional commit
try {
  git add $path | Out-Null
  git commit -m "chore(mode): switch to $Mode" | Out-Null
} catch {}
