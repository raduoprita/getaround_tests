module Getaround
  class Car
    include Helpers
    attr_accessor :id, :price_per_day, :price_per_km

    def self.all
      @all ||= []
    end

    def initialize(attrs)
      @id            = attrs['id'].to_i
      @price_per_day = attrs['price_per_day'].to_i
      @price_per_km  = attrs['price_per_km'].to_i

      validate_attributes
    end

    private

    def validate_attributes
      validate_int(:id, id)
      validate_int(:price_per_day, price_per_day)
      validate_int(:price_per_km, price_per_km)
    end
  end
end
