module Gridloc
  def self.convert(latitude, longitude)
    Dir.chdir File.join(Rails.root, 'vendor', 'gridloc') do
      bin_path = File.join(Rails.root, 'vendor', 'gridloc', 'gridloc')
      results = `#{bin_path} #{latitude} #{longitude}`
      raise "Gridloc failure!" unless $?.success?
      return results.split(",").map(&:to_i)
    end
  end
end
