
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

  def search
    if params[:postcode]
      postcode = params[:postcode].gsub(/[^A-Za-z0-9]/, "")
      @doctors = NHSDoctorsCollection.new(postcode).first(10)
      render :json => @doctors.map(&:to_hash), :callback => params[:callback]
    end
  end
end
