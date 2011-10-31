require File.dirname(__FILE__) + '/../../lib/rapi_doc.rb'

desc "Generate the API Documentation"
task :rapi_doc do

  config_dir   = File.join(::Rails.root.to_s, 'config/rapi_doc')
  template_dir = File.join(File.dirname(__FILE__), '/../../templates')
  target_config_file   = File.join(config_dir,   'config.yml')
  template_config_file = File.join(template_dir, 'config.yml')

  begin
    yml = YAML::load(File.open(targe_config_file))
  rescue
    FileUtils.mkdir(config_dir)
    FileUtils.cp template_config_file, target_config_file
    puts "Generated config/rapi_doc/config.yml."
  end

  # Generating documentations
  if yml
    resources = []
    yml.keys.each do |key|
      resources << ResourceDoc.new(key, yml[key]["location"], yml[key]["controller_name"])
    end

    # generate the apidoc
    RAPIDoc.new(resources)
  end
end

