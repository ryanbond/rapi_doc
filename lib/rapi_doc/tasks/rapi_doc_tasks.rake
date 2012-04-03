include RapiDoc::RAPIDoc

namespace :rapi_doc do

  desc "Generate the config files"
  task :setup do
    create_structure!
    #puts "Now specify controllers in config/rapi_doc/config.yml for which api documentation is to be generated and then run rapi_doc::generate"
  end

  desc "Generate the api documentation"
  task :generate do
    controllers = get_controllers!
    if controllers.empty?
      puts "You don't have any controllers to generate api documentation for"
      #puts "Please specify controllers in config/rapi_doc/config.yml for which api documentation is to be generated and then run rapi_doc::generate again"
    else
      resources = []
      controllers.each do |controller, controller_url, controller_location|
        print "Generate documentation for resource \"#{controller}\" mapped at \"#{controller_url}\" (\"#{File.basename(controller_location)}\")? (Y/n):"
        response = STDIN.gets.chomp
        if ['y', 'Y'].include? response
          resources << RapiDoc::ResourceDoc.new(controller, controller_url, controller_location)
        end
      end
      if resources.empty?
        puts "Nothing to generate"
      else
        # generate the apidoc
        puts "Generating API documentation..."
        generate_templates!(resources)
        move_structure!
        puts "Finished."
      end
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
