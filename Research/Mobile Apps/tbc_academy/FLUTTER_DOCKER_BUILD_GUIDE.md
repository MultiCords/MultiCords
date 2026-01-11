# Flutter TBC Academy - Docker Build Guide

## Project Analysis

### 📊 Project Overview
- **Project Name:** TBC Academy
- **Type:** Flutter Mobile App (Android)
- **Target:** Medical entrance exam preparation platform
- **Key Dependencies:**
  - Flutter 3.6.0+
  - Dart 3.6.0+
  - Android SDK 34
  - OpenJDK 17

### 🎯 Key Features Detected
- ✅ Supabase integration (backend + authentication)
- ✅ Responsive design with Sizer package
- ✅ SVG support with flutter_svg
- ✅ Video playback with youtube_player_flutter
- ✅ News feed with fl_chart
- ✅ Custom UI widgets and theming
- ✅ Local storage with shared_preferences

### 📦 Critical Dependencies
```yaml
sizer: ^2.0.15              # Responsive design
flutter_svg: ^2.0.9        # SVG icons
google_fonts: ^6.1.0       # Typography
supabase_flutter: any      # Backend & Auth
dio: ^5.8.0               # HTTP client
cached_network_image: ^3.3.1  # Image caching
```

---

## Docker Setup Instructions

### Prerequisites
- Docker Desktop installed and running
- Git installed
- 10GB+ free disk space (for Docker images)

### Project Structure
```
.docker/
├── tbs-academy-build/    # Build Docker image
│   └── Dockerfile       # APK/App Bundle builder
└── tbc-academy-test/    # Test Docker image
    └── Dockerfile       # Testing & analysis
```

---

## Building with Docker

### Option 1: Using Docker Compose (Recommended)

#### Build APK and App Bundle
```bash
# Navigate to project directory
cd c:\TheBrainCord\tbc_academy

# Build the Docker image
docker-compose build tbc-build

# Run the build
docker-compose up tbc-build

# Outputs will be in ./build/outputs/
```

#### Run Tests and Code Analysis
```bash
# Build test image
docker-compose build tbc-test

# Run tests
docker-compose up tbc-test

# Coverage reports in ./coverage/
```

---

### Option 2: Using Docker CLI

#### Build APK
```bash
# Build the image
docker build -f .docker/tbs-academy-build/Dockerfile \
  -t thebraincordservices/tbc-academy-build:1.0 .

# Run build
docker run -v $(pwd)/build:/app/build \
  thebraincordservices/tbc-academy-build:1.0
```

#### Build App Bundle (for Play Store)
```bash
docker run -v $(pwd)/build:/app/build \
  thebraincordservices/tbc-academy-build:1.0 \
  /opt/flutter/bin/flutter build appbundle --release
```

#### Run Tests
```bash
docker build -f .docker/tbc-academy-test/Dockerfile \
  -t thebraincordservices/tbc-academy-test:1.0 .

docker run -v $(pwd)/coverage:/app/coverage \
  thebraincordservices/tbc-academy-test:1.0
```

---

## Output Artifacts

### Build Outputs
After successful build, you'll find:

```
build/
├── app/
│   ├── outputs/
│   │   └── flutter-app-release.apk    ← Android APK
│   └── bundle/
│       └── release/
│           └── app.aab              ← App Bundle (Play Store)
└── flutter_assets/
```

### Test Outputs
```
coverage/
├── lcov.info              ← Coverage report
└── coverage.html          ← HTML coverage report
```

---

## Troubleshooting

### Issue: SSL Certificate Error
**Error:** `curl: (60) SSL certificate problem`
**Solution:** Already fixed in latest Dockerfile
- Uses `ubuntu:22.04` with updated SSL certs
- Runs `update-ca-certificates`

### Issue: Permission Denied
**Error:** `permission denied while trying to connect to Docker daemon`
**Solution:**
```bash
# Windows: Ensure Docker Desktop is running
# Check Docker status
docker ps

# If Docker Desktop isn't running, start it from Start Menu
```

### Issue: Disk Space
**Error:** `no space left on device`
**Solution:**
```bash
# Clean up Docker resources
docker system prune -a

# Remove old images
docker image prune -a
```

### Issue: Build Takes Too Long
**Note:** First build takes 15-20 minutes (downloading SDKs)
- Subsequent builds are faster (10-15 minutes)
- Use Docker cache: `docker build --cache-from ...`

### Issue: Gradle Daemon Timeout
**Solution:** Already handled in Dockerfile
- Uses non-root user for Flutter commands
- Proper environment variable setup

---

## Best Practices

### 1. **Pre-build Checks**
```bash
# Verify Flutter dependencies
flutter pub get

# Run analyzer locally first
flutter analyze

# Check pubspec.yaml for issues
flutter pub upgrade --dry-run
```

### 2. **Version Management**
```bash
# Track build versions
docker build -f .docker/tbs-academy-build/Dockerfile \
  -t thebraincordservices/tbc-academy-build:1.0 .

docker build -f .docker/tbs-academy-build/Dockerfile \
  -t thebraincordservices/tbc-academy-build:1.1 .

docker build -f .docker/tbs-academy-build/Dockerfile \
  -t thebraincordservices/tbc-academy-build:latest .
```

### 3. **Local Development**
For faster local testing, install Flutter locally:
```bash
# Download Flutter: https://flutter.dev/docs/get-started/install
# Then build locally
flutter build apk --release
```

### 4. **CI/CD Integration**
Docker builds are perfect for CI/CD pipelines:
```bash
# GitHub Actions / Jenkins / GitLab CI
docker build -f .docker/tbs-academy-build/Dockerfile \
  -t ghcr.io/thebraincord/tbc-academy:$VERSION .

docker push ghcr.io/thebraincord/tbc-academy:$VERSION
```

---

## Key Dockerfile Improvements

✅ **Ubuntu 22.04** - Newer base with better SSL support
✅ **Java 17** - Latest LTS version
✅ **Android SDK 34** - Latest Android API level
✅ **Non-root user** - Better security and Flutter compatibility
✅ **Precache Flutter** - Faster builds
✅ **NDK 26.1** - Latest NDK for native code
✅ **Proper PATH setup** - All tools accessible
✅ **Volume mounts** - Easy artifact extraction

---

## Push to Docker Hub

Once build succeeds:

```bash
# Login to Docker Hub
docker login

# Tag image
docker tag thebraincordservices/tbc-academy-build:1.0 \
  thebraincordservices/tbc-academy-build:latest

# Push to Docker Hub
docker push thebraincordservices/tbc-academy-build:1.0
docker push thebraincordservices/tbc-academy-build:latest

# Pull from anywhere
docker pull thebraincordservices/tbc-academy-build:1.0
docker run thebraincordservices/tbc-academy-build:1.0
```

---

## Development Workflow

### Local Development (Faster)
```bash
# Install locally
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

### Docker for CI/CD
```bash
# In GitHub Actions / Jenkins
docker build -f .docker/tbs-academy-build/Dockerfile -t build .
docker run -v ./build:/app/build build
```

### Testing Before Push
```bash
# Run tests in Docker
docker-compose up tbc-test

# Check coverage
open coverage/coverage.html
```

---

## Environment Variables

### Build-Time Env Vars
```dockerfile
FLUTTER_HOME=/opt/flutter
ANDROID_HOME=/opt/android-sdk
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

### Runtime Env Vars (for container)
```bash
FLUTTER_VERSION=latest  # or specific version
ANDROID_SDK_LEVEL=34    # Target API level
```

---

## Monitoring Build Progress

### View Dockerfile Layers
```bash
docker history thebraincordservices/tbc-academy-build:1.0
```

### View Layer Size
```bash
docker image ls --no-trunc | grep tbc-academy
```

### Stream build output
```bash
docker build --progress=plain -f .docker/tbs-academy-build/Dockerfile .
```

---

## Next Steps

1. ✅ Run first build
   ```bash
   docker-compose build tbc-build
   docker-compose up tbc-build
   ```

2. ✅ Verify outputs
   ```bash
   ls -la build/outputs/
   ```

3. ✅ Test the APK
   - Use Android emulator or physical device
   - Install: `adb install build/app/outputs/flutter-app-release.apk`

4. ✅ Set up CI/CD
   - Add to GitHub Actions
   - Automate builds on every push

5. ✅ Deploy to Play Store
   - Use App Bundle: `build/app/bundle/release/app.aab`

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Docker Flutter Guide](https://flutter.dev/docs/deployment/cd)
- [Android SDK Documentation](https://developer.android.com/docs)
- [Supabase Flutter](https://supabase.com/docs/reference/flutter/introduction)

---

## Support

For issues:
1. Check logs: `docker logs <container_id>`
2. Run analyzer locally: `flutter analyze`
3. Verify pubspec.yaml: `flutter pub get`
4. Check disk space: `docker system df`

