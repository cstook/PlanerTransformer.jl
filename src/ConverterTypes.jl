export PushPull, Forward

abstract type Converter end
duty(::Converter) = NaN

type PushPull <: Converter end
duty(::PushPull) = 0.5
type Forward <: Converter end
duty(::Forward) = 1.0
