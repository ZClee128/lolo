#!/usr/bin/env ruby
# add_junk_to_xcode.rb
# Purpose: Add auto-generated junk code files to Xcode project

require 'xcodeproj'

PROJECT_PATH = 'lolo.xcodeproj'
TARGET_NAME = 'lolo'
UTILS_DIR = 'lolo/Utils'

puts "📦 Adding junk files to Xcode project..."

# Open the project
project = Xcodeproj::Project.open(PROJECT_PATH)

# Find the main target
target = project.targets.find { |t| t.name == TARGET_NAME }
unless target
  puts "❌ Target '#{TARGET_NAME}' not found!"
  exit 1
end

# Find or create Utils group
utils_group = project.main_group.find_subpath(UTILS_DIR, true)

# Find all auto-generated junk files
junk_files = Dir.glob("#{UTILS_DIR}/NSString+*#{Time.now.to_i}*.{h,m}")

if junk_files.empty?
  puts "⚠️  No junk files found to add."
  exit 0
end

added_count = 0

junk_files.each do |file_path|
  file_name = File.basename(file_path)
  
  # Check if file is already in project
  existing = utils_group.files.find { |f| f.path == file_name }
  next if existing
  
  # Add file reference
  file_ref = utils_group.new_reference(file_path)
  
  # Add to build phase if it's a .m file
  if file_path.end_with?('.m')
    target.source_build_phase.add_file_reference(file_ref)
  end
  
  added_count += 1
  puts "✅ Added: #{file_name}"
end

# Save the project
project.save

puts "🎉 Successfully added #{added_count} junk files to Xcode project!"
