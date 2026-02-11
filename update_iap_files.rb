#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'lolo.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
group = project.main_group.find_subpath('lolo', true)

# Files to remove
files_to_remove = [
  'Utils/StoreManager.h',
  'Utils/StoreManager.m',
  'Views/CoinStoreViewController.h',
  'Views/CoinStoreViewController.m'
]

# Files to add
files_to_add = [
  'Utils/LoloDataConnector.h',
  'Utils/LoloDataConnector.m',
  'Views/LoloWalletDetailView.h',
  'Views/LoloWalletDetailView.m'
]

puts "Removing old files..."
files_to_remove.each do |path|
  file_ref = group.find_file_by_path(path)
  if file_ref
    file_ref.remove_from_project
    puts "Removed #{path}"
  else
    puts "File not found in project: #{path}"
  end
end

puts "\nAdding new files..."
files_to_add.each do |path|
  # Split path to find group
  components = path.split('/')
  filename = components.pop
  folder = components.join('/')
  
  # Find group
  target_group = group.find_subpath(folder, true)
  
  # Create file reference
  file_ref = target_group.new_file(filename)
  
  # Add to target if it's an implementation file
  if filename.end_with?('.m')
    target.add_file_references([file_ref])
  end
  puts "Added #{path}"
end

project.save
puts "\nProject saved!"
