module Getaround
  class Option
    include Helpers
    attr_reader :id, :rental_id, :type, :price_hash

    VALIDATIONS = {
      type: ['gps', 'baby_seat', 'additional_insurance']
    }

    DAILY_PRICING = {
      'gps'                  => { 'owner' => 500 },
      'baby_seat'            => { 'owner' => 200 },
      'additional_insurance' => { 'drivy' => 1000 }
    }

    def self.all
      @all ||= []
    end

    def initialize(attrs)
      @id         = attrs['id'].to_i
      @rental_id  = attrs['rental_id'].to_i
      @type       = attrs['type']
      @price_hash = DAILY_PRICING[type]

      validate_attributes
    end

    private

    def validate_attributes
      validate_int(:id, id)
      validate_int(:rental_id, rental_id)
      validate_enum(:type, type, VALIDATIONS[:type])
    end
  end
end
