# Auto-deploy: obserwuje ten folder i po kazdej zmianie robi commit + push.
# Uruchom raz na sesje edycji (w VS Code: Terminal -> New Terminal):
#     powershell -ExecutionPolicy Bypass -File .\auto-deploy.ps1
# Zatrzymanie: Ctrl+C. Strona live ~1 min po kazdym pushu.

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

Write-Host "Obserwuje $PSScriptRoot  (Ctrl+C aby zakonczyc)" -ForegroundColor Cyan

while ($true) {
    $status = git status --porcelain
    if ($status) {
        # poczekaj az edycje sie ustabilizuja (2 s bez kolejnych zmian)
        do {
            $snapshot = $status
            Start-Sleep -Seconds 2
            $status = git status --porcelain
        } while ($status -ne $snapshot)

        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        git add -A
        git commit -m "Auto update $stamp" | Out-Null
        try {
            git push origin main | Out-Null
            Write-Host "[$stamp] wypchniete - live za ~1 min" -ForegroundColor Green
        } catch {
            Write-Host "[$stamp] push nieudany: $_" -ForegroundColor Red
        }
    }
    Start-Sleep -Seconds 3
}
