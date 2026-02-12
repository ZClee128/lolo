#!/usr/bin/env ruby
# inject_junk_code.rb
# Purpose: Inject randomized junk code into Objective-C files to change binary signature

require 'securerandom'
require 'time'

# Configuration
TARGET_DIR = "./lolo"
JUNK_FILES_COUNT = 3
METHODS_PER_FILE = 5
BUILD_TIMESTAMP = Time.now.to_i

class JunkCodeGenerator
  CATEGORY_NAMES = %w[Performance Analytics Network Cache Storage Security Validation Utils Helper]
  METHOD_PREFIXES = %w[process handle validate transform compute calculate analyze generate]
  OBJECT_TYPES = %w[Data Metrics Session Configuration State Result Response Request]
  
  def initialize(timestamp)
    @timestamp = timestamp
    @random = Random.new(@timestamp)
  end
  
  def generate_random_string(length = 8)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a
    (0...length).map { chars[@random.rand(chars.length)] }.join
  end
  
  def generate_method_name
    prefix = METHOD_PREFIXES[@random.rand(METHOD_PREFIXES.length)]
    object = OBJECT_TYPES[@random.rand(OBJECT_TYPES.length)]
    suffix = generate_random_string(4)
    "#{prefix}#{object}#{suffix}"
  end
  
  def generate_property_name
    types = %w[current cached pending active]
    type = types[@random.rand(types.length)]
    object = OBJECT_TYPES[@random.rand(OBJECT_TYPES.length)]
    "#{type}#{object}#{@random.rand(100)}"
  end
  
  def generate_junk_method
    method_name = generate_method_name
    param_name = generate_random_string(6)
    return_value = @random.rand(1000)
    
    <<~OBJC
      - (NSInteger)#{method_name}:(NSString *)#{param_name} {
          // Auto-generated method #{@timestamp}
          NSInteger value = #{return_value};
          for (NSInteger i = 0; i < [#{param_name} length]; i++) {
              value = (value * 31 + [#{param_name} characterAtIndex:i]) % 1000;
          }
          return value;
      }
    OBJC
  end
  
  def generate_junk_property
    property_name = generate_property_name
    "@property (nonatomic, assign) NSInteger #{property_name};"
  end
  
  def generate_header_file(class_name, category_name)
    properties = (1..3).map { generate_junk_property }.join("\n")
    
    <<~OBJC
      //
      //  #{class_name}+#{category_name}.h
      //  lolo
      //
      //  Auto-generated: #{Time.now}
      //  Build: #{@timestamp}
      //
      
      #import <Foundation/Foundation.h>
      
      NS_ASSUME_NONNULL_BEGIN
      
      @interface #{class_name} (#{category_name})
      
      #{properties}
      
      @end
      
      NS_ASSUME_NONNULL_END
    OBJC
  end
  
  def generate_implementation_file(class_name, category_name, methods_count)
    methods = (1..methods_count).map { generate_junk_method }.join("\n")
    
    <<~OBJC
      //
      //  #{class_name}+#{category_name}.m
      //  lolo
      //
      //  Auto-generated: #{Time.now}
      //  Build: #{@timestamp}
      //
      
      #import "#{class_name}+#{category_name}.h"
      
      @implementation #{class_name} (#{category_name})
      
      #{methods}
      
      @end
    OBJC
  end
end

# Main execution
puts "🎭 Starting junk code injection..."
puts "📅 Build timestamp: #{BUILD_TIMESTAMP}"

generator = JunkCodeGenerator.new(BUILD_TIMESTAMP)

# Ensure target directory exists
unless Dir.exist?(TARGET_DIR)
  puts "❌ Target directory #{TARGET_DIR} not found!"
  exit 1
end

# Find Utils directory
utils_dir = File.join(TARGET_DIR, "Utils")
unless Dir.exist?(utils_dir)
  puts "⚠️  Utils directory not found, creating it..."
  Dir.mkdir(utils_dir)
end

# Generate junk files
JUNK_FILES_COUNT.times do |i|
  class_name = "NSString"  # Add categories to common Foundation classes
  category_name = "#{JunkCodeGenerator::CATEGORY_NAMES.sample}#{BUILD_TIMESTAMP}_#{i}"
  
  header_file = File.join(utils_dir, "#{class_name}+#{category_name}.h")
  impl_file = File.join(utils_dir, "#{class_name}+#{category_name}.m")
  
  # Generate and write files
  File.write(header_file, generator.generate_header_file(class_name, category_name))
  File.write(impl_file, generator.generate_implementation_file(class_name, category_name, METHODS_PER_FILE))
  
  puts "✅ Generated: #{File.basename(header_file)} / #{File.basename(impl_file)}"
end

puts "🎉 Junk code injection complete! Generated #{JUNK_FILES_COUNT * 2} files with #{JUNK_FILES_COUNT * METHODS_PER_FILE} methods."
