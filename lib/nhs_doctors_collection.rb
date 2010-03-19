require "nhs_service_collection"

class NHSDoctor < Struct.new(:name, :details_url, :address, :telephone)
  def inspect
    "#<NHSDoctor name=#{name.inspect}, details_url=#{details_url.inspect}>"
  end

  def to_hash
    {:name => name, :details_url => details_url, :address => address, :telephone => telephone}
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
    telephone = el.search("//telephone").first.try(:inner_html)
    address = %w[address1 address2 address3 address4 address5 postcode].map{|el_name|
      el.search("//#{el_name}").first.try(:inner_html)
    }.reject(&:blank?).join("\n")
    NHSDoctor.new(name, details_page_url, address, telephone)
  end
end
