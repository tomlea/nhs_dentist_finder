module DynamicSass
  class StylesheetsController < ActionController::Base
    def show
      stylesheet = params[:stylesheet] or raise "Stylesheet name is not optional."
      stylesheet =~ /^[0-9a-z.-_]+$/ or raise "Stylesheet name is not valid."
      sass_path = File.join(Rails.root, "public", "stylesheets", "sass", "#{stylesheet}.sass")
      raise "No such stylesheet available" unless File.exists? sass_path

      if stale?(:last_modified => File.mtime(sass_path).utc)
        expires_in 24.hours
        sass_engine = Sass::Engine.new(File.read(sass_path))
        render :text => sass_engine.render, :content_type => "text/css"
      end
    end
  end
end
