#!/usr/bin/env ruby
# add_files_to_xcode.rb
# Script to add Objective-C files to Xcode project and remove Swift files

require 'xcodeproj'

project_path = ARGV[0] || './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the main group (usually the project name)
main_group = project.main_group.find_subpath('lolo', true)

# Files to add (.h and .m)
oc_files_to_add = [
  # Utils
  'lolo/Utils/ObfuscationUtil.h',
  'lolo/Utils/ObfuscationUtil.m',
  'lolo/Utils/Constants.h',
  'lolo/Utils/Constants.m',
  'lolo/Utils/UIView+Extensions.h',
  'lolo/Utils/UIView+Extensions.m',
  'lolo/Utils/ImageLoader.h',
  'lolo/Utils/ImageLoader.m',
  'lolo/Utils/AvatarGenerator.h',
  'lolo/Utils/AvatarGenerator.m',
  
  # Models
  'lolo/Models/User.h',
  'lolo/Models/User.m',
  'lolo/Models/Post.h',
  'lolo/Models/Post.m',
  'lolo/Models/Message.h',
  'lolo/Models/Message.m',
  'lolo/Models/LOLOModels.h',
  'lolo/Models/LOLOModels.m',
  
  # Core
  'lolo/main.m',
  'lolo/AppDelegate.h',
  'lolo/AppDelegate.m',
  'lolo/MainTabBarController.h',
  'lolo/MainTabBarController.m',
  'lolo/ViewControllers.h',
  'lolo/HVC.m',
  'lolo/MVC.m',
  'lolo/PVC.m',
]

puts "Adding Objective-C files to Xcode project..."

oc_files_to_add.each do |file_path|
  next unless File.exist?(file_path)
  
  # Determine the group path
  path_components = file_path.split('/')
  path_components.shift # Remove 'lolo'
  file_name = path_components.pop
  group_path = path_components.join('/')
  
  # Find or create the group
  group = main_group
  path_components.each do |component|
    subgroup = group.find_subpath(component, false)
    unless subgroup
      subgroup = group.new_group(component)
    end
    group = subgroup
  end
  
  # Check if file already exists in group
  existing_file = group.files.find { |f| f.path == file_name || f.path.end_with?(file_name) }
  next if existing_file
  
  # Add file reference
  file_ref = group.new_file(file_path)
  
  # Add .m files to compile sources
  if file_path.end_with?('.m')
    target.add_file_references([file_ref])
  end
  
  puts "Added: #{file_path}"
end

# Remove Swift files from target
puts "\nRemoving Swift files from project..."
swift_files_removed = 0

target.source_build_phase.files.each do |build_file|
  file_ref = build_file.file_ref
  next unless file_ref && file_ref.path
  
  if file_ref.path.end_with?('.swift')
    target.source_build_phase.remove_file_reference(file_ref)
    swift_files_removed += 1
    puts "Removed from build: #{file_ref.path}"
  end
end

# Save the project
project.save

puts <<~SUCCESS

✅ Done! Processed files:
   - Added: #{oc_files_to_add.length} Objective-C files
   - Removed from build: #{swift_files_removed} Swift files

⚠️  Next steps:
   1. Open Xcode and delete all .swift files from the project navigator
   2. Clean build folder (Cmd+Shift+K)
   3. Build the project (Cmd+B)
   4. Fix any compilation errors
SUCCESS
