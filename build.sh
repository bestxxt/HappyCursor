#!/bin/bash

echo "Building HappyCursor..."

# 检查参数
BUILD_TYPE=${1:-arm64}

case $BUILD_TYPE in
    "arm64")
        echo "🍎 Building ARM64 (Apple Silicon) only..."
        ARCHS="arm64"
        ONLY_ACTIVE_ARCH="YES"
        OUTPUT_NAME="HappyCursor-arm64"
        ;;
    "x86_64")
        echo "💻 Building Intel (x86_64) only..."
        ARCHS="x86_64"
        ONLY_ACTIVE_ARCH="YES"
        OUTPUT_NAME="HappyCursor-x86_64"
        ;;
    *)
        echo "❌ Invalid build type. Use: arm64 or x86_64"
        echo "Usage: ./build.sh [arm64|x86_64]"
        echo "Default: arm64 (Apple Silicon)"
        exit 1
        ;;
esac

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean -project HappyCursor.xcodeproj -scheme HappyCursor

# Build the project
echo "🔨 Building project..."
xcodebuild -project HappyCursor.xcodeproj \
           -scheme HappyCursor \
           -configuration Release \
           -destination 'platform=macOS' \
           ONLY_ACTIVE_ARCH=$ONLY_ACTIVE_ARCH \
           ARCHS="$ARCHS" \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Find the built app
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "HappyCursor.app" -type d | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "📱 App location: $APP_PATH"
        
        # Check architecture
        echo "🔍 Checking architecture..."
        file "$APP_PATH/Contents/MacOS/HappyCursor"
        
        # Show app size
        echo "📊 App size:"
        du -sh "$APP_PATH"
    else
        echo "⚠️  Could not find built app"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi 