#!/usr/bin/env ruby
# fix_viewmodel_paths.rb
# Fix the duplicate path issue in ViewModels

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first
main_group = project.main_group.find_subpath('lolo', true)

puts "Fixing ViewModels file paths..."

# Find ViewModels group
viewmodels_group = main_group.find_subpath('ViewModels', false)

if viewmodels_group
  viewmodels_group.files.each do |file|
    if file.path && file.path.include?('lolo/ViewModels/lolo/ViewModels')
      old_path = file.path
      new_path = old_path.gsub('lolo/ViewModels/lolo/ViewModels', 'lolo/ViewModels')
      file.path = new_path
      puts "Fixed: #{old_path} -> #{new_path}"
    end
  end
end

project.save

puts "\n✅ Fixed file path issues!"
puts "Rebuilding..."
