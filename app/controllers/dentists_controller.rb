
class DentistsController < ApplicationController
  def create
    if params[:postcode]
      postcode = params[:postcode].gsub(/[^A-Za-z0-9]/, "")
      coords = grid_reference_for_postcode(postcode)
      coords = coords.map{|c| c / 100 }.reverse.join(",")
      @dentist = NHSDentistCollection.new(postcode, coords).find{|d| p d; d.accepting_new_patiants?}
    else
      redirect_to :action => :index
    end
  end

private
  def grid_reference_for_postcode(postcode)
    geoloc = Geokit::Geocoders::YahooGeocoder.geocode("#{postcode}, UK")
    raise "Could not find location for #{postcode}" unless geoloc.success
    Gridloc.convert(geoloc.lat, geoloc.lng)
  end


  def opensearch
    @opensearch ||= OpenSearch::Gazetteer.new('64887C0822065909E0405F0AF0607E40')
  end

end
