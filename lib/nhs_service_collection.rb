require 'rubygems'
require 'hpricot'
Hpricot.buffer_size = 262144
require 'open-uri'
require 'enumerator'
require 'active_support'

class NHSServiceCollection
  include Enumerable

  GP = 1
  DENTISTS = 2

  attr_reader :service_type, :postcode
  def initialize(postcode)
    @postcode = postcode
    @service_type = DENTISTS
  end

  def each(&block)
    values = []
    doc = Hpricot(open("http://www.nhs.uk/NHSCWS/Services/ServicesSearch.aspx?user=#{nhs_api[:username]}&pwd=#{nhs_api[:password]}&q=#{postcode}&type=#{service_type}&PageNumber=1&PageSIze=100"))
    doc.search("//service").each do |el|
      item = new_item(el)
      values.push item
      yield item
    end

    values
  end

  def all
    rv = []
    each{|d| rv.push d }
    rv
  end

  def nhs_api
    self.class.nhs_api
  end

  def self.nhs_api
    @nhs_api ||= YAML.load(File.open(File.join(Rails.root, "config", "nhs_api.yml"))).symbolize_keys
  end
end
