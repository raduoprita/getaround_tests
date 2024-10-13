module Getaround
  module Helpers
    def parsed_date(date)
      begin
        Date.parse(date)
      rescue Exception => e
        puts "Error parsing date: #{e.message}"
        exit
      end
    end
  end
end
