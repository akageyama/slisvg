import sys

import numpy as np

name_file = sys.argv[1]
t = int(sys.argv[2])
decay_rate = float(sys.argv[3])
n_l = int(sys.argv[4])

factor = np.exp(-decay_rate * t)

with open(name_file, "w") as f:

    for i in range(n_l+1):
        x = i / n_l

        for j in range(n_l+1):
            y = j / n_l

            for k in range(n_l+1):
                z = k / n_l

                # ===== Calculate an ABC flow =====
                u = (np.sin(2*np.pi*z) + np.cos(2*np.pi*y)) * factor
                v = (np.sin(2*np.pi*x) + np.cos(2*np.pi*z)) * factor
                w = (np.sin(2*np.pi*y) + np.cos(2*np.pi*x)) * factor

                f.write(f"{i} {j} {k} {x} {y} {z} {u} {v} {w}\n")
