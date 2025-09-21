# 🚀 Quick Start Deployment Guide

## One-Command Deployment

### Windows
```cmd
setup.bat && deploy.bat
```

### Linux/macOS
```bash
chmod +x setup.sh deploy.sh && ./setup.sh && ./deploy.sh
```

## Prerequisites Check

Before deploying, ensure you have:
- [ ] Node.js (v18+)
- [ ] Flutter (v3.24.3+)
- [ ] Firebase CLI access
- [ ] Internet connection

## Deployment Steps

1. **Setup Environment**
   ```bash
   # Windows
   setup.bat
   
   # Linux/macOS
   ./setup.sh
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Deploy**
   ```bash
   # Windows
   deploy.bat
   
   # Linux/macOS
   ./deploy.sh
   ```

4. **Verify Deployment**
   - Visit: https://calcium-ratio-472014-r9.web.app
   - Test login functionality
   - Test chat features

## Automated Deployment

Push to main branch for automatic deployment:
```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

## Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | `flutter clean && flutter pub get` |
| Permission denied | `firebase login` |
| Dependencies error | `flutter pub upgrade` |
| CI/CD fails | Check GitHub secrets |

## Support Links

- 📖 [Full Documentation](./DEPLOYMENT.md)
- 🔧 [Firebase Console](https://console.firebase.google.com/project/calcium-ratio-472014-r9)
- 🌐 [Live App](https://calcium-ratio-472014-r9.web.app)

---
*For detailed instructions, see [DEPLOYMENT.md](./DEPLOYMENT.md)*