export core_geometry_dict


const core_geometry_dict = Dict(
  #  Ferrocube data
  "e14_set"=> CoreGeometry("e14_set", 4e-3,     1.5e-3,   5e-3, 300e-9, 14.5e-6, 20.7e-3, 0.6e-3*2.0),
  "e18_set"=> CoreGeometry("e18_set", 5e-3,     2e-3,     10e-3, 960e-9, 39.5e-6, 24.3e-3, 2.4e-3*2.0),
  "e22_set"=> CoreGeometry("e22_set", 5.9e-3,   2.5e-3,   15.8e-3, 2550e-9, 78.5e-6, 32.5e-3, 6.5e-3*2.0),
  "e32_set"=> CoreGeometry("e32_set", 9.27e-3,  3.175e-3, 20.32e-3, 5380e-9, 129e-6, 41.4e-3, 10e-3*2.0),
  "e58_set"=> CoreGeometry("e58_set", 21.4e-3,  4.05e-3,  38.1e-3, 24600e-9, 305e-6, 80.6e-3, 62e-3*2.0),
  "e64_set"=> CoreGeometry("e64_set", 21.8e-3,  5.08e-3,  50.8e-3, 40700e-9, 511e-6, 79.9e-3, 100e-3*2.0),
  "e14_plt"=>CoreGeometry("e14_plt", 4e-3,     1.5e-3,   5e-3, 240e-9, 14.5e-6, 16.7e-3, 0.5e-3+0.6e-3),
  "e18_plt"=>CoreGeometry("e18_plt", 5e-3,     2e-3,     10e-3, 800e-9, 39.5e-6, 20.3e-3, 1.7e-3+2.4e-3),
  "e22_plt"=>CoreGeometry("e22_plt", 5.9e-3,   2.5e-3,   15.8e-3, 2040e-9, 78.5e-6, 26.1e-3, 4e-3+6.5e-3),
  "e32_plt"=>CoreGeometry("e32_plt", 9.27e-3,  3.175e-3, 20.32e-3, 4560e-9, 129e-6, 35.1e-3, 10e-3+10e-3),
  "e58_plt"=>CoreGeometry("e58_plt", 21.4e-3,  4.05e-3,  38.1e-3, 20800e-9, 305e-6, 67.7e-3, 44e-3+62e-3),
  "e64_plt"=>CoreGeometry("e64_plt", 21.8e-3,  5.08e-3,  50.8e-3, 35500e-9, 511e-6, 69.7e-3, 78e-3+100e-3),

  # Magnetics data
  # using _plt instead of _i to be consistent with Ferrocube
  "er9_set"=>CoreGeometry(Magnetics_ER_Input("er9_set",14.2, 8.47, 120, 1, 7.5, 3.5)),
  "er11_set"=>CoreGeometry(Magnetics_ER_Input("er11_set",14.7, 11.9, 174, 1, 8.7, 4.25)),
  "er12.5_set"=>CoreGeometry(Magnetics_ER_Input("er12.5_set",17.5, 19.9, 348, 2, 11.2, 5.0)),
  "er14.5_set"=>CoreGeometry(Magnetics_ER_Input("er14.5_set",19.0, 17.6, 333, 2, 11.6, 4.8)),
  "er18_set"=>CoreGeometry(Magnetics_ER_Input("er18_set",22.1, 30.2, 667, 3, 15.6, 6.2)),
  "er20_set"=>CoreGeometry(Magnetics_ER_Input("er20_set",33.2, 59, 1960, 10.2, 18, 8.8)),
  "er23_set"=>CoreGeometry(Magnetics_ER_Input("er23_set",26.6, 50.2, 1340, 6.4, 20.2, 8.0)),
  "er25/5.5_set"=>CoreGeometry(Magnetics_ER_Input("er25/5.5_set",33.8, 91.8, 3100, 16.4, 22.0, 11.0)),
  "er25/8_set"=>CoreGeometry(Magnetics_ER_Input("er25/8_set",41.4, 100, 4145, 22.0, 22.0, 11.0)),
  "er30_set"=>CoreGeometry(Magnetics_ER_Input("er30_set",46.0, 108, 4970, 26.4, 26.0, 11.0)),
  "er32_set"=>CoreGeometry(Magnetics_ER_Input("er32_set",38.2, 141, 5400, 27.5, 27.2, 12.4)),

  "er12.5_plt"=>CoreGeometry(Magnetics_ER_Input("er12.5_plt",15.9, 19.8, 315, 1, 11.2, 5.0)),
  "er18_plt"=>CoreGeometry(Magnetics_ER_Input("er18_plt",20.3, 40.1, 813, 3.9, 15.6, 6.2)),
  "er20_plt"=>CoreGeometry(Magnetics_ER_Input("er20_plt",22.5, 57.3, 1460, 8, 18, 8.8)),
  "er25/5.5_plt"=>CoreGeometry(Magnetics_ER_Input("er25/5.5_plt",26.4, 89.7, 2370, 13.1, 22.0, 11.0)), #mate with ER 25/5.5/18
  "er30_plt"=>CoreGeometry(Magnetics_ER_Input("er30_plt",36.2, 108, 3910, 20.8, 26.0, 11.0)),
  "er32_plt"=>CoreGeometry(Magnetics_ER_Input("er32_plt",35.1, 130, 4560, 22, 27.2, 12.4)),
  )
