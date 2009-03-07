
class DentistsController < ApplicationController
  def create
    if params[:postcode]
      coords = grid_reference_for_postcode(params[:postcode]).join(",")
      coords = coords.split(",").map{|c| (c.to_i / 100).to_s}.reverse.join(",")
      p coords
      @dentist = NHSDentistCollection.new("SW112NH", coords).find{|d| p d; d.accepting_new_patiants?}
    else
      redirect_to :action => :index
    end
  end

private
  def geoloc_to_grid_reference(geoloc)
    result = opensearch.find_locations(geoloc.city.split(",").first)
    locations = result["GazetteerResult"]["items"]["Item"]
    p result
    raise "Couldn't find OpenSearch location for #{geoloc.full_address}" if locations.empty?
    best_guess = locations.first
    best_guess["location"]["gml:Point"]["gml:pos"].split(' ')
  end

  def grid_reference_for_postcode(postcode)
    geoloc = Geokit::Geocoders::YahooGeocoder.geocode("#{postcode}, UK")
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
