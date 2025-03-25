#!/bin/bash

# Clean the build directory
rm -rf build/web

# Build the web app with optimizations
flutter build web --release --web-renderer html

# Optimize images (requires ImageMagick)
if command -v convert &> /dev/null; then
    find build/web -type f -name "*.png" -exec convert {} -strip {} \;
    find build/web -type f -name "*.jpg" -exec convert {} -strip {} \;
fi

# Compress JavaScript and CSS files
if command -v uglifyjs &> /dev/null; then
    find build/web -type f -name "*.js" -exec uglifyjs {} -o {} -c -m \;
fi

if command -v cleancss &> /dev/null; then
    find build/web -type f -name "*.css" -exec cleancss -o {} {} \;
fi

echo "Web build completed and optimized!" 