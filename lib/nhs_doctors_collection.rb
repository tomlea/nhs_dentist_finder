require "nhs_service_collection"

class NHSDoctor < Struct.new(:name, :details_url)
  def inspect
    "#<NHSDoctor name=#{name.inspect}, details_url=#{details_url.inspect}>"
  end
private
  def details
    @details ||= (
      doc = Hpricot(open(details_url.gsub(" ", "+")))
      accepting = doc.search("//.Accepting/text()").map(&:to_s)
      {:accepting => accepting}
    )
  end
end

class NHSDoctorsCollection < NHSServiceCollection
  def initialize(*args)
    super
    @service_type = GP
  end
  def new_item(el)
    details_page_url = el.search("//providerprofilepageurl").first.inner_html
    name = el.search("//name").first.inner_html
    NHSDoctor.new(name, details_page_url)
  end
end
