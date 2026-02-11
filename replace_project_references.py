#!/usr/bin/env python3
import os

project_path = 'lolo.xcodeproj/project.pbxproj'

with open(project_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replacements
replacements = {
    'StoreManager.h': 'LoloDataConnector.h',
    'StoreManager.m': 'LoloDataConnector.m',
    'CoinStoreViewController.h': 'LoloWalletDetailView.h',
    'CoinStoreViewController.m': 'LoloWalletDetailView.m',
    # Also replace the comments that might just say the class name without extension if any (usually pbxproj includes extension in comments for files)
}

new_content = content
for old, new in replacements.items():
    new_content = new_content.replace(old, new)

if content == new_content:
    print("No changes make.")
else:
    with open(project_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Project file updated successfully.")
