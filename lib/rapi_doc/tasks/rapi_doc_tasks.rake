include RapiDoc::RapiConfig

namespace :rapi_doc do
  desc "Generate the config files"
  task :setup do
    if File.directory?(config_dir)
      puts "#{BASE_DIR}/#{File.basename(config_dir)} exists"
    else
      FileUtils.mkdir(config_dir)
    end
    FILE_LOCATIONS.each_key do |file_type|
      target_file = send(file_type, :target)
      if File.exist? target_file
        puts "#{BASE_DIR}/#{File.basename(target_file)} exists"
      else
        template_file = send(file_type, :template)
        FileUtils.cp template_file, config_dir
        puts "Generated #{BASE_DIR}/#{File.basename(template_file)}" # TODO Add instructions for users to update the config file
      end
    end
  end
  desc "Generate the API Documentation"
  task :generate do
    begin
      yml = YAML::load(File.open(config_file(:target)))
    rescue
      puts "It seems that you don't have the config files yet. Please run rake rapi_doc:setup"
    else
      # Generating documentations
      resources = yml.collect do |key, val|
        RapiDoc::ResourceDoc.new(key, val["location"], val["controller_name"])
      end

      # generate the apidoc
      RapiDoc::RAPIDoc.new(resources)
    end
  end
end
