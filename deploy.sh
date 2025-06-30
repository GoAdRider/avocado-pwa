#!/bin/bash

# Flutter Web to GitHub Pages Deployment Script
# This script helps build and prepare the Flutter web app for GitHub Pages

echo "🚀 Starting Flutter Web deployment build..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Run build_runner to generate Hive type adapters
echo "🔧 Running build_runner to generate code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build Flutter web with correct base href for GitHub Pages
echo "🏗️ Building Flutter web app..."
flutter build web --release --base-href "/avocado-pwa/"

echo "✅ Build completed successfully!"
echo "📁 Built files are in: build/web/"
echo ""
echo "🌐 To deploy to GitHub Pages:"
echo "1. Push this repository to GitHub (repository name: avocado-pwa)"
echo "2. Go to Settings > Pages in your GitHub repository"
echo "3. Select 'GitHub Actions' as the source"
echo "4. The workflow will automatically deploy when you push to main branch"
echo ""
echo "📱 Your PWA will be available at: https://[your-username].github.io/avocado-pwa/"