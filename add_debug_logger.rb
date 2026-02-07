#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

main_target = project.targets.find { |t| t.name == 'lolo' }

# Find or create Utils group
lolo_group = project.main_group.groups.find { |g| g.display_name == 'lolo' }
utils_group = lolo_group.groups.find { |g| g.display_name == 'Utils' }

unless utils_group
  puts 'Error: Utils group not found'
  exit 1
end

# Add DebugLogger.h
header_file = 'lolo/Utils/DebugLogger.h'
if File.exist?(header_file)
  # Check if already exists
  existing = utils_group.files.find { |f| f.path == 'DebugLogger.h' }
  
  unless existing
    file_ref = utils_group.new_reference('DebugLogger.h')
    puts "✅ Added DebugLogger.h to Xcode project"
  else
    puts "ℹ️  DebugLogger.h already in project"
  end
end

project.save
puts "✅ Project saved successfully"
