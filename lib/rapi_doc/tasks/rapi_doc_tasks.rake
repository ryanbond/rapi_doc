include RapiDoc::RAPIDoc

namespace :rapi_doc do
  
  desc "Generate the config files"
  task :setup do
    create_structure!
    puts "Now specify controllers in config/rapi_doc/config.yml for which api documentation is to be generated and then run rapi_doc::generate"
  end
  
  desc "Generate the api documentation"
  task :generate do
    yml = get_config
    if yml
      resources = get_resources(yml)
      # generate the apidoc
      puts "Generating API documentation..."
      generate_templates!(resources)
      move_structure!
      puts "Finished."
    end
  end

  desc "Clean up generated documentation"
  task :clean do
    remove_structure!
  end

  desc "Clean up everything - generated documentation and all the config"
  task :distclean do
    remove_all!
  end

end
