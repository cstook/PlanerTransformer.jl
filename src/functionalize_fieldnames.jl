
function functionalize_fieldnames(x)
  for field in fieldnames(x)
    @eval $field(y::$x) = y.$field
    @eval export $field
  end
end

methods_to_functionalize = [PCB_Specification,
                            WindingGeometry,
                            Windings,
                            Transformer,
                            TransformerPowerAnalysis,
                            CoreGeometry,
                            FerriteProperties,
                            Conductor,
                            Dielectric,
                            Stackup
                            ]

import Base.length
for m in methods_to_functionalize
  functionalize_fieldnames(m)
end
