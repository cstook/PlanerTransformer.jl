
function functionalize_fieldnames(x)
  for field in fieldnames(x)
    @eval $field(y::$x) = y.$field
    @eval export $field
  end
end

methods_to_functionalize = [PCB_Specification,
                            WindingLayer,
                            Winding,
                            Magnetics,
                            Transformer,
                            TransformerPowerDissipation,
                            CoreGeometry,
                            FerriteProperties,
                            ]

import Base.length
for m in methods_to_functionalize
  functionalize_fieldnames(m)
end
