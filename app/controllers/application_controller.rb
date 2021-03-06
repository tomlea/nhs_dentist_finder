# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '927fb1cd7189233c73cc69a855654236'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password


  private
    def grid_reference_for_postcode(postcode)
      geoloc = Geokit::Geocoders::YahooGeocoder.geocode("#{postcode}, UK")
      raise "Could not find location for #{postcode}" unless geoloc.success
      Gridloc.convert(geoloc.lat, geoloc.lng)
    end
end
