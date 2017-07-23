export PushPull, Forward

abstract type Converter end
duty(::Converter) = NaN
reset_voltage(::Converter) = NaN

struct PushPull <: Converter
  v_in :: Float64
  i_out :: Float64
  frequency :: Float64
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
  reset_voltage :: Float64
  function Forward(v_in, i_out, frequency, duty=0.50, reset_voltage = -1.5*v_in/duty)
    v_in < 0.0 && throw(ArgumentError("v_in must be positive."))
    i_out > 0.0 && throw(ArgumentError("i_out must be negative"))
    frequency < 0.0 && throw(ArgumentError("frequency must be positive"))
    max_reset_voltage = -v_in/duty
    reset_voltage > max_reset_voltage && throw(ArgumentError("reset voltage must be less than $max_reset_voltage for core reset"))
    new(v_in, i_out, frequency, duty, reset_voltage)
  end
end
v_in(x::Forward) = x.v_in
i_out(x::Forward) = x.i_out
frequency(x::Forward) = x.frequency
duty(x::Forward) = x.duty
reset_voltage(x::Forward) = x.reset_voltage


Forward(5,-1,1e6, 0.79)
