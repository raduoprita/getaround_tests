require_relative 'main'

module Getaround
  RSpec.describe Car do
    it "initializes with the correct args" do
      car = Car.new({ 'id' => 1, 'price_per_day' => 200, 'price_per_km' => 10 })

      expect(car).to_not be_nil
      expect(car.id).to eq(1)
      expect(car.price_per_day).to eq(200)
      expect(car.price_per_km).to eq(10)
    end
  end

  RSpec.describe Rental do
    it "initializes with the correct args" do
      rental = Rental.new({ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 })

      expect(rental).to_not be_nil
      expect(rental.id).to eq(1)
      expect(rental.car_id).to eq(1)
      expect(rental.start_date).to eq(Date.parse('2017-12-8'))
      expect(rental.end_date).to eq(Date.parse('2017-12-10'))
      expect(rental.distance).to eq(100)
    end

    it "calculates price" do
      rental = Rental.new({ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 })
      car    = Car.new({ 'id' => 1, 'price_per_day' => 200, 'price_per_km' => 10 })
      rental.calculate_price(car)
      expect(rental.price).to eq(1560)

      rental.end_date = Date.parse('2017-12-30')
      rental.calculate_price(car)
      expect(rental.price).to eq(5440)
    end
  end

  RSpec.describe App do
    it "initializes with the correct args" do
      app = App.new

      expect(app).to_not be_nil
      expect(app.cars).to_not be_nil
      expect(app.rentals).to_not be_nil

      rental = app.rentals.find { |rental| rental.id == 1 }

      expect(rental).to_not be_nil
      expect(rental.id).to eq(1)
      expect(rental.car_id).to eq(1)
      expect(rental.start_date).to eq(Date.parse('2015-12-8'))
      expect(rental.end_date).to eq(Date.parse('2015-12-8'))
      expect(rental.distance).to eq(100)

      car = app.cars.find { |car| car.id == 1 }

      expect(car).to_not be_nil
      expect(car.id).to eq(1)
      expect(car.price_per_day).to eq(2000)
      expect(car.price_per_km).to eq(10)
    end
  end
end
