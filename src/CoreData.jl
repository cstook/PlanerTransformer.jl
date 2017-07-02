export core_geometry_dict


core_geometry_dict = Dict(
  #  Ferrocube data
  "e14"=> CoreGeometry(4e-3,     1.5e-3,   5e-3, 300e-9, 14.5e-6, 16.7e-3, 0.6e-3),
  "e18"=> CoreGeometry(5e-3,     2e-3,     10e-3, 960e-9, 39.5e-6, 24.3e-3, 2.4e-3),
  "e22"=> CoreGeometry(5.9e-3,   2.5e-3,   15.8e-3, 2550e-9, 78.5e-6, 32.5e-3, 6.5e-3),
  "e32"=> CoreGeometry(9.27e-3,  3.175e-3, 20.32e-3, 5380e-9, 129e-6, 41.4e-3, 10e-3),
  "e58"=> CoreGeometry(21.4e-3,  4.05e-3,  38.1e-3, 24600e-9, 305e-6, 80.6e-3, 62e-3),
  "e64"=> CoreGeometry(21.8e-3,  5.08e-3,  50.8e-3, 40700e-9, 511e-6, 79.9e-3, 100e-3),
  "plt14"=>CoreGeometry(0, 0, 0, 240e-9, 14.5e-6, 16.7e-3, 0.5e-3),
  "plt18"=>CoreGeometry(0, 0, 0, 800e-9, 39.5e-6, 20.3e-3, 1.7e-3),
  "plt22"=>CoreGeometry(0, 0, 0, 2040e-9, 78.5e-6, 26.1e-3, 4e-3),
  "plt32"=>CoreGeometry(0, 0, 0, 4560e-9, 129e-6, 35.1e-3, 10e-3),
  "plt58"=>CoreGeometry(0, 0, 0, 20800e-9, 305e-6, 67.7e-3, 44e-3),
  "plt64"=>CoreGeometry(0, 0, 0, 35500e-9, 511e-6, 69.7e-3, 78e-3),

  # Magnetics data
  "er9"=>CoreGeometry(Magnetics_ER_Input(14.2, 8.47, 120, 1, 7.5, 3.5)),
  "er11"=>CoreGeometry(Magnetics_ER_Input(14.7, 11.9, 174, 1, 8.7, 4.25)),
  "er12.5"=>CoreGeometry(Magnetics_ER_Input(17.5, 19.9, 348, 2, 11.2, 5.0)),
  "er14.5"=>CoreGeometry(Magnetics_ER_Input(19.0, 17.6, 333, 2, 11.6, 4.8)),
  "er18"=>CoreGeometry(Magnetics_ER_Input(22.1, 30.2, 667, 3, 15.6, 6.2)),
  "er20"=>CoreGeometry(Magnetics_ER_Input(33.2, 59, 1960, 10.2, 18, 8.8)),
  "er23"=>CoreGeometry(Magnetics_ER_Input(26.6, 50.2, 1340, 6.4, 20.2, 8.0)),
  "er25/5.5"=>CoreGeometry(Magnetics_ER_Input(33.8, 91.8, 3100, 16.4, 22.0, 11.0)),
  "er25/8"=>CoreGeometry(Magnetics_ER_Input(41.4, 100, 4145, 22.0, 22.0, 11.0)),
  "er30"=>CoreGeometry(Magnetics_ER_Input(46.0, 108, 4970, 26.4, 26.0, 11.0)),
  "er32"=>CoreGeometry(Magnetics_ER_Input(38.2, 141, 5400, 27.5, 27.2, 12.4)),
  "i12.5"=>CoreGeometry(Magnetics_I_Input(15.9, 19.8, 315, 1)),
  "i18"=>CoreGeometry(Magnetics_I_Input(20.3, 40.1, 813, 3.9)),
  "i20"=>CoreGeometry(Magnetics_I_Input(22.5, 57.3, 1460, 8)),
  "i22"=>CoreGeometry(Magnetics_I_Input(35.1, 130, 4560, 22)),
  "i25"=>CoreGeometry(Magnetics_I_Input(26.4, 89.7, 2370, 13.1)),
  "i30"=>CoreGeometry(Magnetics_I_Input(36.2, 108, 3910, 20.8)),
  "i32"=>CoreGeometry(Magnetics_I_Input(35.1, 130, 4560, 22)),
  )
