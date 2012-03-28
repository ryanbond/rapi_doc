include RapiDoc::RapiConfig
include FileUtils::Verbose # so that each mv/cp/mkdir gets printed and user is aware of what is happening

namespace :rapi_doc do
  
  desc "Generate the config files"
  task :setup do
    if File.directory?(config_dir)
      #puts "#{BASE_DIR}/#{File.basename(@config_dir)} exists"
    else
      mkdir config_dir
    end
    filetypes = FILE_NAMES.keys
    filetypes.each do |file_type|
      target_file = config_dir(file_type)
      if File.exist? target_file
        #puts "#{BASE_DIR}/#{File.basename(target_file)} exists"
      else
        template_file = template_dir(file_type)
        cp template_file, config_dir
        #puts "Generated #{BASE_DIR}/#{File.basename(template_file)}"
      end
    end
    puts "Now specify controllers in config/rapi_doc/config.yml for which api documentation is to be generated and then run rapi_doc::generate"
  end
  
  desc "Generate the API Documentation"
  task :generate do
    config_file = config_dir(:config_file)
    begin
      yml_file = File.open(config_file)
    rescue Errno::ENOENT
      puts "Please run rake rapi_doc:setup to generate config files first and then run rapi_doc::generate again"
    else
      yml = YAML::load(yml_file)
      if not yml
        puts "Please specify controllers in config/rapi_doc/config.yml for which api documentation is to be generated and then run rapi_doc::generate again"
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
end
