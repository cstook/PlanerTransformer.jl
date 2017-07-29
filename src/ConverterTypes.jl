export PushPull, Forward

abstract type Converter end
v_in(::Converter) = NaN
i_out(::Converter) = NaN
frequency(::Converter) = NaN
duty(::Converter) = NaN

struct PushPull <: Converter
  v_in :: Float64
  i_out :: Float64
  frequency :: Float64
  function PushPull(v_in, i_out, frequency)
    v_in < 0.0 && throw(ArgumentError("v_in must be positive."))
    i_out > 0.0 && throw(ArgumentError("i_out must be negative"))
    frequency < 0.0 && throw(ArgumentError("frequency must be positive"))
    new(v_in, i_out, frequency)
  end
end
v_in(x::PushPull) = x.v_in
i_out(x::PushPull) = x.i_out
frequency(x::PushPull) = x.frequency
duty(::PushPull) = 0.5

struct Forward <: Converter
  v_in :: Float64
  i_out :: Float64
  frequency :: Float64
  duty :: Float64
  function Forward(v_in, i_out, frequency, duty=0.50)
    v_in < 0.0 && throw(ArgumentError("v_in must be positive."))
    i_out > 0.0 && throw(ArgumentError("i_out must be negative"))
    frequency < 0.0 && throw(ArgumentError("frequency must be positive"))
    new(v_in, i_out, frequency, duty)
  end
end
v_in(x::Forward) = x.v_in
i_out(x::Forward) = x.i_out
frequency(x::Forward) = x.frequency
duty(x::Forward) = x.duty
