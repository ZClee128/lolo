#!/usr/bin/env ruby
# readd_oc_files.rb
# Re-add all Objective-C files to Xcode project with correct paths

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the main group
main_group = project.main_group.find_subpath('lolo', true)

# All OC files to add with their group paths
files_to_add = {
  'Utils' => [
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
    'lolo/Utils/DataService.h',
    'lolo/Utils/DataService.m',
  ],
  'Models' => [
    'lolo/Models/User.h',
    'lolo/Models/User.m',
    'lolo/Models/Post.h',
    'lolo/Models/Post.m',
    'lolo/Models/Message.h',
    'lolo/Models/Message.m',
    'lolo/Models/LOLOModels.h',
    'lolo/Models/LOLOModels.m',
  ],
  '' => [
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
}

puts "Adding Objective-C files to Xcode project..."
added_count = 0

files_to_add.each do |group_name, files|
  # Find or create the group
  if group_name.empty?
    group = main_group
  else
    group = main_group.find_subpath(group_name, false)
    unless group
      group = main_group.new_group(group_name, group_name)
    end
  end
  
  files.each do |file_path|
    next unless File.exist?(file_path)
    
    file_name = File.basename(file_path)
    
    # Check if file already exists in group
    existing_file = group.files.find { |f| f.path == file_name || f.display_name == file_name }
    if existing_file
      puts "  Already exists: #{file_path}"
      next
    end
    
    # Add file reference
    file_ref = group.new_file(file_path)
    
    # Add .m files to compile sources
    if file_path.end_with?('.m')
      target.source_build_phase.add_file_reference(file_ref)
    end
    
    puts "  ✅ Added: #{file_path}"
    added_count += 1
  end
end

# Save the project
project.save

puts "\n✅ Successfully added #{added_count} Objective-C files to Xcode project!"
puts "\nNext steps:"
puts "1. Close and reopen Xcode"
puts "2. All files should now appear correctly (no red files)"
puts "3. Clean build folder (Cmd+Shift+K)"
puts "4. Build project (Cmd+B)"
