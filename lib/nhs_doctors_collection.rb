require "nhs_service_collection"

class NHSDoctor < Struct.new(:name, :details_url)


  def inspect
    "#<NHSDentist name=#{name.inspect}, details_url=#{details_url.inspect}>"
  end
private
  def details
    @details ||= (
      doc = Hpricot(open(details_url))
      accepting = doc.search("//.Accepting/text()").map(&:to_s)
      {:accepting => accepting}
    )
  end
end

class NHSDoctorsCollection < NHSServiceCollection
  def initialize(*args)
    super
    @service_type = "GP"
  end
  def new_item(el)
    if link = el.search("//a").first
      NHSDoctor.new(link[:title], "http://www.nhs.uk" + link[:href].gsub(/[ ^]/, "+"))
    end
  end
end
