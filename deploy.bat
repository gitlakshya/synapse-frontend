@echo off
echo Starting Firebase deployment process...

echo.
echo Step 1: Installing dependencies...
call flutter pub get

echo.
echo Step 2: Building web app for production...
call flutter build web --release

echo.
echo Step 3: Deploying to Firebase Hosting...
call firebase deploy --only hosting

echo.
echo Deployment completed!
echo Your app is now live at: https://your-project-id.web.app
pause