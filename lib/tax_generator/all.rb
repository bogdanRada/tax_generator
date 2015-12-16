$stdin.sync = true # if $stdin.isatty
$stdout.sync = true # if $stdout.isatty
require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/module/delegation'

require 'slop'
require 'nokogiri'
require 'tree'
require 'celluloid/autostart'
require 'celluloid/pmap'

require 'logger'
require 'fileutils'
require 'ostruct'
require 'erb'
require 'tilt'

%w(classes helpers).each do |folder_name|
  Gem.find_files("tax_generator/#{folder_name}/**/*.rb").each { |path| require path }
end
require_relative './application'
require_relative './version'
