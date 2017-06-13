@testset "CoreGeometry" begin

w1 = Winding(core_geometry_dict["e14"],3,0.2e-3,0.1e-3,
             copper_weight_to_meters(1.0))
@test isapprox(w1.width,0.0011333333333333332)
@test isapprox(w1.length,0.07597344572538565)
@test isapprox(w1.thickness,0.000480)
@test isapprox(w1.number_of_turns,3.00)
@test isapprox(w1.conductivity,1.68e-8)
@test isapprox(w1.temperature_coefficient,0.003862)
@test isapprox(resistance(w1),0.0030711326938981133)
end # testset
