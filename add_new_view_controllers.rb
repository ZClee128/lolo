#!/usr/bin/env ruby
# add_new_view_controllers.rb
# Add PostDetailViewController and CreatePostViewController to Xcode project

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find the Views/Home group
main_group = project.main_group.find_subpath('lolo', true)
views_group = main_group.find_subpath('Views', false) || main_group.new_group('Views', 'Views')
home_group = views_group.find_subpath('Home', false) || views_group.new_group('Home', 'Home')

# New files to add
new_files = [
  'lolo/Views/Home/PostDetailViewController.h',
  'lolo/Views/Home/PostDetailViewController.m',
  'lolo/Views/Home/CreatePostViewController.h',
  'lolo/Views/Home/CreatePostViewController.m',
]

puts "Adding new view controllers to Xcode project..."
added_count = 0

new_files.each do |file_path|
  next unless File.exist?(file_path)
  
  file_name = File.basename(file_path)
  
  # Check if file already exists
  existing_file = home_group.files.find { |f| f.path == file_name || f.display_name == file_name }
  if existing_file
    puts "  Already exists: #{file_path}"
    next
  end
  
  # Add file reference
  file_ref = home_group.new_file(file_path)
  
  # Add .m files to compile sources
  if file_path.end_with?('.m')
    target.source_build_phase.add_file_reference(file_ref)
  end
  
  puts "  ✅ Added: #{file_path}"
  added_count += 1
end

# Save the project
project.save

puts "\n✅ Successfully added #{added_count} new view controllers!"
puts "\nNext: Build the project"
