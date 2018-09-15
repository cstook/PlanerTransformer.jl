export @prisec_str

macro prisec_str(s)
  a = Array{Bool}(0)
  pos = 1
  done = false
  while ~done
    m = match(r"[sp]"i,s,pos)
    if m!=nothing
      pos = m.offset + 1
      push!(a, m.match in ("P","p"))
    else
      done = true
    end
  end
  (a...)
end
