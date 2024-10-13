module Getaround
  class Action
    include Helpers
    attr_accessor :who, :type, :amount

    VALIDATIONS = {
      who:    ['driver', 'owner', 'insurance', 'assistance', 'drivy'],
      type:   ['debit', 'credit']
    }

    ACCOUNTING_METHOD_MAP = {
      'driver'     => 'debit',
      'owner'      => 'credit',
      'insurance'  => 'credit',
      'assistance' => 'credit',
      'drivy'      => 'credit'
    }

    def initialize(attrs)
      @who    = attrs[:who]
      @type   = ACCOUNTING_METHOD_MAP[attrs[:who]]
      @amount = attrs[:amount].to_i

      validate_attributes
    end

    def validate_attributes
      validate_enum(:who, who, VALIDATIONS[:who])
      validate_enum(:type, type, VALIDATIONS[:type])
      validate_int(:amount, amount)
    end

    def to_h
      {
        who:    who,
        type:   type,
        amount: amount
      }
    end
  end
end
