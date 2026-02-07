#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

main_target = project.targets.find { |t| t.name == 'lolo' }

# Find Views group
lolo_group = project.main_group.groups.find { |g| g.display_name == 'lolo' }
views_group = lolo_group.groups.find { |g| g.display_name == 'Views' }

unless views_group
  puts 'Creating Views group...'
  views_group = lolo_group.new_group('Views', 'lolo/Views')
end

# Add TermsViewController files
files_to_add = [
  'lolo/Views/TermsViewController.h',
  'lolo/Views/TermsViewController.m'
]

files_to_add.each do |file_path|
  if File.exist?(file_path)
    file_name = File.basename(file_path)
    
    # Check if already exists
    existing = views_group.files.find { |f| f.path == file_name }
    
    unless existing
      file_ref = views_group.new_reference(file_name)
      
      # Add .m files to compile sources
      if file_path.end_with?('.m')
        main_target.add_file_references([file_ref])
      end
      
      puts "✅ Added #{file_name}"
    else
      puts "ℹ️  #{file_name} already exists"
    end
  else
    puts "❌ File not found: #{file_path}"
  end
end

project.save
puts "✅ Project saved successfully"
