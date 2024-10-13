require 'json'
require 'date'
require 'debug'
require_relative 'helpers'
require_relative 'car'
require_relative 'rental'
require_relative 'action'
require_relative 'option'

$debug_mode = false

module Getaround
  class App
    include Helpers

    INPUT_PATH  = 'data/input.json'
    OUTPUT_PATH = 'data/output.json'

    def initialize
      begin
        @input = JSON.parse(File.read(INPUT_PATH))
      rescue Errno::ENOENT
        handle_error "#{INPUT_PATH} not found"
      rescue JSON::ParserError
        handle_error "#{INPUT_PATH} is not a valid JSON file"
      end
    end

    def run
      ['cars', 'rentals', 'options'].each do |obj_type|
        @input[obj_type].each do |attrs|
          _class = Getaround.const_get(obj_type[0..-2].capitalize)
          _class.all << _class.new(attrs)
        end
      end

      Rental.process_all
      generate_output
    end

    private

    def generate_output
      output = { rentals: Rental.all.map(&:to_h) }

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
