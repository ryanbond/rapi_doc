require 'configatron'
require File.dirname(__FILE__) + '/../../lib/rapi_doc.rb'

desc "Generate the API Documentation"
task :rapi_doc do

  begin
    yml = YAML::load(File.open("#{::Rails.root.to_s}/config/documentation.yml"))
    configatron.configure_from_yaml "#{::Rails.root}/config/config.yml", :hash => Rails.env
  rescue
    puts "Please ensure that you have created a documentation.yml file in your config directory"
  end
  if yml
    resources = []
    yml.keys.each do |key|
      resources << ResourceDoc.new(key, yml[key]["location"], yml[key]["controller_name"])
    end

    # generate the apidoc
    RAPIDoc.new(resources)
  end
end

