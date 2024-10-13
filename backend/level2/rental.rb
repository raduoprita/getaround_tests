module Getaround
  class Rental
    include Helpers
    attr_accessor :id, :car_id, :start_date, :end_date, :distance, :price

    DISCOUNT_MAP = {
      1               => 1,
      4               => 0.9,
      10              => 0.7,
      Float::INFINITY => 0.5,
    }.sort_by { |k, _| k }.to_h.freeze # make sure it's sorted

    def initialize(attrs)
      @id         = attrs['id'].to_i
      @car_id     = attrs['car_id'].to_i
      @start_date = parsed_date(attrs['start_date'])
      @end_date   = parsed_date(attrs['end_date'])
      @distance   = attrs['distance'].to_i
      @price      = 0
    end

    def calculate_price(car)
      rental_days = (end_date - start_date + 1).to_i

      pricing_list      = []
      total_priced_days = 0
      DISCOUNT_MAP.each do |days, factor|
        priced_days = [days, rental_days].min - total_priced_days

        pricing_list << { days: priced_days, factor: factor } if priced_days > 0
        total_priced_days += priced_days
      end

      if rental_days != total_priced_days
        handle_error "Rental days (#{rental_days}) don't match total priced days (#{total_priced_days})"
      end

      puts
      puts '-' * 30
      puts "rental_days: #{rental_days}"
      puts "total_priced_days: #{total_priced_days}"
      puts pricing_list

      pricing_list.each do |item|
        @price += item[:days] * item[:factor] * car.price_per_day
      end
      @price += distance * car.price_per_km
      @price = @price.to_i

      puts "price: #{@price}"
    end
  end
end
