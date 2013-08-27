require "ti82/version"

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
end
