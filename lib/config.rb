module Config
  def config_dir
    File.join(::Rails.root.to_s, 'config/rapi_doc')
  end

  def template_dir
    File.join(File.dirname(__FILE__), '/../templates')
  end

  def target_config_file
    File.join(config_dir,   'config.yml')
  end

  def template_config_file
    File.join(template_dir, 'config.yml')
  end

  def index_layout_file
    File.join(config_dir, 'index.html.erb')
  end

  def resource_layout_file
    File.join(config_dir, 'resource.html.erb')
  end
end