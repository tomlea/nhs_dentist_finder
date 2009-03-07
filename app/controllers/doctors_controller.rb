
class DoctorsController < ApplicationController
  def create
    if params[:postcode]
      postcode = params[:postcode].gsub(/[^A-Za-z0-9]/, "")
      coords = grid_reference_for_postcode(postcode)
      coords = coords.map{|c| c / 100 }.reverse.join(",")
      if params[:all]
        @doctors = NHSDoctorsCollection.new(postcode, coords).all
      else
        @doctors = [NHSDoctorsCollection.new(postcode, coords).find{|d| true}]
      end
    else
      redirect_to :action => :index
    end
  end
end
