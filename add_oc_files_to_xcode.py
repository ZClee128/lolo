#!/usr/bin/env python3
"""
add_oc_files_to_xcode.py
Automatically adds Objective-C files to Xcode project and marks Swift files for deletion
"""

import os
import re
import uuid
import sys

def generate_uuid():
    """Generate a 24-character uppercase hex UUID for Xcode"""
    return uuid.uuid4().hex.upper()[:24]

def find_oc_files(base_path):
    """Find all .h and .m files in the project"""
    oc_files = []
    for root, dirs, files in os.walk(base_path):
        # Skip Pods and other non-project directories
        if 'Pods' in root or '.git' in root:
            continue
        for file in files:
            if file.endswith('.h') or file.endswith('.m'):
                rel_path = os.path.relpath(os.path.join(root, file), base_path)
                oc_files.append(rel_path)
    return oc_files

def find_swift_files(base_path):
    """Find all .swift files in the project"""
    swift_files = []
    for root, dirs, files in os.walk(base_path):
        # Skip Pods and other non-project directories
        if 'Pods' in root or '.git' in root or 'Tests' in root:
            continue
        for file in files:
            if file.endswith('.swift'):
                rel_path = os.path.relpath(os.path.join(root, file), base_path)
                swift_files.append(rel_path)
    return swift_files

def modify_pbxproj(project_path, oc_files, swift_files_to_remove):
    """Modify the project.pbxproj file to add OC files and remove Swift files"""
    
    pbxproj_path = os.path.join(project_path, 'project.pbxproj')
    
    if not os.path.exists(pbxproj_path):
        print(f"Error: {pbxproj_path} not found")
        return False
    
    with open(pbxproj_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # This is a simplified approach - manual review may be needed
    print(f"Found project file: {pbxproj_path}")
    print(f"Found {len(oc_files)} Objective-C files to add")
    print(f"Found {len(swift_files_to_remove)} Swift files to potentially remove")
    
    print("\nObjective-C files to add:")
    for f in oc_files:
        print(f"  - {f}")
    
    print("\nSwift files that should be removed:")
    for f in swift_files_to_remove:
        print(f"  - {f}")
    
    print("\nNote: Automatic project.pb xproj modification is complex.")
    print("Please add files manually in Xcode or use xcodeproj Ruby gem.")
    print("\nTo add files manually:")
    print("1. Open lolo.xcodeproj in Xcode")
    print("2. Right-click on the project navigator and select 'Add Files to lolo...'")
    print("3. Select all the .h and .m files listed above")
    print("4. Make sure 'Copy items if needed' is checked")
    print("5. Make sure the target 'lolo' is selected")
    print("6. Delete all Swift files from the project")
    
    return True

if __name__ == '__main__':
    base_path = os.path.dirname(os.path.abspath(__file__))
    project_path = os.path.join(base_path, 'lolo.xcodeproj')
    
    # Find lolo directory
    lolo_dir = os.path.join(base_path, 'lolo')
    
    if not os.path.exists(lolo_dir):
        print(f"Error: {lolo_dir} not found")
        sys.exit(1)
    
    oc_files = find_oc_files(lolo_dir)
    swift_files = find_swift_files(lolo_dir)
    
    modify_pbxproj(project_path, oc_files, swift_files)
    
    print("\n✅ Analysis complete!")
    print("\nNext steps:")
    print("1. Add all .h and .m files to Xcode project manually")
    print("2. Delete all .swift files from Xcode project")
    print("3. Build and test the project")
