#!/usr/bin/env ruby

require "json"

# defaults
file = ENV['ENVFILE'] || ".env"
custom_env = false

puts "Reading env from #{file}"

dotenv = begin
  # find that above node_modules/react-native-config/ios/
  raw = File.read(file)
  raw.split("\n").inject({}) do |h, line|
    key, val = line.split("=", 2)
    if line.strip.empty? or line.start_with?('#')
      h
    else
      key, val = line.split("=", 2)
      h.merge!(key => val)
    end
  end
rescue Errno::ENOENT
  puts("**************************")
  puts("*** Missing .env file ****")
  puts("**************************")
  {} # set dotenv as an empty hash
end

# create obj file that sets DOT_ENV as a NSDictionary
dotenv_objc = dotenv.map { |k, v| %Q(@"#{k}":@"#{v}") }.join(",")
template = <<EOF
  #define DOT_ENV @{ #{dotenv_objc} };
EOF

# write it so that ReactNativeConfig.m can return it
path = File.join(ENV["SYMROOT"], "GeneratedDotEnv.m")
File.open(path, "w") { |f| f.puts template }

puts "Wrote to #{path}"
