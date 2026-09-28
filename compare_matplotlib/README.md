# Comparison with Matplotlib

Performance comparison between slisvg and Matplotlib for the same two-dimensional slice visualization, which includes

- Contour lines
- Filled contours
- Vector arrows

## Requirements

- gfortran
- GNU make
- Python 3 with NumPy and Matplotlib (or [uv](https://docs.astral.sh/uv/))

You must build the slisvg library via `cd ../src && make install`. The `make install` command creates the `lib` directory in the parent directory of this directory, as shown below:

```
slisvg/
├── compare_matplotlib
├── lib
├── src
└── ...
```

## Usage

First, you must generate the data to be plotted by slisvg and Matplotlib. The following command generates time-dependent three-dimensional data, and must be executed in `slisvg/compare_matplotlib`.

```sh
cd compare_matplotlib  # if needed
bash ./generate_data.sh 21 10
```

The first argument is the number of grid points (`num_grid` in `./generate_data.sh`). The same grid number is used in the x, y and z directions. The second argument is the number of time steps (`num_time` in `./generate_data.sh`). The generated data are stored as `./data/data_0000.txt`, `./data/data_0001.txt`, and so on, one file per time step. By default, this shell script calls `./script/generate_data.py`.

You can use the following command to compare slisvg and Matplotlib for plotting the generated data:

```sh
cd compare_matplotlib  # if needed
bash ./compare.sh
```

Similarly, this command must also be executed in `slisvg/compare_matplotlib`. This shell script calls `./script/use_matplotlib.py` and `./script/use_slisvg.f90`, and generates `num_grid * num_time` SVG files in `./output/matplotlib` and `./output/slisvg`, respectively. The script measures the time taken to load the data and the time taken to plot them. In addition, it reports the memory usage.
