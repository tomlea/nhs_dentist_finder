
class DoctorsController < ApplicationController
  def create
    if params[:postcode]
      postcode = params[:postcode].gsub(/[^A-Za-z0-9]/, "")
      if params[:all]
        @doctors = NHSDoctorsCollection.new(postcode).all
      else
        @doctors = [NHSDoctorsCollection.new(postcode).find{|d| true}].compact
      end
    else
      redirect_to :action => :index
    end
  end
end
