import time

import matplotlib.pyplot as plt
import numpy as np

with open('./data/param.txt', 'r') as f:
    for line in f:
        num_grid = int(line.split()[0])
        num_slice = int(line.split()[1])
        num_time = int(line.split()[2])

grid_x = np.empty((num_grid, num_grid))
grid_y = np.empty((num_grid, num_grid))
field3d_u = np.empty((num_grid, num_grid, num_slice))
field3d_v = np.empty((num_grid, num_grid, num_slice))
field3d_w = np.empty((num_grid, num_grid, num_slice))

num_level = 10

time_load = 0
time_plot = 0

for i_t in range(num_time):

    start = time.perf_counter()
    with open(f'./data/data_{i_t:04d}.txt', 'r') as f:
        for line in f:
            i_x, i_y, i_z, x, y, z, u, v, w = line.split()
            i_x = int(i_x)
            i_y = int(i_y)
            i_z = int(i_z)
            x = float(x)
            y = float(y)
            z = float(z)
            u = float(u)
            v = float(v)
            w = float(w)

            grid_x[i_x, i_y] = x
            grid_y[i_x, i_y] = y
            field3d_u[i_x, i_y, i_z] = u
            field3d_v[i_x, i_y, i_z] = v
            field3d_w[i_x, i_y, i_z] = w

    time_load += time.perf_counter() - start

    if i_t == 0:
        l_min = np.min(grid_x)
        l_max = np.max(grid_x)
        v_min = np.min(field3d_w)
        v_max = np.max(field3d_w)
        levels = np.linspace(v_min, v_max, num_level)

    start = time.perf_counter()
    for i_z in range(num_slice):

        fig, ax = plt.subplots(figsize=(800/96, 800/96))

        ax.set_xlim(l_min, l_max)
        ax.set_ylim(l_min, l_max)
        ax.set_aspect('equal')
        ax.axis("off")

        ax.contourf(grid_x, grid_y,
                    field3d_w[:, :, i_z],
                    levels=levels, vmin=v_min, vmax=v_max)
        ax.contour(grid_x, grid_y,
                   field3d_w[:, :, i_z],
                   levels=levels, vmin=v_min, vmax=v_max,
                   colors='black', linewidths=1)
        ax.quiver(grid_x, grid_y,
                  field3d_u[:, :, i_z], field3d_v[:, :, i_z])

        plt.savefig(
            f'./output/matplotlib/slice_{i_z+1:04d}_s={i_t:04d}.svg')
        # plt.savefig(
        #     f'./output/matplotlib/slice_{i_z+1:04d}_s={i_t:04d}.png',
        #     dpi=96)
        plt.close(fig)
    time_plot += time.perf_counter() - start

print(f"Load time: {time_load:.6f} sec")
print(f"Plot time: {time_plot:.6f} sec")
