@testset "TransformerDesign" begin
test_spldata = SplInput((
  25e3,(100,14),(300,270),
  100e3,(62,20,),(240,750),
  200e3,(38,8),(190,1100),
  400e3,(20,17),(140,1700),
  700e3,(12,20),(80,1750)
  ))
test_fp = FerriteProperties(0.2e6:0.5e6,25,100,
                            BHloop(15,.44,.15),
                            BHloop(10,.345,.120),
                            SpecificPowerLossData(test_spldata)) # 3f3
test_cg = CoreGeometry(4e-3,     1.5e-3,   5e-3, 300e-9, 14.5e-6, 0.6e-3) # e14
@test volt_seconds_per_turn(2.0,3.0)≈6.0
@test volt_seconds_per_turn(test_cg,2.0) ≈ 14.5e-6*2.0
@test volts_per_turn(test_cg, test_fp, 150e3, 500e3) ≈ 0.6215194243319582

end # testset
