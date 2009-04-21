require "nhs_service_collection"

class NHSDentist < Struct.new(:name, :details_url)
  ACCEPTANCE_STRINGS = ["Accepting new children aged 0-18 years for NHS treatment", "Accepting new charge-exempt adults for NHS treatment", "Emergency NHS treatment for patients not registered with a dentist", "Patients with treatment at standard NHS charges", "NHS treatment for the re-alignment of teeth and jaws", "Appliances including various types of braces subject to an examination", "Orthodontic treatment that may be available for both adults and children", "Access to this service is by referral from a Dental Practitioner only", "Currently accepting new fee-paying NHS patients", "Provides urgent dental access slots", "Please contact the PCT dental helpline for information on dental services", "NHS treatment for people who may not otherwise seek or receive dental care ", "NHS treatment for the elderly, housebound or people with mental or physical health problems", "NHS treatment for groups with special needs"]
  def accepting
    details[:accepting]
  end

  def accepting_new_patiants?
    accepting.include?( "Patients with treatment at standard NHS charges" ) || accepting.include?( "Currently accepting new fee-paying NHS patients" )
  end

  def inspect
    "#<NHSDentist name=#{name.inspect}, details_url=#{details_url.inspect}, details=#{@details.inspect}>"
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

class NHSDentistCollection < NHSServiceCollection
  def new_item(el)
    details_page_url = el.search("//providerprofilepageurl").first.inner_html
    name = el.search("//name").first.inner_html
    NHSDentist.new(name, details_page_url)
  end
end
