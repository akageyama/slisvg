#!/bin/bash

# ===== Parameters =====
num_grid=$1
num_slice=$2
num_time=$3
# ======================

dir_data='./data'
decay_rate=0.1
file_param='./data/param.txt'

use_python=True
script_python='./script/generate_data.py'

# ===== Generate data =====

if [ $# -ne 3 ]; then
    echo "Error: Add three arguments <num_grid>, <num_slice> and <num_time>."
    exit 1
fi

mkdir -p ${dir_data}
echo "${num_grid} ${num_slice} ${num_time}" > "${file_param}"

twopi=`echo "2 * 3.141592653589793238462643383279" | bc -l`
n_l=`echo "(${num_grid}-1)" | bc -l`
n_s=`echo "(${num_slice}-1)" | bc -l`
n_t=`echo "(${num_time}-1)" | bc -l`

for t in `seq 0 ${n_t}`
do
    name_file=`printf "%s/data_%04d.txt" ${dir_data} ${t}`
    rm -f "${name_file}"
    touch "${name_file}"

    if [ "${use_python}" = "True" ]; then

        if command -v uv > /dev/null 2>&1; then
            uv run "${script_python}" ${name_file} ${t} ${decay_rate} ${n_l} ${n_s}
        elif command -v python3 > /dev/null 2>&1; then
            python3 "${script_python}" ${name_file} ${t} ${decay_rate} ${n_l} ${n_s}
        else
            python "${script_python}" ${name_file} ${t} ${decay_rate} ${n_l} ${n_s}
        fi

    else

        factor=`echo "e(-${decay_rate}*${t})" | bc -l`

        for i in `seq 0 ${n_l}`;
        do
            x=`echo "${i} / ${n_l}" | bc -l`

            for j in `seq 0 ${n_l}`
            do
                y=`echo "${j} / ${n_l}" | bc -l`

                for k in `seq 0 ${n_s}`
                do
                    z=`echo "${k} / ${n_s}" | bc -l`

                    # ===== Calculate an ABC flow =====
                    u=`echo "(s(${twopi}*${z}) + c(${twopi}*${y})) * ${factor}" | bc -l`
                    v=`echo "(s(${twopi}*${x}) + c(${twopi}*${z})) * ${factor}" | bc -l`
                    w=`echo "(s(${twopi}*${y}) + c(${twopi}*${x})) * ${factor}" | bc -l`

                    echo "${i} ${j} ${k} ${x} ${y} ${z} ${u} ${v} ${w}" >> "${name_file}"
                done
            done
        done

    fi

done
