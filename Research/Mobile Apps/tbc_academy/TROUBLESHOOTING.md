# 🔧 Troubleshooting Guide

## Build Issues

### Issue 1: Docker Build Fails with SSL Error

**Error:**
```
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

**Solution:**
Already fixed in new Dockerfile! If you still encounter this:

```bash
# Rebuild without cache
docker build --no-cache -f .docker/tbs-academy-build/Dockerfile -t tbc-build:1.0 .

# Or manually update certs in running container
docker exec -it <container-id> update-ca-certificates
```

---

### Issue 2: "Permission Denied" with Docker

**Error:**
```
permission denied while trying to connect to the Docker daemon
```

**Solution:**
```bash
# Windows: Start Docker Desktop
# If already running, restart it:
# 1. Right-click Docker icon in taskbar
# 2. Click "Quit Docker Desktop"
# 3. Start Docker Desktop again

# Verify Docker is running
docker ps
```

---

### Issue 3: Build Takes Too Long (> 30 minutes)

**Cause:** First build downloads large SDKs

**Solution:**
```bash
# This is NORMAL for first build (15-20 minutes)
# Subsequent builds use cache and are faster (8-10 minutes)

# Monitor progress
docker logs -f <container_id>

# Or check in real-time
docker stats
```

---

### Issue 4: "No Space Left on Device"

**Error:**
```
ERROR: failed to allocate memory
no space left on device
```

**Solution:**
```bash
# Check Docker disk usage
docker system df

# Clean up unused images
docker image prune -a

# Clean up unused containers
docker container prune

# Clean up volumes
docker volume prune

# Nuclear option (removes everything)
docker system prune -a --volumes
```

---

### Issue 5: Build Stops Unexpectedly

**Cause:** Container running out of memory

**Solution:**
```bash
# Increase Docker memory allocation
# Docker Desktop > Settings > Resources > Memory
# Increase to 6-8 GB

# Or use limits in docker-compose
# Edit docker-compose.yml:
services:
  tbc-build:
    deploy:
      resources:
        limits:
          memory: 6G
        reservations:
          memory: 4G
```

---

### Issue 6: "Flutter: command not found"

**Error:**
```
flutter: command not found
```

**Solution:**
```bash
# Dockerfile already handles this
# If building manually:

# Check Flutter path
echo $PATH

# Verify Flutter installation in container
docker exec <container-id> /opt/flutter/bin/flutter --version

# Rebuild image
docker build --no-cache -f .docker/tbs-academy-build/Dockerfile -t tbc-build:1.0 .
```

---

### Issue 7: Gradle Build Failure

**Error:**
```
Could not determine Java's version from ...
Gradle task bundleRelease failed with exit code 1
```

**Solution:**
```bash
# Dockerfile handles this, but if issues persist:

# Check Java version in container
docker exec <container-id> java -version

# Should output Java 17
# If not, rebuild with no cache
docker build --no-cache -f .docker/tbs-academy-build/Dockerfile .

# Or manually check in Dockerfile
# Ensure: openjdk-17-jdk is installed
```

---

### Issue 8: Network Issues in Docker

**Error:**
```
Failed to connect to github.com
Network is unreachable
```

**Solution:**
```bash
# Docker network issue
# Check Docker network
docker network ls

# Verify internet connection
docker run -it ubuntu:22.04 bash
# Inside container: ping google.com

# Solution: Restart Docker
# Docker Desktop > Menu > Restart Docker

# Or rebuild on different network
```

---

## Android Build Issues

### Issue 9: "ANDROID_HOME Not Set"

**Error:**
```
ANDROID_HOME is not set
```

**Solution:**
Dockerfile sets this automatically:
```dockerfile
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
```

If building locally, set manually:
```bash
# Windows
set ANDROID_HOME=C:\Android\sdk
set PATH=%PATH%;%ANDROID_HOME%\platform-tools

# macOS/Linux
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

---

### Issue 10: "Gradle Daemon Timeout"

**Error:**
```
Gradle daemon disappeared unexpectedly
```

**Solution:**
```bash
# Kill all Gradle daemons
./gradlew --stop

# Or in Docker
docker run -it --entrypoint bash tbc-build:1.0
# Inside: ./gradlew --stop
```

---

### Issue 11: "Keystore Not Found"

**Error:**
```
Could not load keystore file ...
```

**Solution:**
For local development only (Docker handles release):
```bash
# Create keystore (one-time)
keytool -genkey -v -keystore ~/.android/debug.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 -alias android

# For Play Store (requires proper setup)
# See FLUTTER_DOCKER_BUILD_GUIDE.md
```

---

## Output Issues

### Issue 12: No Output Files Generated

**Cause:** Build succeeded but artifacts not found

**Solution:**
```bash
# Check volume mapping
# In docker-compose.yml or docker run command
# Should have: -v $(pwd)/build:/app/build

# Verify outputs exist in container
docker exec <container-id> ls -la /app/build/app/outputs/

# Copy from container if needed
docker cp <container-id>:/app/build ./build-output
```

---

### Issue 13: APK Size Too Large (> 100MB)

**Cause:** Debug build or unoptimized assets

**Solution:**
```bash
# Ensure release build (should be in Dockerfile)
flutter build apk --release

# Check for unused dependencies
flutter pub outdated

# Remove unused packages from pubspec.yaml

# Rebuild
docker-compose build --no-cache tbc-build
docker-compose up tbc-build
```

---

### Issue 14: App Crashes on Launch

**Cause:** Supabase initialization or dependencies

**Solution:**
```bash
# Check initialization
# In lib/main.dart:
SupabaseService.initialize() // Should succeed

# Check logs
adb logcat | grep "tbc_academy\|supabase\|flutter"

# Or use Flutter DevTools
flutter run
# Open DevTools
```

---

## Testing Issues

### Issue 15: Tests Won't Run in Docker

**Error:**
```
flutter test: command not found
```

**Solution:**
```bash
# Use test Dockerfile
docker build -f .docker/tbc-academy-test/Dockerfile \
  -t tbc-test:1.0 .

docker run -v $(pwd)/coverage:/app/coverage tbc-test:1.0

# Or Docker Compose
docker-compose up tbc-test
```

---

## Debugging

### Enable Verbose Output

```bash
# Docker build verbose
docker build --progress=plain \
  -f .docker/tbs-academy-build/Dockerfile .

# Flutter build verbose (local)
flutter build apk --release -v

# Gradle verbose (in Docker)
# Add to Dockerfile:
RUN /opt/flutter/bin/flutter build apk --release -v
```

### Interactive Debugging

```bash
# Enter running container shell
docker exec -it <container-id> /bin/bash

# Check files
ls -la /app/build/

# Run commands manually
/opt/flutter/bin/flutter --version

# Check environment
env | grep ANDROID
env | grep FLUTTER
env | grep JAVA
```

### View Detailed Logs

```bash
# Save build logs
docker build -f .docker/tbs-academy-build/Dockerfile . 2>&1 | tee build.log

# Search logs
grep -i "error" build.log
grep -i "warning" build.log

# View specific section
grep -A 5 "flutter build apk" build.log
```

---

## Performance Issues

### Issue 16: Build Extremely Slow

**Checks:**
```bash
# Check Docker resources
docker stats

# Check disk I/O
# Open Docker Dashboard > Resources tab

# Solution: Allocate more resources
# Docker Settings > Resources > Increase CPU/Memory
```

### Issue 17: High CPU Usage During Build

**Solution:**
```bash
# This is normal during compilation
# Expected: CPU at 80-100% during build

# If stuck:
docker logs -f <container-id>
# Look for last message to find where it's stuck

# Can safely cancel with Ctrl+C
```

---

## Deployment Issues

### Issue 18: APK Won't Install

**Error:**
```
adb: command not found
// or
Installation failed: INSTALL_FAILED_VERSION_DOWNGRADE
```

**Solution:**
```bash
# Install Android Platform Tools
# From: https://developer.android.com/tools/releases/platform-tools

# For version downgrade:
# Uninstall previous version first
adb uninstall com.thebraincord.tbc_academy

# Then install
adb install build/app/outputs/flutter-app-release.apk
```

---

### Issue 19: Play Store Upload Fails

**Error:**
```
Build doesn't include release signing certificate
```

**Solution:**
See FLUTTER_DOCKER_BUILD_GUIDE.md for signing setup

---

## Prevention Tips

1. **Always check logs:** `docker logs -f <container-id>`
2. **Use --no-cache first time:** Ensures clean build
3. **Monitor resources:** Keep Docker Resources under 80%
4. **Test locally first:** Before Docker build
5. **Keep images updated:** `docker pull ubuntu:22.04`
6. **Document errors:** Record issue + solution for team
7. **Use version tags:** Never use `latest` in production

---

## Getting Help

If issue not listed here:

1. **Check logs:**
   ```bash
   docker logs -f <container-id>
   ```

2. **Search Flutter docs:**
   - https://flutter.dev/docs

3. **Search Android docs:**
   - https://developer.android.com

4. **Search Stack Overflow:**
   - Tag: flutter, docker, android

5. **Check project issues:**
   - GitHub repo issues

---

## Emergency Cleanup

If everything is broken:

```bash
# Remove all Docker containers
docker rm -f $(docker ps -aq)

# Remove all Docker images
docker rmi -f $(docker images -q)

# Remove all Docker volumes
docker volume rm $(docker volume ls -q)

# Remove all networks
docker network prune -f

# Restart Docker
# Docker Desktop > Menu > Quit Docker Desktop
# Then restart Docker Desktop

# Start fresh
docker build -f .docker/tbs-academy-build/Dockerfile -t tbc-build:1.0 .
```

---

## Success Indicators

✅ **Build succeeded when:**
- No error messages at end of build log
- Output files exist: `build/app/outputs/*.apk`
- Container exits with code 0
- APK size is 50-80MB

✅ **App works when:**
- Installs without errors
- Launches on device
- Shows TBC Academy splash screen
- No crashes in first 10 seconds

---

## Additional Resources

- [Flutter Troubleshooting](https://flutter.dev/docs/testing/troubleshooting)
- [Android Build Docs](https://developer.android.com/studio/build)
- [Docker Troubleshooting](https://docs.docker.com/config/containers/troubleshoot/)
- [Gradle Docs](https://gradle.org/guides/)

