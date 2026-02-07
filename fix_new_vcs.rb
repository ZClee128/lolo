#!/usr/bin/env ruby
# fix_new_vcs.rb
# Fix paths for new view controllers

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Remove bad file references first
puts "Removing bad file references..."
target.source_build_phase.files.each do |build_file|
  next unless build_file.file_ref
  
  path = build_file.file_ref.path
  if path && (path.include?('PostDetail') || path.include?('CreatePost'))
    if path.include?('lolo/Views/Home/lolo')
      puts "  Removing: #{path}"
      build_file.remove_from_project
    end
  end
end

# Find the Home group
main_group = project.main_group.find_subpath('lolo', true)
views_group = main_group.find_subpath('Views', false)
home_group = views_group.find_subpath('Home', false) if views_group

# Remove bad file references from groups too
if home_group
  home_group.files.each do |file_ref|
    if file_ref.path && file_ref.path.include?('lolo/Views/Home/lolo')
      puts "  Removing from group: #{file_ref.path}"
      file_ref.remove_from_project
    end
  end
end

# Add files correctly
new_files = {
  'PostDetailViewController.h' => 'lolo/Views/Home/PostDetailViewController.h',
  'PostDetailViewController.m' => 'lolo/Views/Home/PostDetailViewController.m',
  'CreatePostViewController.h' => 'lolo/Views/Home/CreatePostViewController.h',
  'CreatePostViewController.m' => 'lolo/Views/Home/CreatePostViewController.m',
}

puts "\nAdding files with correct paths..."
new_files.each do |name, path|
  next unless File.exist?(path)
  
  # Check if already exists
  existing = home_group.files.find { |f| f.display_name == name }
  if existing
    puts "  Already exists: #{name}"
    next
  end
  
  # Add file
  file_ref = home_group.new_reference(path)
  
  # Add .m to build phase
  if path.end_with?('.m')
    target.source_build_phase.add_file_reference(file_ref)
  end
  
  puts "  ✅ Added: #{path}"
end

project.save
puts "\n✅ Done! Files added correctly."
