require 'compass'
require 'compass/exec'
require 'sprockets'
require 'fileutils'
require 'uglifier'
require 'yui/compressor'
require 'rake'

ROOT = File.dirname(__FILE__)
BUILD_PATH = File.join(ROOT, 'dist')
SPROCKET_ASSETS = [:javascripts, :stylesheets]
MUSTACHES_CONFIG = 'mustaches.yml'

namespace :nyu_assets do
  desc "Compile assets, usage rake nyu_assets:compile['/project/root'[, '/project/root/mustaches.yml']]"
  task :compile, :project_root, :mustaches_config do |task, args|
    args.with_defaults(:project_root => ROOT)
    args.with_defaults(:mustaches_config => MUSTACHES_CONFIG)
    Rake::Task['nyu_assets:cleanup'].invoke(args[:project_root], args[:mustaches_config])
    Rake::Task['nyu_assets:compass'].invoke(args[:project_root])
    Rake::Task['nyu_assets:sprockets'].invoke(args[:project_root])
    Rake::Task['nyu_assets:mustache'].invoke(args[:project_root], args[:mustaches_config])
  end

  desc "Cleanup assets"
  task :cleanup, :project_root, :mustaches_config do |task, args|
    FileUtils.rm_r BUILD_PATH if File.exists?(BUILD_PATH)
    Compass::Exec::SubCommandUI.new(["clean", args[:project_root]]).run!
    # Don't initialize Compass assets, the config will take care of it
    (SPROCKET_ASSETS).each do |asset|
      FileUtils.mkdir_p File.join(BUILD_PATH, asset.to_s)
    end
    YAML.load_file(args[:mustaches_config]).each_key do |dir|
      FileUtils.mkdir_p File.join(BUILD_PATH, dir.to_s)
    end
  end

  desc "Compile compass"
  task :compass, :project_root do |task, args|
    # First do the compass stuff
    Compass::Exec::SubCommandUI.new(["compile", args[:project_root], "-s", "compact"]).run!
  end

  desc "Compile sprockets"
  task :sprockets, :project_root do |task, args|
    # Initialize sprockets environment
    sprockets = Sprockets::Environment.new(args[:project_root]) do |env|
      env.logger = Logger.new(STDOUT)
    end
    SPROCKET_ASSETS.each do |asset_type|
      load_path = File.join(args[:project_root], asset_type.to_s)
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
  task :mustache, :project_root, :mustaches_config do |task, args|
    mustaches_config = YAML.load_file(args[:mustaches_config])
    mustaches_config.each do |dir, mustaches|
      mustaches.each do |mustache|
        mustache_file = mustache.downcase
        require File.join(args[:project_root], dir, mustache_file)
        mustache = Kernel.const_get(mustache).new
        mustache.template_path= File.join(args[:project_root], dir)
        mustache.template_extension= "html.mustache"
        build_file = File.join(BUILD_PATH, dir, "#{mustache_file}.html")
        File.open(build_file, 'w') do |f|
          f.write(mustache.render)
        end
      end
    end
  end
end
# task :default => :compile