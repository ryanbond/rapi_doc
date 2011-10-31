require File.dirname(__FILE__) + '/../../lib/rapi_doc.rb'

desc "Generate the API Documentation"
task :rapi_doc do

  begin
    yml = YAML::load(File.open(target_config_file))
  rescue
    FileUtils.mkdir(config_dir)
    FileUtils.cp template_config_file, target_config_file
    FileUtils.cp index_layout_file, config_dir
    FileUtils.cp resource_layout_file, config_dir
    puts "Generated config/rapi_doc/config.yml." # TODO Add instructions for users to update the config file
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

