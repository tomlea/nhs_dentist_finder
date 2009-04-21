
class DentistsController < ApplicationController
  def create
    if params[:postcode]
      postcode = params[:postcode].gsub(/[^A-Za-z0-9]/, "")
      if params[:all]
        @dentists = []
        NHSDentistCollection.new(postcode).each{|d| p d; @dentists << d if d.accepting_new_patiants?; break if @dentists.size >= 5}
      else
        @dentists = [NHSDentistCollection.new(postcode).find{|d| p d; d.accepting_new_patiants?}].compact
      end
    else
      redirect_to :action => :index
    end
  end
end
