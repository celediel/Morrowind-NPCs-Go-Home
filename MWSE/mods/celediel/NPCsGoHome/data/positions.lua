-- for spawning NPCs into cells or their homes
return {
    -- home positions for NPCS
    npcs = {
        -- Seyda Neen, vanilla
        ["Eldafire"] = {position = {-213.27, -5.37, -123.42}, orientation = {0.00, 0.00, 1.57}},
        ["Erene Llenim"] = {position = {-23.87, 109.84, 16.71}, orientation = {0.00, 0.00, 2.77}},
        ["Fargoth"] = {position = {58.65, 89.09, -123.50}, orientation = {0.00, 0.00, -3.01}},
        ["Indrele Rathryon"] = {position = {31.86, -16.17, 26.38}, orientation = {0.00, 0.00, 0.93}},
        ["Vodunius Nuccius"] = {position = {15.47, 24.62, -137.08}, orientation = {0.00, 0.00, -3.10}},

        -- Balmora, vanilla
        ["Rarayn Radarys"] = {position = {136.23, 132.69, 7.00}, orientation = {0.00, 0.00, -3.14}},
        ["Dralosa Athren"] = {position = {190.74, 91.01, 7.00}, orientation = {0.00, 0.00, -1.55}},
        ["Balyn Omarel"] = {position = {259.97, 54.13, 7.00}, orientation = {0.00, 0.00, -1.97}},
        ["Dralcea Arethi"] = {position = {185.27, -64.19, 7.00}, orientation = {0.00, 0.00, 0.02}},

        -- Ald-Ruhn, vanilla
        ["Aryni Orethi"] = {position = {12.19, 387.82, -254.00}, orientation = {0.00, 0.00, 3.11}},
        ["Dandera Selaro"] = {position = {-15.23, 357.65, -124.36}, orientation = {0.00, 0.00, 3.12}},
        ["Gindrala Hleran"] = {position = {30.24, 358.76, -126.00}, orientation = {0.00, 0.00, -3.07}},
        ["Tauryon"] = {position = {-94.82, 315.39, -126.00}, orientation = {0.00, 0.00, 2.57}},

        -- Hla Oad, vanilla
        ["Fadila Balvel"] = {position = {4058.02, 4268.32, 8147.63}, orientation = {0.00, 0.00, -2.27}},
        ["Relien Rirne"] = {position = {4120.17, 2938.51, 14676.96}, orientation = {0.00, 0.00, -2.51}},

        -- Gnaar Mok
        ["Anglalos"] = {position = {4043.17, 4186.94, 15124.96}, orientation = {0.00, 0.00, -3.02}},
        ["Caryarel"] = {position = {4084.50, 4114.05, 15124.96}, orientation = {0.00, 0.00, -2.90}},
        ["Nadene Rotheran"] = {position = {4173.37, 4272.18, 14623.57}, orientation = {0.00, 0.00, -2.65}},

        -- Caldera
        ["Nedhelas"] = {position = {-235.15, 3.21, -123.42}, orientation = {0.00, 0.00, 1.77}}
    },

    -- todo: find a way to pick this with code instead
    -- positions picked from a list for public houses
    cells = {
        -- {{{ Vvardenfell
        -- {{{ Balmora
        ["Balmora, Lucky Lockup"] = {
            {position = {222.87, 1290.63, -505.00}, orientation = {0.00, 0.00, -2.54}},
            {position = {-10.30, 757.07, -505.00}, orientation = {0.00, 0.00, -0.04}},
            {position = {5.55, 996.71, -504.11}, orientation = {0.00, 0.00, -0.01}},
            {position = {221.29, 1358.15, -505.00}, orientation = {0.00, 0.00, -3.10}},
            {position = {334.71, 913.76, -505.00}, orientation = {0.00, 0.00, -3.10}}
        },
        ["Balmora, Council Club"] = {
            {position = {-62.33, -31.99, 7.00}, orientation = {0.00, 0.00, 0.82}},
            {position = {579.51, -1.70, -249.00}, orientation = {0.00, 0.00, -0.64}},
            {position = {406.88, 590.81, -249.00}, orientation = {0.00, 0.00, 3.09}},
            {position = {-36.75, 269.06, -249.00}, orientation = {0.00, 0.00, 1.05}},
            {position = {-716.66, 719.97, -505.00}, orientation = {0.00, 0.00, 1.42}},
            {position = {-1.61, -200.41, -249.00}, orientation = {0.00, 0.00, -0.02}},
            {position = {-272.50, 71.34, -249.00}, orientation = {0.00, 0.00, 1.28}}
        },
        ["Balmora, Eight Plates"] = {
            {position = {463.41, -333.82, -249.00}, orientation = {0.00, 0.00, -0.50}},
            {position = {426.63, -320.01, -249.00}, orientation = {0.00, 0.00, -0.92}},
            {position = {-215.54, 486.13, -249.00}, orientation = {0.00, 0.00, 0.96}},
            {position = {-236.28, 820.92, -249.00}, orientation = {0.00, 0.00, -0.03}},
            {position = {-109.68, 823.78, -249.00}, orientation = {0.00, 0.00, -0.07}},
            {position = {-28.39, 822.93, -249.00}, orientation = {0.00, 0.00, 0.02}},
            {position = {59.99, 823.30, -249.00}, orientation = {0.00, 0.00, -0.02}},
            {position = {187.22, 919.89, -249.00}, orientation = {0.00, 0.00, -1.50}},
            {position = {185.86, 984.72, -249.00}, orientation = {0.00, 0.00, -1.55}},
            {position = {187.40, 1075.68, -249.00}, orientation = {0.00, 0.00, -1.65}},
            {position = {190.35, 1164.61, -249.00}, orientation = {0.00, 0.00, -1.53}},
            {position = {404.83, 1090.28, -249.00}, orientation = {0.00, 0.00, -0.61}},
            {position = {587.57, 1348.27, -249.00}, orientation = {0.00, 0.00, -2.48}},
            {position = {118.16, -274.01, 7.00}, orientation = {0.00, 0.00, -1.56}},
            {position = {61.89, -207.22, 7.00}, orientation = {0.00, 0.00, 1.49}}
        },
        ["Balmora, South Wall Cornerclub"] = {
            {position = {32.41, 586.87, 7.00}, orientation = {0.00, 0.00, 2.96}},
            {position = {-278.73, -77.59, -249.00}, orientation = {0.00, 0.00, 0.44}},
            {position = {301.04, -21.29, -249.00}, orientation = {0.00, 0.00, -0.69}},
            {position = {382.68, 300.45, -249.00}, orientation = {0.00, 0.00, -0.12}},
            {position = {468.77, 465.61, -249.00}, orientation = {0.00, 0.00, -1.59}},
            {position = {467.71, 588.84, -249.00}, orientation = {0.00, 0.00, -1.59}},
            {position = {446.45, 716.87, -249.00}, orientation = {0.00, 0.00, -2.51}},
            {position = {820.65, 692.28, -249.00}, orientation = {0.00, 0.00, -1.65}},
            {position = {806.36, 296.22, -217.31}, orientation = {0.00, 0.00, -1.11}},
            {position = {337.37, 737.83, -249.00}, orientation = {0.00, 0.00, 3.09}}
        },
        ["Balmora, South Wall Den Of Iniquity"] = {
            {position = {239.72, 589.39, -249.00}, orientation = {0.00, 0.00, -2.86}},
            {position = {241.20, 588.73, -249.00}, orientation = {0.00, 0.00, -1.62}},
            {position = {245.71, 471.54, -249.00}, orientation = {0.00, 0.00, -1.52}},
            {position = {158.42, 334.12, -249.00}, orientation = {0.00, 0.00, -0.14}},
            {position = {544.37, 441.53, -249.00}, orientation = {0.00, 0.00, 0.65}},
            {position = {640.98, 786.91, -248.08}, orientation = {0.00, 0.00, 1.56}},
            {position = {581.22, 644.53, -248.08}, orientation = {0.00, 0.00, 2.71}}
        },
        ["Balmora, Temple"] = {
            {position = {4376.65, 4854.57, 14738.00}, orientation = {0.00, 0.00, -1.55}},
            {position = {3794.23, 5211.92, 14738.00}, orientation = {0.00, 0.00, -1.88}},
            {position = {3788.64, 5015.97, 14738.00}, orientation = {0.00, 0.00, -1.59}},
            {position = {4445.33, 3818.36, 14738.00}, orientation = {0.00, 0.00, 1.37}},
            {position = {4634.63, 3624.07, 14738.00}, orientation = {0.00, 0.00, 0.08}},
            {position = {4649.12, 4140.44, 14738.00}, orientation = {0.00, 0.00, 2.97}},
            {position = {4928.52, 3988.65, 14738.00}, orientation = {0.00, 0.00, 1.41}},
            {position = {4905.70, 3724.60, 14738.00}, orientation = {0.00, 0.00, 1.41}},
            {position = {4566.90, 4000.76, 14994.00}, orientation = {0.00, 0.00, 2.48}},
            {position = {4010.41, 4025.20, 14994.00}, orientation = {0.00, 0.00, -2.40}},
            {position = {4002.15, 4362.62, 14994.00}, orientation = {0.00, 0.00, -1.50}},
            {position = {3883.06, 5028.78, 14994.00}, orientation = {0.00, 0.00, 3.11}},
            {position = {4017.98, 5033.10, 14994.00}, orientation = {0.00, 0.00, 3.11}},
            {position = {4265.54, 4859.36, 14994.00}, orientation = {0.00, 0.00, 0.09}},
            {position = {4688.08, 5028.28, 14994.00}, orientation = {0.00, 0.00, 3.09}},
            {position = {4560.71, 5023.61, 14994.00}, orientation = {0.00, 0.00, 3.08}},
            {position = {4150.35, 4027.17, 15261.95}, orientation = {0.00, 0.00, 0.55}},
            {position = {4018.50, 4139.81, 15262.07}, orientation = {0.00, 0.00, 0.85}},
            {position = {3952.61, 4291.36, 15262.11}, orientation = {0.00, 0.00, 1.38}},
            {position = {3968.40, 4476.93, 15262.01}, orientation = {0.00, 0.00, 1.72}},
            {position = {4029.23, 4661.15, 15262.12}, orientation = {0.00, 0.00, 2.32}},
            {position = {4136.10, 4766.56, 15262.10}, orientation = {0.00, 0.00, 2.75}},
            {position = {4426.29, 4777.21, 15262.12}, orientation = {0.00, 0.00, -2.68}},
            {position = {4606.59, 4602.62, 15262.24}, orientation = {0.00, 0.00, -2.11}},
            {position = {4655.46, 4386.72, 15262.25}, orientation = {0.00, 0.00, -1.55}},
            {position = {4571.42, 4113.65, 15262.22}, orientation = {0.00, 0.00, -0.98}},
            {position = {4442.48, 3981.70, 15262.20}, orientation = {0.00, 0.00, -0.42}},
            {position = {4289.16, 3445.38, 14226.00}, orientation = {0.00, 0.00, 3.12}},
            {position = {4612.15, 3057.99, 14226.00}, orientation = {0.00, 0.00, 1.08}},
            {position = {4650.32, 3580.35, 14226.00}, orientation = {0.00, 0.00, 1.41}},
            {position = {4749.69, 4067.32, 14226.00}, orientation = {0.00, 0.00, 0.16}},
            {position = {3914.98, 3632.41, 14226.00}, orientation = {0.00, 0.00, -1.69}},
            {position = {3932.40, 3168.32, 14226.00}, orientation = {0.00, 0.00, -2.12}},
            {position = {3774.62, 4069.76, 14226.00}, orientation = {0.00, 0.00, -0.02}}
        },
        ["Balmora, Morag Tong Guild"] = {
            {position = {359.47, 358.09, 9.88}, orientation = {0.00, 0.00, -1.66}},
            {position = {902.58, 436.94, 9.69}, orientation = {0.00, 0.00, -1.90}},
            {position = {1077.50, 284.22, 9.69}, orientation = {0.00, 0.00, 2.99}},
            {position = {1109.53, -199.75, 9.69}, orientation = {0.00, 0.00, 3.09}},
            {position = {897.73, -200.37, 9.69}, orientation = {0.00, 0.00, 3.10}},
            {position = {1168.76, 17.80, 7.00}, orientation = {0.00, 0.00, -1.68}},
            {position = {12.37, 51.53, 7.00}, orientation = {0.00, 0.00, 3.01}},
            {position = {315.16, -260.68, 9.88}, orientation = {0.00, 0.00, -0.24}},
            {position = {-172.78, -153.71, 9.88}, orientation = {0.00, 0.00, 1.51}},
            {position = {251.52, 1053.12, 266.16}, orientation = {0.00, 0.00, 2.02}}
        },
        -- }}}

        -- {{{ Gnisis
        ["Gnisis, Madach Tradehouse"] = {
            {position = {-625.02, 305.07, -894.00}, orientation = {0.00, 0.00, 2.46}},
            {position = {100.10, -49.81, -894.00}, orientation = {0.00, 0.00, -2.84}},
            {position = {-420.28, -723.51, -894.00}, orientation = {0.00, 0.00, 0.29}},
            {position = {575.21, -719.01, -894.00}, orientation = {0.00, 0.00, -0.74}},
            {position = {873.63, 173.11, -894.00}, orientation = {0.00, 0.00, 2.76}},
            {position = {659.33, 225.69, -894.00}, orientation = {0.00, 0.00, -2.37}},
            {position = {-237.97, 153.85, -126.00}, orientation = {0.00, 0.00, -1.77}},
            {position = {-238.99, 253.70, -126.00}, orientation = {0.00, 0.00, -1.66}},
            {position = {-242.53, 359.42, -126.00}, orientation = {0.00, 0.00, -2.30}},
            {position = {25.28, 568.43, -126.00}, orientation = {0.00, 0.00, -3.09}},
            {position = {231.21, 241.74, -126.00}, orientation = {0.00, 0.00, -1.47}},
            {position = {-23.55, 250.11, -382.00}, orientation = {0.00, 0.00, -1.47}}
        },
        ["Gnisis, Fort Darius"] = {
            {position = {-53.93, 519.00, -126.00}, orientation = {0.00, 0.00, 3.09}},
            {position = {14.06, 231.89, -382.00}, orientation = {0.00, 0.00, 1.37}},
            {position = {276.92, 314.82, -371.95}, orientation = {0.00, 0.00, 2.76}},
            {position = {185.69, 240.55, -371.95}, orientation = {0.00, 0.00, 2.08}},
            {position = {269.97, 531.29, -382.00}, orientation = {0.00, 0.00, -2.14}},
            {position = {-265.57, 886.74, -382.00}, orientation = {0.00, 0.00, 1.37}},
            {position = {-6.38, 773.91, -382.00}, orientation = {0.00, 0.00, -1.36}},
            {position = {693.12, 279.94, 130.00}, orientation = {0.00, 0.00, -1.12}},
            {position = {-1166.08, 319.61, -254.00}, orientation = {0.00, 0.00, 3.12}},
            {position = {-1368.90, 232.95, -254.00}, orientation = {0.00, 0.00, -0.39}},
            {position = {-1728.43, 172.37, -254.00}, orientation = {0.00, 0.00, 0.91}}
        },
        -- }}}

        -- {{{ Ald-Ruhn
        ["Ald-ruhn, The Rat In The Pot"] = {
            {position = {154.18, 425.84, 2.00}, orientation = {0.00, 0.00, 0.64}},
            {position = {19.49, 429.50, 2.00}, orientation = {0.00, 0.00, -1.60}},
            {position = {16.32, 517.69, 2.00}, orientation = {0.00, 0.00, -1.49}},
            {position = {18.28, 643.34, 2.00}, orientation = {0.00, 0.00, -1.52}},
            {position = {19.79, 429.49, 2.00}, orientation = {0.00, 0.00, -1.60}},
            {position = {-3.88, 281.16, 2.00}, orientation = {0.00, 0.00, -0.44}},
            {position = {-117.24, 278.73, 2.00}, orientation = {0.00, 0.00, 0.02}},
            {position = {-304.90, 274.83, 2.00}, orientation = {0.00, 0.00, -0.02}},
            {position = {-394.37, 279.30, 2.00}, orientation = {0.00, 0.00, -0.05}},
            {position = {-110.95, 308.02, -254.00}, orientation = {0.00, 0.00, -0.09}},
            {position = {-347.46, 652.76, -254.00}, orientation = {0.00, 0.00, 1.93}},
            {position = {-112.87, 694.26, -254.00}, orientation = {0.00, 0.00, -1.68}},
            {position = {-99.06, 802.53, -254.00}, orientation = {0.00, 0.00, 1.56}},
            {position = {139.54, 812.52, -254.00}, orientation = {0.00, 0.00, -1.63}},
            {position = {111.24, 694.92, -254.00}, orientation = {0.00, 0.00, -1.63}},
            {position = {701.44, -91.77, -510.00}, orientation = {0.00, 0.00, -1.82}},
            {position = {402.54, -694.76, -510.00}, orientation = {0.00, 0.00, -0.21}},
            {position = {-594.88, -618.74, -510.00}, orientation = {0.00, 0.00, 0.34}},
            {position = {-703.68, 16.55, -510.00}, orientation = {0.00, 0.00, 1.66}},
            {position = {-347.25, 403.67, -510.00}, orientation = {0.00, 0.00, 2.75}},
            {position = {485.94, 416.56, -510.00}, orientation = {0.00, 0.00, -2.32}},
            {position = {625.61, 414.57, -510.00}, orientation = {0.00, 0.00, 2.88}},
            {position = {-35.49, 731.88, -510.00}, orientation = {0.00, 0.00, -1.53}},
            {position = {-211.77, 641.18, -510.00}, orientation = {0.00, 0.00, 1.48}},
            {position = {-680.81, 211.37, -482.86}, orientation = {0.00, 0.00, 1.72}},
            {position = {-682.71, 335.97, -482.86}, orientation = {0.00, 0.00, 2.12}},
            {position = {-595.91, 435.92, -482.86}, orientation = {0.00, 0.00, 2.63}},
            {position = {-482.90, 419.23, -482.86}, orientation = {0.00, 0.00, -3.03}}
        },
        ["Ald-ruhn, Temple"] = {
            {position = {4123.62, 4697.31, 14722.00}, orientation = {0.00, 0.00, -1.57}},
            {position = {3956.22, 5074.02, 14722.00}, orientation = {0.00, 0.00, 0.17}},
            {position = {4117.64, 5041.25, 14724.57}, orientation = {0.00, 0.00, -1.64}},
            {position = {4126.39, 3822.76, 14722.00}, orientation = {0.00, 0.00, 1.92}},
            {position = {4132.21, 3596.93, 14722.00}, orientation = {0.00, 0.00, 0.98}},
            {position = {4319.00, 3463.75, 14722.00}, orientation = {0.00, 0.00, 0.21}},
            {position = {4606.23, 3831.38, 14722.00}, orientation = {0.00, 0.00, 1.44}},
            {position = {4548.21, 3607.98, 14722.00}, orientation = {0.00, 0.00, 1.82}},
            {position = {4326.29, 3981.72, 14722.00}, orientation = {0.00, 0.00, 2.97}},
            {position = {4142.42, 4353.57, 14722.00}, orientation = {0.00, 0.00, 1.58}},
            {position = {4042.08, 3726.49, 14978.00}, orientation = {0.00, 0.00, -2.97}},
            {position = {4315.64, 3606.87, 14978.00}, orientation = {0.00, 0.00, -0.14}},
            {position = {4371.59, 4829.50, 14978.00}, orientation = {0.00, 0.00, -2.36}},
            {position = {3967.30, 4645.47, 14980.79}, orientation = {0.00, 0.00, -0.03}},
            {position = {3692.51, 4616.50, 14978.00}, orientation = {0.00, 0.00, -1.60}},
            {position = {3565.53, 4906.61, 14978.00}, orientation = {0.00, 0.00, 2.46}},
            {position = {3676.71, 3845.17, 14978.00}, orientation = {0.00, 0.00, -1.60}},
            {position = {3552.35, 3606.81, 14978.00}, orientation = {0.00, 0.00, 0.75}},
            {position = {3763.71, 3903.79, 15246.03}, orientation = {0.00, 0.00, 0.61}},
            {position = {3667.59, 4143.41, 15245.88}, orientation = {0.00, 0.00, 1.42}},
            {position = {3659.07, 4332.60, 15245.98}, orientation = {0.00, 0.00, 1.78}},
            {position = {3770.04, 4560.66, 15246.07}, orientation = {0.00, 0.00, 2.41}},
            {position = {4147.16, 4577.37, 15246.07}, orientation = {0.00, 0.00, -2.56}},
            {position = {4302.24, 4388.21, 15246.23}, orientation = {0.00, 0.00, -1.78}},
            {position = {4332.40, 4193.77, 15246.25}, orientation = {0.00, 0.00, -1.50}},
            {position = {4235.76, 3962.36, 15246.11}, orientation = {0.00, 0.00, -0.99}},
            {position = {4102.95, 3880.86, 15245.88}, orientation = {0.00, 0.00, -0.44}},
            {position = {3966.24, 3561.04, 14210.00}, orientation = {0.00, 0.00, 3.14}},
            {position = {4296.27, 3436.92, 14210.00}, orientation = {0.00, 0.00, 1.35}},
            {position = {4411.64, 3634.21, 14210.00}, orientation = {0.00, 0.00, 2.84}},
            {position = {4431.93, 3943.37, 14210.00}, orientation = {0.00, 0.00, 0.16}},
            {position = {3640.05, 3570.30, 14210.00}, orientation = {0.00, 0.00, -2.24}},
            {position = {3437.45, 3893.05, 14210.00}, orientation = {0.00, 0.00, -0.07}}
        },
        ["Ald-ruhn, Ald Skar Inn"] = {
            {position = {924.71, -1207.86, -510.00}, orientation = {0.00, 0.00, 0.83}},
            {position = {1342.69, -948.50, -509.22}, orientation = {0.00, 0.00, -0.14}},
            {position = {1363.15, -563.75, -509.70}, orientation = {0.00, 0.00, -2.75}},
            {position = {1345.69, -444.17, -509.76}, orientation = {0.00, 0.00, -1.32}},
            {position = {962.96, -330.06, -510.00}, orientation = {0.00, 0.00, -3.12}},
            {position = {1049.05, -327.75, -510.00}, orientation = {0.00, 0.00, -3.14}},
            {position = {759.03, -378.16, -508.62}, orientation = {0.00, 0.00, -1.55}},
            {position = {655.97, -540.04, -510.00}, orientation = {0.00, 0.00, -2.95}},
            {position = {468.22, -381.53, -508.62}, orientation = {0.00, 0.00, 1.21}},
            {position = {324.66, -722.79, -510.00}, orientation = {0.00, 0.00, -3.03}},
            {position = {494.33, -759.56, -510.00}, orientation = {0.00, 0.00, -1.48}},
            {position = {278.66, -398.08, -509.03}, orientation = {0.00, 0.00, -1.47}},
            {position = {148.89, -551.71, -510.00}, orientation = {0.00, 0.00, -2.90}},
            {position = {-39.59, -385.43, -509.03}, orientation = {0.00, 0.00, 1.62}},
            {position = {-279.34, -1080.13, -496.34}, orientation = {0.00, 0.00, -2.96}},
            {position = {-159.01, -1176.50, -496.34}, orientation = {0.00, 0.00, -1.53}},
            {position = {-572.05, -838.71, -508.71}, orientation = {0.00, 0.00, 1.85}},
            {position = {-582.41, -691.73, -508.71}, orientation = {0.00, 0.00, 1.44}},
            {position = {-582.32, -323.78, -508.71}, orientation = {0.00, 0.00, 1.73}},
            {position = {-182.35, -334.96, -510.00}, orientation = {0.00, 0.00, 3.02}},
            {position = {-336.51, -311.08, -510.00}, orientation = {0.00, 0.00, 3.09}},
            {position = {429.72, -1551.44, 2.00}, orientation = {0.00, 0.00, 3.08}},
            {position = {317.13, -1536.22, 2.00}, orientation = {0.00, 0.00, 3.08}},
            {position = {143.69, -1625.25, 2.00}, orientation = {0.00, 0.00, 1.76}},
            {position = {694.06, -1160.40, 2.00}, orientation = {0.00, 0.00, 3.11}},
            {position = {817.18, -1297.80, 2.00}, orientation = {0.00, 0.00, -1.69}},
            {position = {710.14, -1418.49, 2.00}, orientation = {0.00, 0.00, -0.06}},
            {position = {774.76, -1429.21, 2.00}, orientation = {0.00, 0.00, -2.99}},
            {position = {632.04, -1588.25, 2.00}, orientation = {0.00, 0.00, 1.37}},
            {position = {580.04, -1798.04, 2.00}, orientation = {0.00, 0.00, -0.31}},
            {position = {757.37, -1393.00, -254.00}, orientation = {0.00, 0.00, 2.97}},
            {position = {708.70, -1687.83, -254.00}, orientation = {0.00, 0.00, -1.77}},
            {position = {499.70, -1357.05, -254.00}, orientation = {0.00, 0.00, 1.39}},
            {position = {224.21, -1370.48, -254.00}, orientation = {0.00, 0.00, 1.45}},
            {position = {251.70, -1797.68, -254.00}, orientation = {0.00, 0.00, 1.58}},
            {position = {251.90, -1721.04, -254.00}, orientation = {0.00, 0.00, 1.58}}
        },
        -- }}}

        -- {{{ Sadrith Mora
        ["Sadrith Mora, Dirty Muriel's Cornerclub"] = {
            {position = {-180.96, -23.31, 386.00}, orientation = {0.00, 0.00, 1.36}},
            {position = {-182.36, 50.53, 387.99}, orientation = {0.00, 0.00, 1.55}},
            {position = {-92.94, 174.84, 387.35}, orientation = {0.00, 0.00, 3.12}},
            {position = {-49.42, 275.62, 387.35}, orientation = {0.00, 0.00, 1.56}},
            {position = {-213.36, 263.85, 387.99}, orientation = {0.00, 0.00, -1.46}},
            {position = {-172.63, -143.05, 387.99}, orientation = {0.00, 0.00, -1.51}},
            {position = {-46.89, -568.11, 387.99}, orientation = {0.00, 0.00, -0.07}},
            {position = {74.00, -553.98, 386.00}, orientation = {0.00, 0.00, -0.07}},
            {position = {-204.03, -281.63, 132.37}, orientation = {0.00, 0.00, -1.73}},
            {position = {-192.90, -195.83, 132.37}, orientation = {0.00, 0.00, -1.66}},
            {position = {-104.57, -418.53, 131.84}, orientation = {0.00, 0.00, 3.06}}
        },
        -- }}}

        -- {{{ Hla Oad
        -- ? maybe, maybe not ?
        -- ["Hla Oad, Fatleg's Drop Off"] = {},
        -- ["Hla Oad, The Drop Off"] = {},
        -- }}}

        -- {{{ Pelagiad
        ["Pelagiad, Halfway Tavern"] = {
            {position = {-53.46, -300.18, 2.00}, orientation = {0.00, 0.00, 0.26}},
            {position = {171.16, -73.97, 2.00}, orientation = {0.00, 0.00, -2.43}},
            {position = {293.28, 294.99, 2.00}, orientation = {0.00, 0.00, -0.04}},
            {position = {360.19, 296.12, 2.00}, orientation = {0.00, 0.00, -0.04}},
            {position = {428.74, 297.33, 2.00}, orientation = {0.00, 0.00, -0.23}},
            {position = {500.92, 405.54, 2.00}, orientation = {0.00, 0.00, -1.59}},
            {position = {826.17, 509.89, 2.00}, orientation = {0.00, 0.00, -2.43}},
            {position = {732.58, 462.36, 2.00}, orientation = {0.00, 0.00, -2.54}},
            {position = {530.07, -84.56, 2.00}, orientation = {0.00, 0.00, -1.15}},
            {position = {403.12, -14.35, 2.00}, orientation = {0.00, 0.00, 1.58}},
            {position = {401.25, 51.01, 2.00}, orientation = {0.00, 0.00, 1.51}},
            {position = {249.69, 749.41, -254.00}, orientation = {0.00, 0.00, 2.55}},
            {position = {468.77, 265.65, -254.00}, orientation = {0.00, 0.00, 2.58}},
            {position = {251.22, 332.29, -254.00}, orientation = {0.00, 0.00, -2.57}},
            {position = {569.66, 121.96, 258.00}, orientation = {0.00, 0.00, 0.24}},
            {position = {786.80, -296.05, 258.00}, orientation = {0.00, 0.00, -0.08}}
        },
        -- }}}

        -- {{{ Gnaar Mok
        ["Gnaar Mok, Druegh-jigger's Rest"] = {
            {position = {3957.30, 3969.36, 14481.53}, orientation = {0.00, 0.00, 1.09}},
            {position = {3949.90, 4105.69, 14481.53}, orientation = {0.00, 0.00, 1.62}},
            {position = {4134.70, 4252.04, 14481.53}, orientation = {0.00, 0.00, 0.10}},
            {position = {4300.35, 4302.60, 14481.53}, orientation = {0.00, 0.00, -2.86}},
            {position = {4346.93, 3962.00, 14481.53}, orientation = {0.00, 0.00, -1.21}},
            {position = {4215.60, 3912.02, 14481.53}, orientation = {0.00, 0.00, 0.89}},
            {position = {4127.97, 4100.41, 14481.53}, orientation = {0.00, 0.00, -1.71}}
        },
        -- }}}

        -- {{{ Caldera
        ["Caldera, Shenk's Shovel"] = {
            {position = {76.14, 1.11, 130.00}, orientation = {0.00, 0.00, 1.45}},
            {position = {125.18, -105.21, 130.00}, orientation = {0.00, 0.00, 0.47}},
            {position = {268.91, -128.54, 130.00}, orientation = {0.00, 0.00, -0.05}},
            {position = {370.32, -123.93, 134.13}, orientation = {0.00, 0.00, -0.05}},
            {position = {480.65, -117.58, 134.13}, orientation = {0.00, 0.00, -0.05}},
            {position = {554.92, -311.51, 130.00}, orientation = {0.00, 0.00, -1.36}},
            {position = {-37.23, -547.36, 130.00}, orientation = {0.00, 0.00, 0.49}},
            {position = {-61.29, 406.96, 130.00}, orientation = {0.00, 0.00, 0.70}},
            {position = {68.72, 578.33, 130.00}, orientation = {0.00, 0.00, -2.60}},
            {position = {-71.46, 588.34, 130.00}, orientation = {0.00, 0.00, 2.53}},
            {position = {336.74, 186.69, 130.00}, orientation = {0.00, 0.00, -0.89}},
            {position = {142.95, 221.89, 130.00}, orientation = {0.00, 0.00, 0.89}},
            {position = {215.56, 379.49, 130.00}, orientation = {0.00, 0.00, -3.12}},
            {position = {594.85, 59.74, 386.00}, orientation = {0.00, 0.00, -2.67}},
            {position = {586.76, -564.72, 386.00}, orientation = {0.00, 0.00, -1.41}},
            {position = {16.14, -429.27, 386.00}, orientation = {0.00, 0.00, 3.12}},
            {position = {-22.40, 64.39, 419.04}, orientation = {0.00, 0.00, 1.64}},
            {position = {-78.76, 53.74, 642.00}, orientation = {0.00, 0.00, 2.00}},
            {position = {-51.95, -243.29, 642.00}, orientation = {0.00, 0.00, 1.44}},
            {position = {334.04, -173.96, 642.00}, orientation = {0.00, 0.00, -2.89}},
            {position = {100.93, -575.35, 642.00}, orientation = {0.00, 0.00, -1.04}}
        },
        -- }}}

        -- {{{ Suran
        ["Suran, Desele's House of Earthly Delights"] = {
            {position = {-108.34, -220.51, 265.00}, orientation = {0.00, 0.00, 1.97}},
            {position = {-269.44, -225.96, 265.00}, orientation = {0.00, 0.00, -3.12}},
            {position = {-22.04, -92.09, 265.00}, orientation = {0.00, 0.00, -3.11}},
            {position = {-43.25, -60.40, 265.00}, orientation = {0.00, 0.00, 1.09}},
            {position = {-459.20, -80.04, 263.00}, orientation = {0.00, 0.00, -1.84}},
            {position = {-559.84, -783.53, 264.17}, orientation = {0.00, 0.00, 1.19}},
            {position = {40.33, -818.81, 7.00}, orientation = {0.00, 0.00, -0.56}}
        },
        -- }}}

        -- {{{ Molag Mar
        -- cantons
        ["Molag Mar, Waistworks"] = {
            {position = {213.32, 527.80, -958.00}, orientation = {0.00, 0.00, 3.03}},
            {position = {4.79, 515.48, -948.53}, orientation = {0.00, 0.00, -3.06}},
            {position = {-284.06, 515.07, -948.12}, orientation = {0.00, 0.00, 3.08}},
            {position = {-410.04, 349.79, -958.00}, orientation = {0.00, 0.00, 1.53}},
            {position = {-398.84, 117.78, -958.00}, orientation = {0.00, 0.00, 1.53}},
            {position = {-388.71, -165.33, -949.25}, orientation = {0.00, 0.00, 1.71}},
            {position = {-245.13, -264.15, -953.20}, orientation = {0.00, 0.00, 0.04}},
            {position = {38.90, -273.30, -958.00}, orientation = {0.00, 0.00, 0.02}},
            {position = {328.22, -275.49, -958.00}, orientation = {0.00, 0.00, -0.00}},
            {position = {396.90, -71.06, -957.44}, orientation = {0.00, 0.00, -1.71}},
            {position = {424.84, 210.13, -958.00}, orientation = {0.00, 0.00, -1.65}},
            {position = {387.46, 475.91, -948.86}, orientation = {0.00, 0.00, -1.60}},
            {position = {266.33, 344.34, -1214.00}, orientation = {0.00, 0.00, -1.82}},
            {position = {48.29, 357.84, -1214.00}, orientation = {0.00, 0.00, 0.99}},
            {position = {-70.91, 312.76, -1214.00}, orientation = {0.00, 0.00, -0.66}},
            {position = {-223.38, 299.56, -1214.00}, orientation = {0.00, 0.00, 0.66}},
            {position = {-93.66, -85.75, -1214.00}, orientation = {0.00, 0.00, 2.44}},
            {position = {87.46, -103.46, -1214.00}, orientation = {0.00, 0.00, -2.22}},
            {position = {261.59, -110.35, -1214.00}, orientation = {0.00, 0.00, -0.16}},
            {position = {-286.66, -15.18, -1214.00}, orientation = {0.00, 0.00, 1.09}}
        },
        -- public spaces
        ["Molag Mar, Temple"] = {
            {position = {2.24, 189.94, 12.80}, orientation = {0.00, 0.00, -3.08}},
            {position = {146.72, 138.88, 12.80}, orientation = {0.00, 0.00, -2.71}},
            {position = {191.69, -4.14, 14.87}, orientation = {0.00, 0.00, -1.53}},
            {position = {-110.92, 185.00, 12.80}, orientation = {0.00, 0.00, 2.80}},
            {position = {-207.61, 4.95, 14.89}, orientation = {0.00, 0.00, 1.61}},
            {position = {-8.85, -376.09, 2.00}, orientation = {0.00, 0.00, -3.13}},
            {position = {516.68, 60.91, 2.00}, orientation = {0.00, 0.00, -1.74}},
            {position = {518.65, -49.65, 2.00}, orientation = {0.00, 0.00, -1.67}},
            {position = {-395.19, 80.69, -254.00}, orientation = {0.00, 0.00, -3.09}},
            {position = {-571.83, 63.91, -254.00}, orientation = {0.00, 0.00, 1.60}},
            {position = {78.52, 127.53, -254.00}, orientation = {0.00, 0.00, -2.83}},
            {position = {130.31, -7.97, -254.00}, orientation = {0.00, 0.00, -1.66}},
            {position = {1273.15, -455.03, -252.12}, orientation = {0.00, 0.00, -0.79}}
        },
        ["Molag Mar, St. Veloth's Hostel"] = {
            {position = {4160.26, 3906.16, 15554.00}, orientation = {0.00, 0.00, 0.02}},
            {position = {4069.98, 4004.76, 15554.00}, orientation = {0.00, 0.00, 1.25}},
            {position = {3869.26, 3893.23, 15554.00}, orientation = {0.00, 0.00, -2.61}},
            {position = {3729.06, 3898.95, 15554.00}, orientation = {0.00, 0.00, 3.07}},
            {position = {3565.69, 3907.93, 15554.00}, orientation = {0.00, 0.00, 3.05}},
            {position = {3417.14, 4125.15, 15554.00}, orientation = {0.00, 0.00, -0.18}},
            {position = {3469.29, 4265.61, 15554.00}, orientation = {0.00, 0.00, -2.07}},
            {position = {3426.97, 4003.59, 15300.39}, orientation = {0.00, 0.00, -0.22}},
            {position = {3607.49, 3734.34, 15300.39}, orientation = {0.00, 0.00, -0.14}},
            {position = {3971.19, 3946.15, 15298.00}, orientation = {0.00, 0.00, -1.79}},
            {position = {3757.05, 4086.39, 15298.00}, orientation = {0.00, 0.00, -3.11}},
            {position = {3720.15, 4472.21, 15298.00}, orientation = {0.00, 0.00, 1.86}},
            {position = {3874.18, 4578.54, 15298.00}, orientation = {0.00, 0.00, 3.03}},
            {position = {4364.12, 3898.59, 15302.37}, orientation = {0.00, 0.00, -1.87}}
        },
        -- }}}

        -- {{{ Ebonheart
        ["Ebonheart, Six Fishes"] = {
            {position = {290.34, 561.52, 2.00}, orientation = {0.00, 0.00, 1.65}},
            {position = {283.08, 482.31, 2.00}, orientation = {0.00, 0.00, 1.52}},
            {position = {306.77, 347.78, 2.00}, orientation = {0.00, 0.00, 1.05}},
            {position = {456.64, 294.88, 2.00}, orientation = {0.00, 0.00, -0.35}},
            {position = {194.05, 340.76, 2.00}, orientation = {0.00, 0.00, -0.89}},
            {position = {42.56, 476.67, 2.00}, orientation = {0.00, 0.00, 2.32}},
            {position = {-35.04, 244.08, 2.00}, orientation = {0.00, 0.00, 2.31}},
            {position = {-29.01, 88.22, 2.00}, orientation = {0.00, 0.00, 0.66}},
            {position = {96.12, 85.94, 2.00}, orientation = {0.00, 0.00, -0.63}},
            {position = {87.74, 233.73, 2.00}, orientation = {0.00, 0.00, -2.39}},
            {position = {-90.63, -88.38, 2.00}, orientation = {0.00, 0.00, -2.20}},
            {position = {-267.03, -58.82, 2.00}, orientation = {0.00, 0.00, 2.55}},
            {position = {64.28, -290.37, 2.00}, orientation = {0.00, 0.00, -0.92}}
        },
        -- }}}

        -- {{{ Vivec
        -- cantons
        ["Vivec, Arena Waistworks"] = {
            {position = {4935.70, 5099.57, 18050.00}, orientation = {0.00, 0.00, -2.11}},
            {position = {3481.49, 4232.53, 18050.00}, orientation = {0.00, 0.00, -1.71}},
            {position = {3348.72, 3782.08, 18050.00}, orientation = {0.00, 0.00, 0.41}},
            {position = {4092.16, 3939.02, 18050.00}, orientation = {0.00, 0.00, 0.59}},
            {position = {4355.49, 4045.92, 18050.00}, orientation = {0.00, 0.00, -0.09}},
            {position = {4298.64, 4266.86, 18050.00}, orientation = {0.00, 0.00, -1.76}},
            {position = {4128.06, 4247.50, 18050.00}, orientation = {0.00, 0.00, -2.92}},
            {position = {5161.25, 3827.25, 18050.00}, orientation = {0.00, 0.00, -0.67}},
            {position = {2511.11, 3785.64, 18050.00}, orientation = {0.00, 0.00, 1.58}},
            {position = {3378.72, 3546.21, 18050.00}, orientation = {0.00, 0.00, 1.07}},
            {position = {3353.38, 4664.91, 18050.00}, orientation = {0.00, 0.00, 1.86}},
            {position = {4310.78, 3532.53, 18050.00}, orientation = {0.00, 0.00, -0.62}},
            {position = {4312.45, 4636.14, 18050.00}, orientation = {0.00, 0.00, -1.52}}
        },
        ["Vivec, Foreign Quarter Lower Waistworks"] = {
            {position = {4779.61, 3880.70, 13442.00}, orientation = {0.00, 0.00, -1.05}},
            {position = {4105.09, 3881.06, 13186.00}, orientation = {0.00, 0.00, -0.03}},
            {position = {4093.57, 4283.46, 13186.00}, orientation = {0.00, 0.00, 1.83}},
            {position = {4645.03, 4295.68, 13186.00}, orientation = {0.00, 0.00, -2.91}},
            {position = {4597.47, 3921.74, 13186.00}, orientation = {0.00, 0.00, -0.95}},
            {position = {4309.95, 4584.29, 13442.00}, orientation = {0.00, 0.00, -2.79}}
        },
        ["Vivec, Foreign Quarter Upper Waistworks"] = {
            {position = {4332.56, 4347.65, 14850.00}, orientation = {0.00, 0.00, 1.08}},
            {position = {4109.29, 4586.61, 14850.00}, orientation = {0.00, 0.00, -0.04}},
            {position = {3865.10, 4360.15, 14850.00}, orientation = {0.00, 0.00, -1.85}},
            {position = {4065.00, 4118.35, 14850.00}, orientation = {0.00, 0.00, 2.89}},
            {position = {4375.37, 3909.21, 14850.00}, orientation = {0.00, 0.00, -1.36}},
            {position = {3533.95, 3888.58, 14850.00}, orientation = {0.00, 0.00, 0.55}},
            {position = {3573.93, 4794.15, 14850.00}, orientation = {0.00, 0.00, 1.37}},
            {position = {4314.55, 3879.18, 14850.00}, orientation = {0.00, 0.00, 1.11}},
            {position = {4552.39, 4336.22, 14850.00}, orientation = {0.00, 0.00, -2.08}},
            {position = {3901.25, 4789.88, 14850.00}, orientation = {0.00, 0.00, 1.86}}
        },
        ["Vivec, Foreign Quarter Waistworks"] = {
            -- rethinking Vivec
        },
        ["Vivec, Hlaalu Waistworks"] = {
            {position = {778.54, 775.58, -382.00}, orientation = {0.00, 0.00, -1.75}},
            {position = {786.02, 678.91, -382.00}, orientation = {0.00, 0.00, -1.75}},
            {position = {785.16, 248.36, -382.00}, orientation = {0.00, 0.00, -1.45}},
            {position = {786.13, 346.62, -382.00}, orientation = {0.00, 0.00, -1.45}},
            {position = {234.32, 261.68, -382.00}, orientation = {0.00, 0.00, 1.68}},
            {position = {229.51, 355.00, -382.00}, orientation = {0.00, 0.00, 1.69}},
            {position = {229.64, 788.49, -382.00}, orientation = {0.00, 0.00, 1.49}},
            {position = {233.38, 687.96, -382.00}, orientation = {0.00, 0.00, 1.53}},
            {position = {377.48, 528.47, -359.43}, orientation = {0.00, 0.00, 1.74}},
            {position = {110.50, 273.31, -126.00}, orientation = {0.00, 0.00, 1.60}},
            {position = {272.72, 909.88, -126.00}, orientation = {0.00, 0.00, -3.09}},
            {position = {718.80, 905.15, -122.20}, orientation = {0.00, 0.00, 3.06}},
            {position = {914.77, 614.96, -126.00}, orientation = {0.00, 0.00, -1.54}}
        },
        ["Vivec, Redoran Waistworks"] = {
            {position = {-135.48, -100.64, 135.98}, orientation = {0.00, 0.00, 1.48}},
            {position = {-131.52, -391.19, 139.93}, orientation = {0.00, 0.00, 1.48}},
            {position = {68.58, -648.48, 134.47}, orientation = {0.00, 0.00, 0.15}},
            {position = {287.54, -648.93, 134.02}, orientation = {0.00, 0.00, 0.02}},
            {position = {517.86, -650.56, 132.39}, orientation = {0.00, 0.00, 0.02}},
            {position = {655.46, -408.73, 130.00}, orientation = {0.00, 0.00, -1.40}},
            {position = {200.89, -157.18, -103.43}, orientation = {0.00, 0.00, 1.23}},
            {position = {399.57, -293.32, -103.43}, orientation = {0.00, 0.00, -2.23}},
            {position = {323.47, -412.84, -108.98}, orientation = {0.00, 0.00, -1.66}},
            {position = {209.63, -7.48, -126.00}, orientation = {0.00, 0.00, -3.05}},
            {position = {-161.87, -282.26, 130.00}, orientation = {0.00, 0.00, 1.53}},
            {position = {88.59, 133.76, 137.19}, orientation = {0.00, 0.00, 2.55}},
            {position = {381.78, 150.12, 130.00}, orientation = {0.00, 0.00, 2.63}}
        },
        ["Vivec, Telvanni Waistworks"] = {
            {position = {345.63, -904.81, -121.87}, orientation = {0.00, 0.00, -0.00}},
            {position = {547.84, -901.60, -118.65}, orientation = {0.00, 0.00, -0.00}},
            {position = {742.85, -899.58, -116.63}, orientation = {0.00, 0.00, -0.00}},
            {position = {910.50, -735.11, -126.00}, orientation = {0.00, 0.00, -1.39}},
            {position = {912.00, -513.89, -126.00}, orientation = {0.00, 0.00, -1.63}},
            {position = {899.64, -293.19, -116.19}, orientation = {0.00, 0.00, -1.50}},
            {position = {750.49, -114.17, -126.00}, orientation = {0.00, 0.00, 3.03}},
            {position = {511.54, -82.49, -126.00}, orientation = {0.00, 0.00, 3.03}},
            {position = {247.86, -116.58, -124.47}, orientation = {0.00, 0.00, 3.03}},
            {position = {691.46, -187.50, -376.43}, orientation = {0.00, 0.00, 2.96}},
            {position = {817.33, -343.56, -382.00}, orientation = {0.00, 0.00, -2.60}},
            {position = {805.17, -693.27, -382.00}, orientation = {0.00, 0.00, -1.65}},
            {position = {555.62, -790.82, -382.00}, orientation = {0.00, 0.00, -0.08}},
            {position = {443.63, -790.89, -382.00}, orientation = {0.00, 0.00, -0.08}},
            {position = {240.16, -307.64, -382.00}, orientation = {0.00, 0.00, 1.36}},
            {position = {250.84, -696.10, -382.00}, orientation = {0.00, 0.00, 1.20}},
            {position = {114.37, -710.82, -126.00}, orientation = {0.00, 0.00, 1.18}}
        },
        ["Vivec, St. Delyn Waistworks"] = {
            {position = {310.29, -755.88, -126.00}, orientation = {0.00, 0.00, -0.01}},
            {position = {705.58, -770.98, -126.00}, orientation = {0.00, 0.00, -0.13}},
            {position = {716.52, -252.58, -126.00}, orientation = {0.00, 0.00, -3.12}},
            {position = {313.63, -250.03, -126.00}, orientation = {0.00, 0.00, 3.07}},
            {position = {497.90, -108.36, 130.00}, orientation = {0.00, 0.00, 3.13}},
            {position = {929.60, -380.29, 130.00}, orientation = {0.00, 0.00, -1.63}},
            {position = {920.01, -591.86, 130.00}, orientation = {0.00, 0.00, -1.63}},
            {position = {739.60, -917.90, 130.00}, orientation = {0.00, 0.00, -0.47}},
            {position = {457.17, -914.89, 130.00}, orientation = {0.00, 0.00, -0.32}}
        },
        ["Vivec, St. Olms Waistworks"] = {
            {position = {311.26, -911.36, -126.00}, orientation = {0.00, 0.00, -0.03}},
            {position = {531.22, -900.78, -117.83}, orientation = {0.00, 0.00, -0.03}},
            {position = {773.62, -899.03, -116.08}, orientation = {0.00, 0.00, -0.03}},
            {position = {939.04, -752.03, -123.59}, orientation = {0.00, 0.00, -1.54}},
            {position = {941.86, -530.50, -126.00}, orientation = {0.00, 0.00, -1.54}},
            {position = {944.76, -268.61, -126.00}, orientation = {0.00, 0.00, -1.61}},
            {position = {812.26, -118.18, -122.87}, orientation = {0.00, 0.00, -3.10}},
            {position = {592.80, -111.69, -126.00}, orientation = {0.00, 0.00, -3.11}},
            {position = {238.09, -124.69, -116.36}, orientation = {0.00, 0.00, 3.07}},
            {position = {152.00, -293.40, -120.54}, orientation = {0.00, 0.00, 1.46}},
            {position = {156.50, -543.01, -116.05}, orientation = {0.00, 0.00, 1.54}},
            {position = {155.84, -827.16, -116.70}, orientation = {0.00, 0.00, 1.56}},
            {position = {242.12, -688.58, -382.00}, orientation = {0.00, 0.00, 0.93}},
            {position = {809.40, -749.61, -382.00}, orientation = {0.00, 0.00, 0.35}},
            {position = {806.65, -313.38, -382.00}, orientation = {0.00, 0.00, -2.22}},
            {position = {219.91, -304.45, -376.39}, orientation = {0.00, 0.00, 1.99}}
        },
        -- public spaces
        ["Vivec, Black Shalk Cornerclub"] = {
            {position = {670.25, -950.57, -318.00}, orientation = {0.00, 0.00, -2.41}},
            {position = {524.95, -958.40, -318.00}, orientation = {0.00, 0.00, 2.47}},
            {position = {408.90, -826.91, -318.00}, orientation = {0.00, 0.00, 0.08}},
            {position = {615.04, -704.82, -318.00}, orientation = {0.00, 0.00, 1.51}},
            {position = {622.61, -502.62, -318.00}, orientation = {0.00, 0.00, 1.55}},
            {position = {629.35, -236.27, -318.00}, orientation = {0.00, 0.00, 0.00}},
            {position = {206.25, -258.17, -318.00}, orientation = {0.00, 0.00, -1.90}},
            {position = {136.03, -72.00, -318.00}, orientation = {0.00, 0.00, 3.07}},
            {position = {208.83, 242.04, -318.00}, orientation = {0.00, 0.00, -3.09}},
            {position = {326.40, 259.17, -318.00}, orientation = {0.00, 0.00, 2.64}},
            {position = {657.09, 276.60, -318.00}, orientation = {0.00, 0.00, -3.06}},
            {position = {634.31, 85.01, -318.00}, orientation = {0.00, 0.00, 0.18}},
            {position = {465.71, 99.84, -318.00}, orientation = {0.00, 0.00, -0.91}}
        },
        -- }}}
        -- }}}

        -- {{{ Mainland Morrowind
        -- {{{ Almas Thirr
        -- cantons
        ["Almas Thirr, Waistworks"] = {
            {position = {5257.20, 3614.06, 12034.00}, orientation = {0.00, 0.00, 3.08}},
            {position = {4838.67, 3592.44, 12034.00}, orientation = {0.00, 0.00, 3.14}},
            {position = {4736.85, 2533.22, 12034.00}, orientation = {0.00, 0.00, 0.15}},
            {position = {5298.11, 2072.02, 12035.29}, orientation = {0.00, 0.00, 3.05}},
            {position = {5205.03, 2055.23, 12035.29}, orientation = {0.00, 0.00, 3.12}},
            {position = {5763.51, 2530.47, 12034.00}, orientation = {0.00, 0.00, 0.50}},
            {position = {5639.44, 4088.63, 12034.00}, orientation = {0.00, 0.00, -0.39}},
            {position = {5335.43, 4083.18, 12034.00}, orientation = {0.00, 0.00, -0.47}},
            {position = {5216.86, 4070.39, 12034.00}, orientation = {0.00, 0.00, -0.10}},
            {position = {4842.84, 4091.39, 12034.00}, orientation = {0.00, 0.00, -0.13}},
            {position = {4728.14, 5123.60, 12034.00}, orientation = {0.00, 0.00, 2.63}},
            {position = {5251.99, 4534.71, 12065.88}, orientation = {0.00, 0.00, -0.19}},
            {position = {5774.66, 5304.96, 12290.00}, orientation = {0.00, 0.00, -1.55}},
            {position = {4848.35, 5378.74, 12290.00}, orientation = {0.00, 0.00, 3.09}},
            {position = {4563.61, 4407.18, 12290.00}, orientation = {0.00, 0.00, 1.90}},
            {position = {4536.89, 3502.34, 12290.00}, orientation = {0.00, 0.00, 2.16}},
            {position = {4722.35, 2376.24, 12290.00}, orientation = {0.00, 0.00, 0.42}}
        },
        -- public spaces
        ["Almas Thirr, Canalworks Temple"] = {
            {position = {4197.91, 6825.42, 8962.00}, orientation = {0.00, 0.00, 3.03}},
            {position = {3905.75, 6802.21, 8962.00}, orientation = {0.00, 0.00, 3.00}},
            {position = {4015.18, 6831.25, 8962.00}, orientation = {0.00, 0.00, 3.06}},
            {position = {3968.57, 6694.26, 8962.00}, orientation = {0.00, 0.00, 3.04}},
            {position = {4047.08, 6712.05, 8962.00}, orientation = {0.00, 0.00, 3.03}},
            {position = {4202.87, 6706.79, 8962.55}, orientation = {0.00, 0.00, 3.11}},
            {position = {3952.43, 7222.09, 8963.29}, orientation = {0.00, 0.00, 0.56}},
            {position = {3202.58, 7219.05, 8972.79}, orientation = {0.00, 0.00, -0.33}},
            {position = {3044.80, 6860.65, 8962.00}, orientation = {0.00, 0.00, -3.11}},
            {position = {2933.09, 6832.00, 8972.79}, orientation = {0.00, 0.00, 2.77}},
            {position = {3232.95, 6810.64, 8962.00}, orientation = {0.00, 0.00, -2.77}},
            {position = {3463.89, 7671.45, 8972.79}, orientation = {0.00, 0.00, 0.57}},
            {position = {3699.30, 7678.87, 8972.79}, orientation = {0.00, 0.00, -0.95}},
            {position = {3100.34, 7522.52, 8962.00}, orientation = {0.00, 0.00, 1.72}}
        }
        -- }}}
        -- }}}
    }
}
