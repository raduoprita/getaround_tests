module Getaround
  class Rental
    include Helpers
    attr_accessor :id, :car_id, :start_date, :end_date, :distance, :price

    def initialize(attrs)
      @id         = attrs['id'].to_i
      @car_id     = attrs['car_id'].to_i
      @start_date = parsed_date(attrs['start_date'])
      @end_date   = parsed_date(attrs['end_date'])
      @distance   = attrs['distance'].to_i
      @price      = 0
    end
  end
end
