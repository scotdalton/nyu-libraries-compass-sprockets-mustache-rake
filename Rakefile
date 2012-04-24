require 'compass'
require 'compass/exec'
require 'sprockets'
require 'fileutils'
require 'uglifier'
require 'yui/compressor'
require 'rake'

ROOT = File.dirname(__FILE__)
SPROCKET_ASSETS = [:javascripts, :stylesheets]
MUSTACHES_CONFIG = "mustaches.yml.tml"

namespace :nyu_libraries_assets do
  desc "Compile assets, usage rake nyu_assets:compile['/project/root'[, 'mustaches.yml'[, true|false]]]"
  task :compile, :project_root, :mustaches_config, :downcase do |task, args|
    args.with_defaults(:project_root => ROOT)
    args.with_defaults(:mustaches_config => MUSTACHES_CONFIG)
    build_path = File.join(args[:project_root], 'dist')
    Rake::Task['nyu_libraries_assets:cleanup'].invoke(args[:project_root], args[:mustaches_config], build_path)
    Rake::Task['nyu_libraries_assets:compass'].invoke(args[:project_root])
    Rake::Task['nyu_libraries_assets:sprockets'].invoke(args[:project_root], build_path)
    Rake::Task['nyu_libraries_assets:mustache'].invoke(args[:project_root], args[:mustaches_config], build_path, args[:downcase])
  end

  desc "Cleanup assets"
  task :cleanup, :project_root, :mustaches_config, :build_path do |task, args|
    FileUtils.rm_r args[:build_path] if File.exists?(args[:build_path])
    Compass::Exec::SubCommandUI.new(["clean", args[:project_root]]).run!
    # Don't initialize Compass assets, the config will take care of it
    (SPROCKET_ASSETS).each do |asset|
      FileUtils.mkdir_p File.join(args[:build_path], asset.to_s)
    end
    mustaches_config_file = "#{args[:project_root]}/#{args[:mustaches_config]}"
    if File.exists?(mustaches_config_file)
      mustaches_config = YAML.load_file(mustaches_config_file)
      if mustaches_config
        mustaches_config.each_key do |dir|
          FileUtils.mkdir_p File.join(args[:build_path], dir.to_s)
        end
      end
    end
  end

  desc "Compile compass"
  task :compass, :project_root do |task, args|
    # First do the compass stuff
    Compass::Exec::SubCommandUI.new(["compile", args[:project_root], "-s", "compact"]).run!
  end

  desc "Compile sprockets"
  task :sprockets, :project_root, :build_path do |task, args|
    # Initialize sprockets environment
    sprockets = Sprockets::Environment.new(args[:project_root]) do |env|
      env.logger = Logger.new(STDOUT)
    end
    SPROCKET_ASSETS.each do |asset_type|
      load_path = File.join(args[:project_root], asset_type.to_s)
      next unless File.exists?(load_path)
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
          build_file = File.join(args[:build_path], asset_type.to_s, name)
          File.open(build_file, 'w') do |f|
            f.write(asset)
          end
        end
      end
    end
  end

  desc "Make mustaches"
  task :mustache, :project_root, :mustaches_config, :build_path, :downcase do |task, args|
    args.with_defaults(:downcase => true)
    mustaches_config_file = "#{args[:project_root]}/#{args[:mustaches_config]}"
    if File.exists?(mustaches_config_file)
      mustaches_config = YAML.load_file(mustaches_config_file)
      if mustaches_config
        mustaches_config.each do |dir, mustaches|
          mustaches.each do |mustache|
            template = (mustache.is_a? Hash) ? mustache.keys.first : mustache
            template_file = template.gsub(/(.)([A-Z])/,'\1_\2').downcase
            if mustache[template].is_a? Array
              mustache[template].each do |logic_file|
                logic_class = logic_file
                logic_file = logic_file.gsub(/(.)([A-Z])/,'\1_\2').downcase
                logic_output_file = (args[:downcase].eql? true) ? logic_file.gsub(/(.)([A-Z])/,'\1_\2').downcase : logic_class
                require File.join(args[:project_root], dir, logic_file)
                mustache = Kernel.const_get(logic_class).new
                mustache.template_file= File.join(args[:project_root], dir, template_file) + ".html.mustache"
                build_file = File.join(args[:build_path], dir, "#{logic_output_file}.html")
                File.open(build_file, 'w') do |f|
                  f.write(mustache.render)
                end
              end
            else
              require File.join(args[:project_root], dir, template_file)
              mustache = Kernel.const_get(template).new
              mustache.template_file= File.join(args[:project_root], dir, template_file) + ".html.mustache"
              build_file = File.join(args[:build_path], dir, "#{template_file}.html")
              File.open(build_file, 'w') do |f|
                f.write(mustache.render)
              end
            end
          end
        end
      end
    end
  end
end