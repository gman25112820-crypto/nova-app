# Fabulously Me — Nova App
<!-- Stacks on top of ~/.claude/CLAUDE.md -->

## What This Is
Flutter/Dart wellbeing app for children with chronic pain.
Targets Flutter web via CanvasKit renderer. Deployed to Vercel.

## Deploy
```
.\build_and_deploy.ps1
```
Builds Flutter web → patches CanvasKit WASM → deploys to Vercel prod.
Live: https://fabulously-me.vercel.app

## Key Files
- `lib/fab/screens/fab_home_screen.dart` — primary home screen (main file)
- `lib/main_fab.dart` — web entry point
- `pubspec.yaml` — dependencies
- `build_and_deploy.ps1` — build + deploy script
- `web/flutter_bootstrap.js` — CanvasKit patch (canvasKitBaseUrl: "canvaskit/")

## Current Architecture
- Scene fills full screen — world image with invisible tap zones
- Tap zones (GestureDetector, HitTestBehavior.opaque, stable Stack):
  - Left strip → DinoGardenScreen
  - Bottom path → CalmLagoonScreen
  - Gate (centre) → SharedGardenScreen
  - Left house → HouseInteriorScreen (chicken)
  - Right house → HouseInteriorScreen (giraffe)
- Panel: AnimatedContainer, bottom-anchored
  - Collapsed: 40px (pill handle only)
  - Open: 50% screen height
  - Header: 40px strip with pill/arrow toggle + skeleton key (🔑) → ParentDashboardScreen
  - Content: greeting → mood picker → sleep log → check-in → 8-tile LOG grid
- LOG grid: 4-column, SliverGridDelegateWithFixedCrossAxisCount, mainAxisExtent: 55

## CanvasKit Constraints — DO NOT BREAK
- `DraggableScrollableSheet` — does NOT work on Flutter web CanvasKit
- `sliding_up_panel` — does NOT work on Flutter web CanvasKit
- GestureDetectors inside `AnimatedBuilder` cancel on mobile — keep in stable Stack
- Tap reliability pattern for web:
  `MouseRegion` + `GestureDetector(HitTestBehavior.opaque)` + `Material` + `InkWell`

## Analyse Before Deploy
```
dart analyze lib/fab/screens/fab_home_screen.dart
```
Exit code 2 with only `unused_element` warnings = safe to deploy.
Any actual errors must be fixed first.

## Rules for This Project
- Run dart analyze before every build
- Never use drag-based widgets — CanvasKit doesn't support them
- All tap zones must use HitTestBehavior.opaque
- Keep GestureDetectors outside AnimatedBuilder in stable Stack positions
- flutter_bootstrap.js patch is applied by build script — do not hand-edit

## Branch
nova-fab
