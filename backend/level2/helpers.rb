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
  end
end
