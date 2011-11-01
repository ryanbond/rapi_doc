module Config
  def config_dir
    File.join(::Rails.root.to_s, 'config/rapi_doc')
  end

  def template_dir
    File.join(File.dirname(__FILE__), '/../templates')
  end

  def config_file(location)
    File.join(find_location(location), 'config.yml')
  end

  def layout_file(location)
    File.join(find_location(location), 'layout.html.erb')
  end

  def find_location(location)
    location == :target ? config_dir : template_dir
  end
end