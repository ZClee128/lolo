#!/usr/bin/env python3
# fix_xcode_project.py
# Fix syntax error in project.pbxproj

PROJECT_FILE = 'lolo.xcodeproj/project.pbxproj'

print("🔧 Fixing Xcode project file...")

with open(PROJECT_FILE, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the syntax error: remove the extra ),
content = content.replace('StringObfuscation.m */,);', 'StringObfuscation.m */,')
content = content.replace('StringObfuscation.m in Sources */,);', 'StringObfuscation.m in Sources */,')

with open(PROJECT_FILE, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Fixed project file syntax")
