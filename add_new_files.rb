#!/usr/bin/env ruby
# add_new_files.rb
# Add newly created files to Xcode project

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the main group
main_group = project.main_group.find_subpath('lolo', true)

# New files to add
new_files = {
  'Utils' => [
    'lolo/Utils/MockDataService.h',
    'lolo/Utils/MockDataService.m',
  ],
  'ViewModels' => [
    'lolo/ViewModels/HomeViewModel.h',
    'lolo/ViewModels/HomeViewModel.m',
    'lolo/ViewModels/ProfileViewModel.h',
    'lolo/ViewModels/ProfileViewModel.m',
  ]
}

puts "Adding new files to Xcode project..."
added_count = 0

new_files.each do |group_name, files|
  # Find or create the group
  group = main_group.find_subpath(group_name, false)
  unless group
    group = main_group.new_group(group_name, group_name)
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

puts "\n✅ Successfully added #{added_count} new files!"
puts "\nBuilding project..."
