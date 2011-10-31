require File.dirname(__FILE__) + '/../../lib/rapi_doc.rb'

desc "Generate the API Documentation"
task :rapi_doc do

  begin
    target_dir = "#{::Rails.root.to_s}/config/rapi_doc"
    yml = YAML::load(File.open("#{target_dir}/config.yml"))
  rescue
    puts "Can't find the configuration file. Generating that for you.."
    template_dir = File.dirname(__FILE__) + '/../../templates'
    FileUtils.cp "#{template_dir}/config.yml", target_dir
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

