module Getaround
  class Rental
    include Helpers

    COMMISSION_FEE_FACTOR = 0.3
    INSURANCE_FEE_FACTOR  = 0.5
    DAILY_ASSISTANCE_FEE  = 100
    DISCOUNT_MAP          = {
      1               => 1,
      4               => 0.9,
      10              => 0.7,
      Float::INFINITY => 0.5,
    }.sort_by { |k, _| k }.to_h.freeze # make sure it's sorted

    def self.process_all
      all.each do |rental|
        rental.process
      end
    end

    def self.all
      @all ||= []
    end

    def initialize(attrs)
      @id          = attrs['id'].to_i
      @car_id      = attrs['car_id'].to_i
      @start_date  = parsed_date(attrs['start_date'])
      @end_date    = parsed_date(attrs['end_date'])
      @distance    = attrs['distance'].to_i
      @price       = 0
      @rental_days = (@end_date - @start_date + 1).to_i

      validate_attributes
    end

    def process
      calculate_price
      calculate_commission
      create_actions
      add_options
    end

    def to_h
      {
        id:      @id,
        options: options.map(&:type),
        actions: @actions.map(&:to_h)
      }
    end

    def car
      @car ||= (Car.all.find { |car| car.id == @car_id }) or handle_error "Car not found for rental id #{@id} (Car id #{@car_id})"
    end

    def options
      @options ||= Option.all.find_all { |option| option.rental_id == @id }
    end

    private

    def validate_attributes
      validate_int(:id, @id)
      validate_int(:car_id, @car_id)
      validate_date(:start_date, @start_date)
      validate_date(:end_date, @end_date)
      validate_int(:distance, @distance)
      validate_int(:rental_days, @rental_days)
    end

    def calculate_price
      pricing_list      = []
      total_priced_days = 0
      DISCOUNT_MAP.each do |days, factor|
        priced_days = [days, @rental_days].min - total_priced_days

        pricing_list << { days: priced_days, factor: factor } if priced_days > 0
        total_priced_days += priced_days
      end

      if @rental_days != total_priced_days
        handle_error "Rental days (#{@rental_days}) don't match total priced days (#{total_priced_days})"
      end

      if $debug_mode
        puts
        puts '-' * 30
        puts "rental_days: #{@rental_days}"
        puts "total_priced_days: #{total_priced_days}"
        puts pricing_list
      end

      pricing_list.each do |item|
        @price += item[:days] * item[:factor] * car.price_per_day
      end
      @price += @distance * car.price_per_km
      @price = @price.to_i

      puts "-- -- Rental id #{id} (Car id #{car_id}): #{price}" if $debug_mode
    end

    def calculate_commission
      @commission_amount = (@price * COMMISSION_FEE_FACTOR).to_i
      insurance_fee      = @commission_amount * INSURANCE_FEE_FACTOR
      assistance_fee     = @rental_days * DAILY_ASSISTANCE_FEE
      drivy_fee          = @commission_amount - insurance_fee - assistance_fee
      @commission        = {
        insurance_fee:  insurance_fee.to_i,
        assistance_fee: assistance_fee.to_i,
        drivy_fee:      drivy_fee.to_i
      }

      puts "commission: #{@commission}" if $debug_mode
    end

    def create_actions
      @actions = [
        Action.new({ who: 'driver', amount: @price }),
        Action.new({ who: 'owner', amount: @price - @commission_amount }),
        Action.new({ who: 'insurance', amount: @commission[:insurance_fee] }),
        Action.new({ who: 'assistance', amount: @commission[:assistance_fee] }),
        Action.new({ who: 'drivy', amount: @commission[:drivy_fee] }),
      ]
    end

    def add_options
      total_options_amount = 0
      options.each do |option|
        action         = @actions.find { |action| action.who == option.price_hash.keys.first }
        options_amount = option.price_hash[action.who] * @rental_days
        action.amount  += options_amount

        total_options_amount += options_amount
      end
      @actions.find { |action| action.who == 'driver' }.amount += total_options_amount
    end
  end
end
