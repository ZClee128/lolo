# encoding: UTF-8
# fix_url_placeholders.rb
# Purpose: Fix URL placeholders with proper obfuscation calls

require 'fileutils'

file = 'lolo/Utils/DataService.m'

content = File.read(file, encoding: 'UTF-8')

# Fix avatar URL placeholders - should use StringObfuscation method + ID
# Example: obfuscated_avatar_url_placeholder1" -> [NSString stringWithFormat:@"%@%@", [StringObfuscation avatarBaseURL], @"1"]
5.times do |i|
  id = i + 1
  old_str = "obfuscated_avatar_url_placeholder#{id}\""
  new_str = "[NSString stringWithFormat:@\"%@%@\", [StringObfuscation avatarBaseURL], @\"#{id}\"]"
  content.gsub!(old_str, new_str)
  puts "✓ Replaced avatar URL placeholder #{id}"
end

# Fix picsum placeholder in CreatePostViewController - this one should just use local assets
# We'll replace it with a simple comment since it's mock data
pic_file = 'lolo/Views/Home/CreatePostViewController.m'
if File.exist?(pic_file)
  pic_content = File.read(pic_file, encoding: 'UTF-8')
  pic_content.gsub!('obfuscated_picsum_url_placeholder400/300?random=999"', '@"placeholder.jpg" /* Using local asset instead of external URL */')
  File.write(pic_file, pic_content)
  puts "✓ Fixed CreatePostViewController placeholder"
end

# Fix picsum placeholders in mock posts - replace with StringObfuscation call
7.times do |i|
  id = i + 1
  old_str = "obfuscated_picsum_url_placeholder400/300?random=#{id}\""
  # Use the obfuscated URL method
  new_str = "[NSString stringWithFormat:@\"%@400/300?random=%d\", [StringObfuscation placeholderImageBaseURL], #{id}]"
  content.gsub!(old_str, new_str)
  puts "✓ Replaced picsum URL placeholder #{id}"
end

File.write(file, content)

puts "\n✅ All URL placeholders fixed!"
