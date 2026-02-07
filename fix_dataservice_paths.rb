#!/usr/bin/env ruby
# fix_dataservice_paths.rb  
# Fix DataService file paths in Xcode project

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find DataService files and remove them first
puts "Removing incorrectly added DataService files..."
project.files.each do |file|
  if file.path && file.path.include?('DataService')
    puts "  Removing: #{file.path}"
    # Remove from all build phases
    project.targets.first.source_build_phase.files.each do |build_file|
      build_file.remove_from_project if build_file.file_ref == file
    end
    file.remove_from_project
  end
end

# Add them back with correct paths
puts "\nAdding DataService files with correct paths..."

# Find the Utils group
main_group = project.main_group.find_subpath('lolo', true)
utils_group = main_group.find_subpath('Utils', false)

unless utils_group
  puts "ERROR: Utils group not found!"
  exit 1
end

# Add DataService.h
h_file = utils_group.new_file('DataService.h')
puts "  Added: DataService.h"

# Add DataService.m and add to compile sources
m_file = utils_group.new_file('DataService.m')
project.targets.first.source_build_phase.add_file_reference(m_file)
puts "  Added: DataService.m (added to build phase)"

# Save the project
project.save

puts "\n✅ Successfully fixed DataService file references!"
puts "\nNext: Clean derived data and rebuild"
