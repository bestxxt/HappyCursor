#!/bin/bash

echo "Building HappyCursor..."

# Clean previous builds
xcodebuild clean -project HappyCursor.xcodeproj -scheme HappyCursor

# Build the project
xcodebuild -project HappyCursor.xcodeproj \
           -scheme HappyCursor \
           -configuration Release \
           -destination 'platform=macOS' \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "App location: $(find ~/Library/Developer/Xcode/DerivedData -name "HappyCursor.app" -type d | head -1)"
else
    echo "❌ Build failed!"
    exit 1
fi 