#!/usr/bin/env ruby
# add_ui_files.rb
# Add all new UI files to Xcode project

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the main group
main_group = project.main_group.find_subpath('lolo', true)

# New UI files to add
new_files = {
  'Views/Home' => [
    'lolo/Views/Home/FeedCardCell.h',
    'lolo/Views/Home/FeedCardCell.m',
  ],
  'Views/Profile' => [
    'lolo/Views/Profile/ProfileHeaderView.h',
    'lolo/Views/Profile/ProfileHeaderView.m',
  ],
  'Views/IM' => [
    'lolo/Views/IM/MessageCell.h',
    'lolo/Views/IM/MessageCell.m',
  ]
}

puts "Adding new UI files to Xcode project..."
added_count = 0

new_files.each do |group_path, files|
  # Find or create the group hierarchy
  path_components = group_path.split('/')
  group = main_group
  
  path_components.each do |component|
    subgroup = group.find_subpath(component, false)
    unless subgroup
      subgroup = group.new_group(component, component)
    end
    group = subgroup
  end
  
  files.each do |file_path|
    next unless File.exist?(file_path)
    
    file_name = File.basename(file_path)
    
    # Check if file already exists
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

puts "\n✅ Successfully added #{added_count} new UI files!"
puts "\nNext: Build the project in Xcode"
