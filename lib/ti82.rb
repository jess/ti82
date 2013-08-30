require "ti82/version"
require 'bigdecimal'
require 'bigdecimal/newton'
include Newton

class Function
  # borrowed this function from https://github.com/wkranec/finance
  include Ti82
  values = {
    eps: "1.0e-16",
    one: "1.0",
    two: "2.0",
    ten: "10.0",
    zero: "0.0"
    }

  values.each do |key, value|
    define_method key do
      BigDecimal.new value
    end
  end

  def initialize(transactions, function)
    @transactions = transactions
    @function = function
  end

  def values(x)
    value = send(@function, x[0], *@transactions)
    [ BigDecimal.new(value.to_s) ]
  end
end

module Ti82

  # pmt(rate,number,present_value,future_value,type: 0 = end or 1 = beg)
  def pmt(rate, number, pv, fv, type = 0)
    (
      pv + 
      ( pv + fv ) / 
      ( (1 + rate)**number - 1 )
    ) *
    if type == 0
      ( rate / 1)
    else
      ( rate / (1 + rate))
    end
  end

  def pv(rate, number, payment, fv, type = 0)
    if fv == 0
      payment * ( (1 - (1 / (1 + rate)**number )) / rate ) * -1
    else
      (
        (fv) /  
        ( ( 1 + rate)**number )
      )
    end
  end

  # net present value 
  # npv(0.08, cf0, cf1, cf2...)
  def npv(rate, *cash_flows)
    total = 0
    cash_flows.each_with_index do |cf, index|
      total += cf.to_f / (1 + rate) ** index
    end
    total
  end

  # irr
  # irr(cf0, cf1, cf2...)
  def irr(*cash_flows)
    func = Function.new(cash_flows, :npv)
    rate = [func.one]
    nlsolve(func, rate)
    rate[0].to_f
  end
end
