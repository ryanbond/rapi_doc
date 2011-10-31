desc "Generate the API Documentation"
task :rapi_doc do
  begin
    yml = YAML::load(File.open(config_file(:target)))
  rescue
    FileUtils.mkdir(config_dir) if (!File.directory?(config_dir))
    [config_file(:template), index_layout_file(:template), resource_layout_file(:template)].each do |_file|
      FileUtils.cp _file, config_dir
      puts "Generated config/rapi_doc/#{File.basename(_file)}" # TODO Add instructions for users to update the config file
    end
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

