module Getaround
  module Helpers
    def parsed_date(date)
      begin
        Date.parse(date)
      rescue Exception => e
        handle_error "Error parsing date: #{e.message}"
      end
    end

    def handle_error(message, with_raise: true)
      # TODO decide how to handle errors
      if with_raise
        raise message
      else
        puts "Error: #{message}"
        exit
      end
    end

    def validate_int(attribute, value)
      unless value.is_a?(Integer)
        handle_error "#{attribute}: #{value} should be an Integer"
      end
    end

    def validate_date(attribute, value)
      unless value.is_a?(Date)
        handle_error "#{attribute}: #{value} should be an Date"
      end
    end

    def validate_enum(attribute, value, array)
      unless array.include?(value)
        handle_error "Invalid #{attribute}: #{value}"
      end
    end
  end
end
