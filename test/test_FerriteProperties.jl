@testset "FerriteProperties" begin
test_spldata = PlanerTransformer.SplInput((
  25e3,(100,14),(300,270),
  100e3,(62,20,),(240,750),
  200e3,(38,8),(190,1100),
  400e3,(20,17),(140,1700),
  700e3,(12,20),(80,1750)
  ))
test_fp = FerriteProperties("3f3",0.2e6,0.5e6,25,100,
                            BHloop(15,.44,.15),
                            BHloop(10,.345,.120),
                            SpecificPowerLossData(test_spldata)) # 3f3
@test specific_power_loss(test_fp.spl_hot,0.2,15e3)≈72926.68854848042
@test specific_power_loss(test_fp.spl_hot,0.1,50e3)≈24158.470844381052
@test specific_power_loss(test_fp.spl_hot,0.07,150e3)≈37883.89793616807
@test specific_power_loss(test_fp.spl_hot,0.05,300e3)≈52475.72366004552
@test specific_power_loss(test_fp.spl_hot,0.02,600e3)≈42277.685735775805
@test specific_power_loss(test_fp.spl_hot,0.01,1e6)≈51375.309340858454
@test specific_power_loss(test_fp.spl_hot,0.04,400e3)≈87672.48079453735
@test specific_power_loss(test_fp,0.04,400e3)≈87672.48079453735
@test length(ferrite_dict)>0
# need better inverse function at some point
@test flux_density(test_fp.spl_hot,42277.685735775805,600e3)≈0.019989634564937644
@test flux_density(test_fp,42277.685735775805,600e3)≈0.019989634564937644




@test_throws ArgumentError SpecificPowerLossData((),())
@test_throws ArgumentError SpecificPowerLossData((1),(2,3))
@test_throws ArgumentError SpecificPowerLossData((1,2,3),((1,10),(2,20)))

@test_throws ArgumentError SpecificPowerLossData(PlanerTransformer.SplInput((1,2,3,4)))
end # testset
