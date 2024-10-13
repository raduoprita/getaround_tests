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
    it "calculates commissions and generates hash" do
      rental = Rental.new({ 'id' => 1, 'car_id' => 1, 'start_date' => '2017-12-8', 'end_date' => '2017-12-10', 'distance' => 100 })
      rental.process

      expected = {
        id:      1,
        options: [
                   "gps",
                   "baby_seat"
                 ],
        actions: [
                   {
                     who:    "driver",
                     type:   "debit",
                     amount: 8700
                   },
                   {
                     who:    "owner",
                     type:   "credit",
                     amount: 6720,
                   },
                   {
                     who:    "insurance",
                     type:   "credit",
                     amount: 990,
                   },
                   {
                     who:    "assistance",
                     type:   "credit",
                     amount: 300,
                   },
                   {
                     who:    "drivy",
                     type:   "credit",
                     amount: 690
                   }
                 ]
      }

      expect(rental.to_h).to eq(expected)

      rental.instance_variable_set(:@rental_days, 23)
      rental.process

      expected = {
        id:      1,
        options: [
                   "gps",
                   "baby_seat"
                 ],
        actions: [
                   {
                     who:    "driver",
                     type:   "debit",
                     amount: 52500
                   },
                   {
                     who:    "owner",
                     type:   "credit",
                     amount: 41580,
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
      expect(Rental.all).to_not be_nil
      expect(Car.all).to_not be_nil
      expect(Option.all).to_not be_nil

      expected = {
        id:      3,
        options: [],
        actions: [
                   {
                     who:    "driver",
                     type:   "debit",
                     amount: 27800
                   },
                   {
                     who:    "owner",
                     type:   "credit",
                     amount: 19460,
                   },
                   {
                     who:    "insurance",
                     type:   "credit",
                     amount: 4170,
                   },
                   {
                     who:    "assistance",
                     type:   "credit",
                     amount: 1200,
                   },
                   {
                     who:    "drivy",
                     type:   "credit",
                     amount: 2970
                   }
                 ]
      }

      expect(Rental.all.last.to_h).to eq(expected)

      expected = {
        id:            1,
        price_per_day: 2000,
        price_per_km:  10
      }

      car = Car.all.first
      expect(car.id).to eq(expected[:id])
      expect(car.price_per_day).to eq(expected[:price_per_day])
      expect(car.price_per_km).to eq(expected[:price_per_km])

      expect(Option.all.first.type).to eq('gps')

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
