@testset "FerriteProperties" begin
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
@test specificpowerloss(test_fp.spl_hot,0.2,15e3)≈41282.42493233671
@test specificpowerloss(test_fp.spl_hot,0.1,50e3)≈33312.32948194469
@test specificpowerloss(test_fp.spl_hot,0.07,150e3)≈39764.72237401459
@test specificpowerloss(test_fp.spl_hot,0.05,300e3)≈83594.04626141209
@test specificpowerloss(test_fp.spl_hot,0.02,600e3)≈50114.55055175903
@test specificpowerloss(test_fp.spl_hot,0.01,1e6)≈22730.663569664855
@test specificpowerloss(test_fp.spl_hot,0.04,400e3)≈87672.48079453735
@test specificpowerloss(test_fp,0.04,400e3)≈87672.48079453735
@test length(ferrite_dict)>0
# need better inverse function at some point
@test flux_density(test_fp.spl_hot,50114.55055175903,600e3)≈0.02233938496577921
@test flux_density(test_fp,50114.55055175903,600e3)≈0.02233938496577921
end # testset
