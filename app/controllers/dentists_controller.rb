
class DentistsController < ApplicationController
  def create
    if params[:postcode]
      postcode = params[:postcode].gsub(/[^A-Za-z0-9]/, "")
      coords = grid_reference_for_postcode(postcode)
      coords = coords.map{|c| c / 100 }.reverse.join(",")
      if params[:all]
        @dentists = NHSDentistCollection.new(postcode, coords).select{|d| p d; d.accepting_new_patiants?}
      else
        @dentists = [NHSDentistCollection.new(postcode, coords).find{|d| p d; d.accepting_new_patiants?}].compact
      end
    else
      redirect_to :action => :index
    end
  end
end
