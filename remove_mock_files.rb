#!/usr/bin/env ruby
# remove_mock_files.rb
# Remove MockDataService files from Xcode project

require 'xcodeproj'

project_path = './lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Find all file references with MockDataService
files_to_remove = []
project.files.each do |file|
  if file.path && (file.path.include?('MockDataService'))
    puts "Found file to remove: #{file.path}"
    files_to_remove << file
  end
end

# Remove from build phases
files_to_remove.each do |file|
  target.source_build_phase.files.each do |build_file|
    if build_file.file_ref == file
      puts "Removing from build phase: #{file.path}"
      build_file.remove_from_project
    end
  end
  
  # Remove the file reference itself
  puts "Removing file reference: #{file.path}"
  file.remove_from_project
end

# Save the project
project.save

puts "\n✅ Successfully removed #{files_to_remove.count} MockDataService file references!\n"
