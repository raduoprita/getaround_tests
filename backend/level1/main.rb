require 'json'
require 'date'
require 'debug'
require_relative 'helpers'
require_relative 'car'
require_relative 'rental'

module Getaround
  class App
    attr_reader :cars, :rentals

    INPUT_PATH  = 'data/input.json'
    OUTPUT_PATH = 'data/output.json'

    def initialize
      begin
        input = JSON.parse(File.read(INPUT_PATH))
      rescue Errno::ENOENT
        puts "#{INPUT_PATH} not found"
        exit
      rescue JSON::ParserError
        puts "#{INPUT_PATH} is not a valid JSON file"
        exit
      end

      @cars = []
      input['cars'].each do |car_attrs|
        @cars << Car.new(car_attrs)
      end

      @rentals = []
      input['rentals'].each do |rental_attrs|
        @rentals << Rental.new(rental_attrs)
      end
    end

    def run
      calculate_rental_price
      generate_output
    end

    private

    def calculate_rental_price
      rentals.each do |rental|
        car = cars.find { |car| car.id == rental.car_id }

        if car
          rental.price += rental.distance * car.price_per_km
          rental.price += (rental.end_date - rental.start_date + 1).to_i * car.price_per_day
        else
          puts "Car not found for rental id #{rental.id} (Car id #{rental.car_id})"
          exit
        end
      end
    end

    def generate_output
      data   = rentals.map { |rental| { 'id' => rental.id, 'price' => rental.price } }
      output = { rentals: data }

      begin
        File.write(OUTPUT_PATH, JSON.pretty_generate(output))
      rescue IOError => e
        puts "Error writing to #{OUTPUT_PATH}: #{e.message}"
        exit
      end
    end
  end
end

app = Getaround::App.new
app.run
