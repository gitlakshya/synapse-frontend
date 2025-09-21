@echo off
set ENV=%1
if "%ENV%"=="" set ENV=development

echo Generating config for %ENV% environment...
dart run tool/config_generator.dart %ENV%

echo Building Flutter web app...
flutter build web --release

echo Build complete!