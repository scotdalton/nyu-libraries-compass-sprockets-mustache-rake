require 'compass'
require 'compass/exec'
require 'sprockets'
require 'fileutils'
require 'uglifier'
require 'yui/compressor'

ROOT = File.dirname(__FILE__)
BUILD_PATH = File.join(ROOT, 'dist')
SPROCKET_ASSETS = [:javascripts, :css]
MUSTACHES_CONFIG = 'mustaches.yml'
COMPASS_CONFIG = "#{ROOT}/compass.rb"

desc "Cleanup assets"
task :cleanup do
  FileUtils.rm_r BUILD_PATH if File.exists?(BUILD_PATH)
  Compass::Exec::SubCommandUI.new(["clean", ROOT]).run!
  # Don't initialize Compass assets, the config will take care of it
  (SPROCKET_ASSETS).each do |asset|
    FileUtils.mkdir_p File.join(BUILD_PATH, asset.to_s)
  end
  YAML.load_file(MUSTACHES_CONFIG).each_key do |dir|
    FileUtils.mkdir_p File.join(BUILD_PATH, dir.to_s)
  end
end

desc "Compile assets"
task :compile => [:cleanup, :compass, :sprockets, :mustache]

desc "Compile compass"
task :compass do
  # First do the compass stuff
  Compass::Exec::SubCommandUI.new(["compile", ROOT, "-s", "compact", "-c", COMPASS_CONFIG]).run!
end

desc "Compile sprockets"
task :sprockets do
  # Initialize sprockets environment
  sprockets = Sprockets::Environment.new(ROOT) do |env|
    env.logger = Logger.new(STDOUT)
  end
  SPROCKET_ASSETS.each do |asset_type|
    load_path = File.join(ROOT, asset_type.to_s)
    sprockets.append_path load_path
    Dir.new(load_path).each do |filename|
      file = File.join(load_path, filename)
      if File.exists?(file) and File.file?(file)
        asset = sprockets[filename]
        attributes = sprockets.attributes_for(asset.pathname)
        name, format = attributes.logical_path, attributes.format_extension
        puts format
        asset = asset.to_s
        # Minify JS
        asset = Uglifier.compile(asset) if format.eql?(".js")
        # Minify CSS
        asset = YUI::CssCompressor.new.compress(asset) if format.eql?(".css")
        build_file = File.join(BUILD_PATH, asset_type.to_s, name)
        File.open(build_file, 'w') do |f|
          f.write(asset)
        end
      end
    end
  end
end

desc "Make mustaches"
task :mustache do
  mustaches_config = YAML.load_file(MUSTACHES_CONFIG)
  mustaches_config.each do |dir, mustaches|
    mustaches.each do |mustache|
      mustache_file = mustache.downcase
      require File.join(ROOT, dir, mustache_file)
      mustache = Kernel.const_get(mustache).new
      mustache.template_path= File.join(ROOT, dir)
      mustache.template_extension= "html.mustache"
      build_file = File.join(BUILD_PATH, dir, "#{mustache_file}.html")
      File.open(build_file, 'w') do |f|
        f.write(mustache.render)
      end
    end
  end
end

task :default => :compile