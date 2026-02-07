#!/usr/bin/env ruby
# fix_xcode_references.rb
# Remove all file references and re-add Objective-C files

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the main group
main_group = project.main_group.find_subpath('lolo', true)

puts "Cleaning up old file references..."

# Remove all .swift file references from groups
def remove_swift_files(group)
  files_to_remove = []
  group.files.each do |file|
    if file.path && file.path.end_with?('.swift')
      files_to_remove << file
    end
  end
  
  files_to_remove.each do |file|
    puts "Removing reference: #{file.path}"
    file.remove_from_project
  end
  
  # Recursively process subgroups
  group.groups.each do |subgroup|
    remove_swift_files(subgroup)
  end
end

remove_swift_files(main_group)

# Save after cleanup
project.save

puts "\n✅ All Swift file references removed from Xcode project"
puts "\nNext: Please manually add the Objective-C files in Xcode:"
puts "1. Right-click on 'lolo' in Project Navigator"
puts "2. Select 'Add Files to \"lolo\"...'"
puts "3. Navigate to the lolo folder"
puts "4. Select these folders: Utils, Models"
puts "5. Also select: main.m, AppDelegate.h, AppDelegate.m, MainTabBarController.h, MainTabBarController.m, ViewControllers.h, HVC.m, MVC.m, PVC.m"
puts "6. Make sure 'Copy items if needed' is UNCHECKED (files are already there)"
puts "7. Make sure 'Create groups' is selected"
puts "8. Make sure target 'lolo' is checked"
puts "9. Click 'Add'"
