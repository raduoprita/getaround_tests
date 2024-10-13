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
      expect(rental.rental_days).to eq(3)
    end

    it "calculates price" do
      rental = Rental.new({ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 })
      car    = Car.new({ 'id' => 1, 'price_per_day' => 2000, 'price_per_km' => 10 })
      rental.process(car)
      expect(rental.price).to eq(6600)
      expect(rental.commission[:insurance_fee]).to eq(990)
      expect(rental.commission[:assistance_fee]).to eq(300)
      expect(rental.commission[:drivy_fee]).to eq(690)

      rental.rental_days = 23
      rental.process(car)
      expect(rental.price).to eq(36400)
      expect(rental.commission[:insurance_fee]).to eq(5460)
      expect(rental.commission[:assistance_fee]).to eq(2300)
      expect(rental.commission[:drivy_fee]).to eq(3160)

      expected = {
        id:      1,
        actions: [
                   {
                     who:    "driver",
                     type:   "debit",
                     amount: 36400
                   },
                   {
                     who:    "owner",
                     type:   "credit",
                     amount: 25480,
                   },
                   {
                     who:    "insurance",
                     type:   "credit",
                     amount: 5460,
                   },
                   {
                     who:    "assistance",
                     type:   "credit",
                     amount: 2300,
                   },
                   {
                     who:    "drivy",
                     type:   "credit",
                     amount: 3160
                   }
                 ]
      }
      expect(rental.to_h).to eq(expected)
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
      expect(rental.rental_days).to eq(1)

      car = app.cars.find { |car| car.id == 1 }

      expect(car).to_not be_nil
      expect(car.id).to eq(1)
      expect(car.price_per_day).to eq(2000)
      expect(car.price_per_km).to eq(10)
    end
  end

  RSpec.describe Action do
    it "initializes with the correct args" do
      action = Action.new({ who: 'driver', amount: 1000 })
      expect(action).to_not be_nil
      expect(action.who).to eq('driver')
      expect(action.type).to eq('debit')
      expect(action.amount).to eq(1000)

      expected = {
        who:    'driver',
        type:   'debit',
        amount: 1000
      }

      expect(action.to_h).to eq(expected)

      action = Action.new({ who: 'drivy', amount: 1000 })
      expect(action).to_not be_nil
      expect(action.who).to eq('drivy')
      expect(action.type).to eq('credit')
      expect(action.amount).to eq(1000)
    end

    it "raises error with invalid args" do
      expect { Action.new({ who: 'John', amount: 1000 }) }.to raise_error
    end
  end
end
