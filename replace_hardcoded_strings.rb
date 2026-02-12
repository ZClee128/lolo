#!/usr/bin/env ruby
# encoding: UTF-8
# replace_hardcoded_strings.rb
# Purpose: Batch replace hardcoded strings with obfuscated versions

replacements = {
  # UserDefaults keys
  '@"CurrentUserId"' => '[StringObfuscation userDefaultsKeyCurrentUserId]',
  '@"UserCreatedPosts"' => '[StringObfuscation userDefaultsKeyUserCreatedPosts]',
  '@"HasAgreedToTerms"' => '[StringObfuscation userDefaultsKeyHasAgreedToTerms]',
  '@"BlockedUsers"' => '[StringObfuscation userDefaultsKeyBlockedUsers]',
  
  # Notification names
  '@"CoinsBalanceDidChangeNotification"' => '[StringObfuscation notificationNameCoinsBalanceChanged]',
  '@"AccountDeletedNotification"' => '[StringObfuscation notificationNameAccountDeleted]',
  '@"TermsAgreedNotification"' => '[StringObfuscation notificationNameTermsAgreed]',
  
  # URLs (more complex, need manual review)
  '@"https://i.pravatar.cc/150?u=' => 'obfuscated_avatar_url_placeholder',
  '@"https://picsum.photos/' => 'obfuscated_picsum_url_placeholder'
}

files_to_process = [
  'lolo/Utils/DataService.m',
  'lolo/Utils/ReportManager.m',
  'lolo/AppDelegate.m',
  'lolo/Views/SettingsViewController.m',
  'lolo/Views/TermsAgreementViewController.m',
  'lolo/Views/TermsViewController.m',
  'lolo/Views/Profile/ProfileHeaderView.m',
  'lolo/Views/LoloWalletDetailView.m',
  'lolo/Views/Home/CreatePostViewController.m'
]

puts "🔧 Starting batch string replacement..."

files_to_process.each do |file_path|
  unless File.exist?(file_path)
    puts "⚠️  Skipping #{file_path} (not found)"
    next
  end
  
  content = File.read(file_path, encoding: 'UTF-8')
  original_content = content.dup
  changed = false
  
  replacements.each do |old_str, new_str|
    if content.include?(old_str)
      count = content.scan(old_str).length
      content.gsub!(old_str, new_str)
      puts "  ✓ #{File.basename(file_path)}: Replaced '#{old_str}' (#{count} occurrences)"
      changed = true
    end
  end
  
  if changed
    File.write(file_path, content)
    puts "✅ Updated: #{file_path}"
  end
end

puts "\n🎉 Batch replacement complete!"
puts "\n⚠️  IMPORTANT: URLs still need manual replacement. Search for 'obfuscated_' placeholders."
