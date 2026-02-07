#!/bin/bash
# delete_swift_files.sh
# Script to delete all Swift files from the project

echo "🗑️  Deleting Swift files from project..."

cd "$(dirname "$0")"

# Find and delete all .swift files in lolo directory (excluding Pods and build folders)
find lolo -name "*.swift" -type f ! -path "*/Pods/*" ! -path "*/build/*" -print -delete

echo "✅ Done! All Swift files have been deleted."
echo ""
echo "Next steps:"
echo "1. Also delete Swift files from the Xcode project navigator manually"
echo "2. Update Info.plist if needed"
echo "3. Build and test the project"
