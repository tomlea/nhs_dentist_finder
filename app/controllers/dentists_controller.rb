
class DentistsController < ApplicationController
  def create
    if params[:postcode]
      coords = grid_reference_for_postcode(params[:postcode]).join(",")
      @dentist = NHSDentistCollection.new(coords).find(&:accepting_new_patiants?)
    else
      redirect_to :action => :index
    end
  end

private
  def geoloc_to_grid_reference(geoloc)
    result = opensearch.find_locations(geoloc.full_address)
    locations = result["GazetteerResult"]["items"]["Item"]
    raise "Couldn't find OpenSearch location for #{geoloc.full_address}" if locations.empty?
    best_guess = locations.first
    best_guess["location"]["gml:Point"]["gml:pos"].split(' ')
  end

  def grid_reference_for_postcode(postcode)
    geoloc = Geokit::Geocoders::GoogleGeocoder.geocode("#{postcode}, UK")
    p :outer => geoloc
    geoloc = geoloc.all.first
    p :first => geoloc
    raise "Could not find location for #{postcode}" unless geoloc.success and geoloc.full_address
    geoloc_to_grid_reference(geoloc)
  end


  def opensearch
    @opensearch ||= OpenSearch::Gazetteer.new('64887C0822065909E0405F0AF0607E40')
  end

end
