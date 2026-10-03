#!/bin/bash

dir_lib="../lib"

dir_script='./script'
dir_output_matplotlib='./output/matplotlib'
dir_output_slisvg='./output/slisvg'
script_matplotlib="${dir_script}/use_matplotlib.py"
script_slisvg="${dir_script}/use_slisvg.f90"

if [[ "$OSTYPE" == "darwin"* ]]; then
    command_time=(/usr/bin/time -l)
else
    command_time=(/usr/bin/time -v)
fi

if [ ! -d "${dir_lib}" ]; then
    echo "Error: ${dir_lib} not found. Run 'cd ../src && make install'."
    exit 1
fi
if [ ! -f ./data/param.txt ]; then
    echo "Error: ./data not found. Run 'bash ./generate_data.sh <num_grid> <num_slice> <num_time>'."
    exit 1
fi

# Execute Python script with matplotlib

echo " --- Matplotlib ---"
mkdir -p "${dir_output_matplotlib}"
rm -f "${dir_output_matplotlib}"/*
if command -v uv > /dev/null 2>&1; then
    "${command_time[@]}" uv run "${script_matplotlib}"
elif command -v python3 > /dev/null 2>&1; then
    "${command_time[@]}" python3 "${script_matplotlib}"
else
    "${command_time[@]}" python "${script_matplotlib}"
fi

echo ''

# Execute slisvg

echo " --- slisvg ---"
mkdir -p "${dir_output_slisvg}"
rm -f "${dir_output_slisvg}"/*
rm -f use_slisvg.o a.out
gfortran -c "${script_slisvg}" -I ${dir_lib}
gfortran use_slisvg.o -I ${dir_lib} -L ${dir_lib} -lslisvg
"${command_time[@]}" ./a.out
rm -f use_slisvg.o a.out