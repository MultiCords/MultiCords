# 🚀 Quick Reference: Build Commands

## Start Building Now

```bash
# Navigate to project
cd c:\TheBrainCord\tbc_academy

# Option 1: Docker Compose (Recommended)
docker-compose build tbc-build
docker-compose up tbc-build

# Option 2: Docker CLI
docker build -f .docker/tbs-academy-build/Dockerfile -t tbc-build:1.0 .
docker run -v $(pwd)/build:/app/build tbc-build:1.0

# Option 3: Local (Fastest for development)
flutter pub get
flutter build apk --release
```

---

## 📁 Important Paths

| What | Path |
|------|------|
| Build Dockerfile | `.docker/tbs-academy-build/Dockerfile` |
| Test Dockerfile | `.docker/tbc-academy-test/Dockerfile` |
| Docker Compose | `docker-compose.yml` |
| Project Config | `pubspec.yaml` |
| Main Entry | `lib/main.dart` |
| Output APK | `build/app/outputs/flutter-app-release.apk` |
| Output Bundle | `build/app/bundle/release/app.aab` |

---

## 🔍 Verify Build

```bash
# Check output files
ls -la build/app/outputs/

# Check APK size
ls -lh build/app/outputs/*.apk

# List outputs
dir build\app\outputs\
```

---

## 📱 Test on Device

```bash
# Connect Android device via USB
# Enable USB Debugging on device

# Install APK
adb install -r build/app/outputs/flutter-app-release.apk

# Or via Flutter
flutter install
```

---

## 🐳 Docker Commands

```bash
# View images
docker images | grep tbc

# Remove image
docker rmi thebraincordservices/tbc-academy-build:1.0

# Clean up
docker system prune -a

# View build logs
docker build -f .docker/tbs-academy-build/Dockerfile . 2>&1 | tail -50
```

---

## 📊 Troubleshooting

```bash
# Check Docker status
docker ps
docker info

# Increase build verbosity
docker build --progress=plain -f .docker/tbs-academy-build/Dockerfile .

# Enter container shell
docker run -it -v $(pwd):/app tbc-build:1.0 /bin/bash

# View Dockerfile
cat .docker/tbs-academy-build/Dockerfile
```

---

## 📦 Push to Docker Hub

```bash
# Login
docker login

# Tag
docker tag tbc-build:1.0 thebraincordservices/tbc-academy-build:1.0

# Push
docker push thebraincordservices/tbc-academy-build:1.0

# Pull from anywhere
docker pull thebraincordservices/tbc-academy-build:1.0
```

---

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Flutter App

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -f .docker/tbs-academy-build/Dockerfile -t tbc-build:1.0 .
      - name: Run build
        run: docker run -v $(pwd)/build:/app/build tbc-build:1.0
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: apk
          path: build/app/outputs/
```

---

## ⏱️ Expected Times

| Step | Time |
|------|------|
| Docker image download | ~1 min |
| Dependencies install | ~5 min |
| Android SDK setup | ~3 min |
| Flutter setup | ~5 min |
| Code compilation | ~5 min |
| **First build total** | **15-20 min** |
| **Subsequent builds** | **8-10 min** |

---

## 💾 Disk Space

```bash
# Check Docker disk usage
docker system df

# Clean up space
docker system prune -a

# Required space
- Base image: 2GB
- Android SDK: 5GB
- Build artifacts: 1GB
- **Total: 8-10GB**
```

---

## 🎯 Success Indicators

✅ Build succeeded when you see:
```
#12 [11/12] RUN /opt/flutter/bin/flutter build appbundle --release 2>&1
#12 ...
#12 Running Gradle task 'bundleRelease'...
#12 ...
#12 ✓ Built .../build/app/bundle/release/app.aab
```

✅ Output files exist:
```
build/app/outputs/flutter-app-release.apk
build/app/bundle/release/app.aab
```

---

## 🚨 Common Issues

**Issue:** `docker: command not found`
- **Fix:** Docker not installed or not in PATH

**Issue:** `Failed to build image`
- **Fix:** Insufficient disk space (run `docker system prune -a`)

**Issue:** `SSL certificate problem`
- **Fix:** Already fixed in new Dockerfile

**Issue:** `Permission denied`
- **Fix:** Start Docker Desktop

**Issue:** Build very slow
- **Fix:** Normal for first build (~20 min), next builds faster

---

## 🔗 Resources

- [Flutter Build Docs](https://flutter.dev/docs/deployment/android)
- [Docker Docs](https://docs.docker.com/)
- [GitHub Actions CI/CD](https://docs.github.com/en/actions)
- [Supabase Docs](https://supabase.com/docs)

---

## 📞 Quick Help

```bash
# Rebuild without cache
docker build --no-cache -f .docker/tbs-academy-build/Dockerfile .

# Build with custom tag
docker build -f .docker/tbs-academy-build/Dockerfile -t my-custom-tag:latest .

# View intermediate files
docker history thebraincordservices/tbc-academy-build:1.0
```

---

**Ready to build?** Run: `docker-compose up tbc-build`

