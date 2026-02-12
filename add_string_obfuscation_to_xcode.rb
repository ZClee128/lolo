#!/usr/bin/env ruby
# add_string_obfuscation_to_xcode.rb
# Purpose: Add StringObfuscation files to Xcode project

require 'xcodeproj'

PROJECT_PATH = 'lolo.xcodeproj'
TARGET_NAME = 'lolo'
UTILS_GROUP_PATH = 'lolo/Utils'

puts "📦 Adding StringObfuscation files to Xcode project..."

# Open the project
project = Xcodeproj::Project.open(PROJECT_PATH)

# Find the main target
target = project.targets.find { |t| t.name == TARGET_NAME }
unless target
  puts "❌ Target '#{TARGET_NAME}' not found!"
  exit 1
end

# Find or create Utils group
utils_group = project.main_group.find_subpath(UTILS_GROUP_PATH, true)

# Files to add
files_to_add = [
  { path: 'lolo/Utils/StringObfuscation.h', type: 'header' },
  { path: 'lolo/Utils/StringObfuscation.m', type: 'source' }
]

added_count = 0

files_to_add.each do |file_info|
  file_path = file_info[:path]
  file_name = File.basename(file_path)
  
  unless File.exist?(file_path)
    puts "⚠️  File not found: #{file_path}"
    next
  end
  
  # Check if file is already in project
  existing = utils_group.files.find { |f| f.path == file_name }
  if existing
    puts "ℹ️  Already in project: #{file_name}"
    next
  end
  
  # Add file reference
  file_ref = utils_group.new_reference(file_path)
  
  # Add to build phase if it's a source file
  if file_info[:type] == 'source'
    target.source_build_phase.add_file_reference(file_ref)
  end
  
  added_count += 1
  puts "✅ Added: #{file_name}"
end

# Save the project
if added_count > 0
  project.save
  puts "\n🎉 Successfully added #{added_count} files to Xcode project!"
else
  puts "\n✓ All files already in project, nothing to add."
end
