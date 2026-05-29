# build_and_deploy.ps1
# Builds the Fabulously Me Flutter web app, patches flutter_bootstrap.js
# to force local CanvasKit (avoids blank canvas on Vercel), then deploys.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "==> Flutter build web (release)" -ForegroundColor Cyan
flutter build web -t lib/main_fab.dart --release

# Re-apply the canvasKitBaseUrl patch every time — flutter build regenerates
# flutter_bootstrap.js and resets it to the gstatic CDN, which fails on Vercel.
Write-Host "==> Patching flutter_bootstrap.js (local CanvasKit)" -ForegroundColor Cyan
$bs = 'build\web\flutter_bootstrap.js'
$content = Get-Content $bs -Raw

$old = '_flutter.loader.load({
  serviceWorkerSettings: {'
$new = '_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" },
  serviceWorkerSettings: {'

if ($content -notlike '*canvasKitBaseUrl*') {
    $content = $content.Replace($old, $new)
    Set-Content $bs $content -NoNewline -Encoding utf8
    Write-Host "    Patch applied." -ForegroundColor Green
} else {
    Write-Host "    Already patched, skipping." -ForegroundColor Yellow
}

Write-Host "==> Deploying to Vercel (production)" -ForegroundColor Cyan
vercel --prod --force

Write-Host "==> Done." -ForegroundColor Green
