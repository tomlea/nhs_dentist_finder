if ActionController::Base.instance_methods.include?("sass_old_process")
  ActionController::Base.send(:alias_method, :process, :sass_old_process)
end
