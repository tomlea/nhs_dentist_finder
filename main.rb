require 'rubygems'
require 'hpricot'
Hpricot.buffer_size = 262144
require 'open-uri'
require 'enumerator'
require 'active_support'

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

class NHSDentistCollection
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
        dentist = NHSDentist.new(link[:title], "http://www.nhs.uk" + link[:href].gsub(/[ ^]/, "+"))
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

p NHSDentistCollection.new("SW174PQ", "1756,5270").find(&:accepting_new_patiants?)
