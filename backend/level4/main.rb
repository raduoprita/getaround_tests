require 'json'
require 'date'
require 'debug'
require_relative 'helpers'
require_relative 'car'
require_relative 'rental'
require_relative 'action'

$debug_mode = false

module Getaround
  class App
    include Helpers
    attr_reader :cars, :rentals

    INPUT_PATH  = 'data/input.json'
    OUTPUT_PATH = 'data/output.json'

    def initialize
      begin
        input = JSON.parse(File.read(INPUT_PATH))
      rescue Errno::ENOENT
        handle_error "#{INPUT_PATH} not found"
      rescue JSON::ParserError
        handle_error "#{INPUT_PATH} is not a valid JSON file"
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
      calculate_rental_prices
      generate_output
    end

    private

    def calculate_rental_prices
      rentals.each do |rental|
        car = cars.find { |car| car.id == rental.car_id }

        if car
          rental.process(car)
        else
          handle_error "Car not found for rental id #{rental.id} (Car id #{rental.car_id})"
        end
      end
    end

    def generate_output
      output = { rentals: rentals.map(&:to_h) }

      begin
        File.write(OUTPUT_PATH, JSON.pretty_generate(output))
      rescue IOError => e
        handle_error "Error writing to #{OUTPUT_PATH}: #{e.message}"
      end
    end
  end
end

app = Getaround::App.new
app.run
