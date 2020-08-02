-- for spawning NPCs into cells or their homes
return {
    -- home positions for NPCS
    npcs = {
        -- Balmora, vanilla
        ["Rarayn Radarys"] = {position = {136.23, 132.69, 7.00}, orientation = {0.00, 0.00, -3.14}},
        ["Dralosa Athren"] = {position = {190.74, 91.01, 7.00}, orientation = {0.00, 0.00, -1.55}},
        ["Balyn Omarel"] = {position = {0, 0, 0}, orientation = {0, 0, 0}},
        ["Dralcea Arethi"] = {position = {0, 0, 0}, orientation = {0, 0, 0}}
    },
    -- positions picked from a list for public houses
    cells = {
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
        ["Balmora, South Wall Cornerclub (mod)"] = {
            {position = {239.72, 589.39, -249.00}, orientation = {0.00, 0.00, -2.86}},
            {position = {241.20, 588.73, -249.00}, orientation = {0.00, 0.00, -1.62}},
            {position = {245.71, 471.54, -249.00}, orientation = {0.00, 0.00, -1.52}},
            {position = {158.42, 334.12, -249.00}, orientation = {0.00, 0.00, -0.14}},
            {position = {544.37, 441.53, -249.00}, orientation = {0.00, 0.00, 0.65}},
            {position = {640.98, 786.91, -248.08}, orientation = {0.00, 0.00, 1.56}},
            {position = {581.22, 644.53, -248.08}, orientation = {0.00, 0.00, 2.71}}
        },
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
        }
    }
}
