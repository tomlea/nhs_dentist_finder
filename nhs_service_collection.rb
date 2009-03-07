require 'rubygems'
require 'hpricot'
Hpricot.buffer_size = 262144
require 'open-uri'
require 'enumerator'
require 'active_support'

class NHSServiceCollection
  include Enumerable

  attr_reader :service_type, :postcode, :coords
  def initialize(postcode, coords)
    @postcode, @coords = postcode, coords
    @service_type = "Dentist"
  end

  def each
    return @complete_set if @complete_set
    values = []
    doc = Hpricot(open("http://www.nhs.uk/ServiceDirectories/Pages/ServiceResults.aspx?Postcode=#{postcode}&Coords=#{coords}&ServiceType=#{service_type}&JScript=1"))

    loop do
      doc.search("//.result").each do |el|
        link = el.search("//a").first
        dentist = member_class.new(link[:title], "http://www.nhs.uk" + link[:href].gsub(/[ ^]/, "+"))
        values.push dentist
        yield dentist
      end

      unless next_page_link = doc.search("//li.next/a").first and next_page_link[:href]
        return @complete_set = values
      end

      doc = Hpricot(open("http://www.nhs.uk"+next_page_link[:href]))
    end
  end

  def nearest
    each{|r| return r}
  end
end
