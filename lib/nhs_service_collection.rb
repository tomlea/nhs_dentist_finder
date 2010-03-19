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

  def first(n = nil)
    if n
      collection = []
      each do |v|
        return collection if collection.size >= n
        collection << v
      end
      collection
    else
      first(1).first
    end
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
    @nhs_api ||= if ENV["nhs_password"] and ENV["nhs_username"]
      {:username => ENV["nhs_username"], :password => ENV["nhs_password"]}
    else
      YAML.load(File.open(File.join(Rails.root, "config", "nhs_api.yml"))).symbolize_keys
    end
  end
end
