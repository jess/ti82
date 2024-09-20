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
    # Adjust for beginning or end of period payments
    payment = payment / (1 + rate) if type == 1

    # Calculate the present value of annuity (payments)
    pv_annuity = if rate != 0
                   payment * (1 - (1 / (1 + rate)**number)) / rate
                 else
                   payment * number
                 end

    # Calculate the present value of future value
    pv_future_value = fv / (1 + rate)**number

    # Total present value: adding both annuity and future value
    present_value = pv_annuity + pv_future_value

    # Correcting the sign based on cash flow signs
    if payment < 0 && fv >= 0
      present_value.abs
    elsif payment >= 0 && fv < 0
      present_value.abs
    else
      present_value
    end
  end

  # net present value 
  # npv(0.08, cf0, cf1, cf2...)
  def npv(rate, *cash_flows)
    cash_flows.npv(rate).to_f
  end

  # irr
  # irr(cf0, cf1, cf2...)
  def old_irr(*cash_flows)
    # Make sure we have a valid sequence of cash flows.
      positives, negatives = cash_flows.partition{ |i| i >= 0 }
      if positives.empty? || negatives.empty?
        raise ArgumentError, "Calculation does not converge."
      end

      BigDecimal.limit(100)
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

  def irr(*cash_flows, guess: 0.1, tol: 1e-6, max_iter: 100)
    # Validates that there are both positive and negative cash flows
    positives, negatives = cash_flows.partition { |i| i >= 0 }
    if positives.empty? || negatives.empty?
      raise ArgumentError, "Calculation does not converge."
    end

    # Helper functions
    npv = ->(rate) { cash_flows.each_with_index.sum { |cf, i| cf / (1 + rate)**i } }
    npv_derivative = ->(rate) { cash_flows.each_with_index.sum { |cf, i| -i * cf / (1 + rate)**(i + 1) } }

    # Quick check for small sequences where simple solution exists
    if cash_flows.length == 2
      return (cash_flows[1] / -cash_flows[0]) - 1
    end

    # Dynamic bracketing to find suitable initial bounds
    a = -0.99 # lower bound (cannot be less than -1 for IRR)
    b = 1.0   # upper bound

    # Expand bounds dynamically to find initial bracket
    max_iter.times do
      npv_a = npv.call(a)
      npv_b = npv.call(b)

      if npv_a * npv_b < 0
        break # Found initial bounds where root exists
      end

      # Expand the bounds if no root is found in the current range
      a -= 0.5
      b += 0.5
    end

    # If no valid bounds found
    raise "Bisection did not find valid initial bounds" if npv.call(a) * npv.call(b) > 0

    # Bisection method for initial bracketing
    rate = nil
    max_iter.times do
      mid = (a + b) / 2.0
      npv_mid = npv.call(mid)

      if npv_mid.abs < tol # Check for convergence
        rate = mid
        break
      end

      if npv.call(a) * npv_mid < 0
        b = mid
      else
        a = mid
      end
    end

    raise "Bisection did not converge" unless rate

    # Newton-Raphson for refinement
    max_iter.times do
      npv_value = npv.call(rate)
      npv_deriv = npv_derivative.call(rate)

      break if npv_deriv.abs < tol # Avoid division by zero or very small derivative

      new_rate = rate - npv_value / npv_deriv

      return new_rate.to_f if (new_rate - rate).abs < tol # Convergence check

      rate = new_rate
    end

    raise "IRR did not converge"
  end


  def pvrate(n, pmt, pv)
    r = 0.00001
    fv0 = 0
    last_high = 0
    last_low = 0
    lr = 0
    nr = 0
    tries = 0
    pv = pv.round(2)
    until fv0 == pv || tries > 100
      fv0 = ( (pmt/r) * (1 - (1/ ((1+r))**n)) ).round(2)
      tries += 1
      if pv < fv0
        if last_high == 0 && r < lr
          last_high = lr
        end
        if last_low < r
          last_low = r
        end
        if last_high == 0
          nr = r * 2.0
        else
          nr = r + ((last_high - last_low) / 2.0)
        end
        lr = r
        r = nr
      else # high
        nr = r - ((r - last_low)/2.0)
        if r < last_high
          last_high = r
        end
        lr = r
        r = nr
      end
    end
    r.round(6)
  end

  def brate(price, pmt, n, par)
    flows = [price]
    ( n - 1 ).to_i.times{|i| flows << pmt }
    flows << par + pmt
    irr(*flows)
  end

  def fvrate(n, pmt, fv)
    r = 0.00001
    fv0 = 0
    last_high = 0
    last_low = 0
    lr = 0
    nr = 0
    tries = 0
    fv = fv.round(2)
    until fv0 == fv || tries > 100
      fv0 = ( (pmt/r) * ( (1+r)**n - 1 ) ).round(2)
      tries +=
      if fv0 < fv
        if last_high == 0 && r < lr
          last_high = lr
        end
        if last_low < r
          last_low = r
        end
        if last_high == 0
          nr = r * 2.0
        else
          nr = r + ((last_high - last_low) / 2.0)
        end
        lr = r
        r = nr
      else # high
        nr = r - ((r - last_low)/2.0)
        if r < last_high
          last_high = r
        end
        lr = r
        r = nr
      end
    end
    r.round(4)
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
