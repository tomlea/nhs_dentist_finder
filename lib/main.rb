require "nhs_dentist_collection"

p NHSDentistCollection.new("SW174PQ", "1756,5270").find(&:accepting_new_patiants?)
