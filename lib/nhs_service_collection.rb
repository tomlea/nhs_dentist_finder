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

  def each(&block)
    return @complete_set.each(&block) if @complete_set
    values = []
    doc = Hpricot(open("http://www.nhs.uk/ServiceDirectories/Pages/ServiceResults.aspx?Postcode=#{postcode}&Coords=#{coords}&ServiceType=#{service_type}&JScript=1"))

    loop do
      doc.search("//.result").each do |el|
        item = new_item(el)
        values.push item
        yield item
      end

      if next_page_link = doc.search("//li.next/a").first and next_page_link[:href]
        doc = Hpricot(open("http://www.nhs.uk"+next_page_link[:href]))
      else
        return @complete_set = values
      end
    end
  end

  def all
    rv = []
    each{|d| rv.push d }
    rv
  end
end
