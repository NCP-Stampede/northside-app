#!/bin/bash

# Flutter Web Preview Script
# This script runs the Flutter app in a web browser.

set -e

echo "🚀 Starting Flutter app for web preview..."

# Navigate to the Flutter project directory and run for web
cd /workspaces/northside-app/northside_app && /workspaces/northside-app/flutter/bin/flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0

echo "✅ Flutter app started successfully for web!"
