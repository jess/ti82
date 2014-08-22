require "ti82/version"
require 'finance'


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
    cash_flows.npv(rate).to_f
  end

  # irr
  # irr(cf0, cf1, cf2...)
  def irr(*cash_flows)
    # Make sure we have a valid sequence of cash flows.
      positives, negatives = cash_flows.partition{ |i| i >= 0 }
      if positives.empty? || negatives.empty?
        raise ArgumentError, "Calculation does not converge."
      end

      func = Finance::Cashflow::Function.new(cash_flows, :npv)
      rate = 0
      methods = [:one, :two, :ten, :eps, :zero]
      methods.each do |method|
        rate = [func.send(method)]
        nlsolve(func, rate)
        rate = rate[0].to_f
        break if rate > 0
      end
      rate
  end

  # Bond price = coupon / y x ( 1 - (1/ (1+y))^N) + face / (1 + y)^N
  # first value / face value
  def solve_for_bond_price(*cash_flows)
    n = cash_flows.size - 1
    first = cash_flows[0].round(3)
    coupon = cash_flows[1]
    fv = cash_flows.last - coupon
    guess = coupon / fv
    price = bond_price(coupon, guess, n, fv)
    until ( price + first ).abs < 0.001 do
      diff = (price + first).abs
      per = (diff / first.abs) * 0.1
      if ( price + first ) > 0
        guess = guess + per
      else
        guess = guess - per
      end
      price = bond_price(coupon, guess, n, fv)
    end
    guess
  end

  def bond_price(coupon, guess, n, fv)
    (coupon / guess) *
      (1 - (1 / ( 1 + guess ))**n) + fv / (1 + guess)**n
  end
end
