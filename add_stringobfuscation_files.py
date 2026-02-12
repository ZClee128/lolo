#!/usr/bin/env python3
# add_stringobfuscation_files.py
# Direct modification of Xcode project file to add StringObfuscation files

import uuid
import re

PROJECT_FILE = 'lolo.xcodeproj/project.pbxproj'

# Generate UUIDs for the new files
string_obf_h_uuid = uuid.uuid4().hex[:24].upper()
string_obf_m_uuid = uuid.uuid4().hex[:24].upper()
string_obf_m_build_uuid = uuid.uuid4().hex[:24].upper()

print(f"📦 Adding StringObfuscation files to Xcode project...")
print(f"   StringObfuscation.h UUID: {string_obf_h_uuid}")
print(f"   StringObfuscation.m UUID: {string_obf_m_uuid}")

# Read the project file
with open(PROJECT_FILE, 'r', encoding='utf-8') as f:
    content = f.read()

# Check if files are already added
if 'StringObfuscation.h' in content:
    print("✓ StringObfuscation files already in project")
    exit(0)

# Find the Utils group
utils_group_match = re.search(r'(/\* Utils \*/.*?children = \()(.*?)(\);)', content, re.DOTALL)
if not utils_group_match:
    print("❌ Could not find Utils group")
    exit(1)

utils_group_uuid = re.search(r'([A-F0-9]{24}) /\* Utils \*/', content).group(1)
print(f"   Utils group UUID: {utils_group_uuid}")

# Add file references to Utils group children
utils_children = utils_group_match.group(2)
new_utils_children = utils_children.rstrip() + f"\n\t\t\t\t{string_obf_h_uuid} /* StringObfuscation.h */,\n\t\t\t\t{string_obf_m_uuid} /* StringObfuscation.m */,"

content = content.replace(
    utils_group_match.group(0),
    utils_group_match.group(1) + new_utils_children + utils_group_match.group(3)
)

# Add PBXFileReference entries
file_ref_section = re.search(r'(/\* Begin PBXFileReference section \*/)(.*?)(/\* End PBXFileReference section \*/)', content, re.DOTALL)
if file_ref_section:
    new_file_refs = f"""
\t\t{string_obf_h_uuid} /* StringObfuscation.h */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = StringObfuscation.h; sourceTree = "<group>"; }};
\t\t{string_obf_m_uuid} /* StringObfuscation.m */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = StringObfuscation.m; sourceTree = "<group>"; }};"""
    
    content = content.replace(
        file_ref_section.group(3),
        new_file_refs + "\n" + file_ref_section.group(3)
    )

# Add .m file to PBXSourcesBuildPhase
sources_build_phase = re.search(r'(/\* Sources \*/.*?files = \()(.*?)(\);.*?/\* Sources \*/)', content, re.DOTALL)
if sources_build_phase:
    sources_files = sources_build_phase.group(2)
    new_sources_files = sources_files.rstrip() + f"\n\t\t\t\t{string_obf_m_build_uuid} /* StringObfuscation.m in Sources */,"
    
    content = content.replace(
        sources_build_phase.group(0),
        sources_build_phase.group(1) + new_sources_files + sources_build_phase.group(3)
    )
    
    # Add PBXBuildFile entry
    build_file_section = re.search(r'(/\* Begin PBXBuildFile section \*/)(.*?)(/\* End PBXBuildFile section \*/)', content, re.DOTALL)
    if build_file_section:
        new_build_file = f"\n\t\t{string_obf_m_build_uuid} /* StringObfuscation.m in Sources */ = {{isa = PBXBuildFile; fileRef = {string_obf_m_uuid} /* StringObfuscation.m */; }};"
        
        content = content.replace(
            build_file_section.group(3),
            new_build_file + "\n" + build_file_section.group(3)
        )

# Write back the modified project file
with open(PROJECT_FILE, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Successfully added StringObfuscation files to Xcode project!")
print("\nNext steps:")
print("1. Open the project in Xcode")
print("2. Verify that StringObfuscation.h and .m appear in the Utils group")
print("3. Build the project")
