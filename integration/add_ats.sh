#! /bin/bash
# desc: generates new ats files for each test based off input file structure

ORIG_DIR=$(pwd) # should be ./serac_repo/tests/integration
INPUT_DIR="${ORIG_DIR}/../../data/input_files/tests/"

# for each type,
TYPES=(solid thermal_solid thermal_conduction)

cd ${INPUT_DIR}

for _type in ${TYPES[@]} ; do

    cd "./${_type}"

    # for each test in directory "t"
    for t in $(ls --color=no) ; do

        # remove .lua from file name
        t=$(echo $t | awk -F "." '{print $1}')

        if [ $t == "dyn_amgx_solve" ] ||
           [ $t == "static_amgx_solve" ] ||
           [ $t == "static_reaction_exact" ] ; then
            
            echo "Skipping $t!"
            
            continue
        fi

        #echo "Writing ats file for ${_type}/${t}..."

        cd ${ORIG_DIR}

        if [ ! -d ${_type}/${t} ] ; then
            mkdir -vp ${_type}/${t}
        fi

        cd ${_type}

        ATS_FILE="${t}/${t}.ats"

        # insert the following text
        NAME_SERIAL="${t}_serial"
        NAME_PARALLEL="${t}_parallel"
        INPUT_FILE="{0}/tests/${_type}/${t}.lua"

        echo "##############################################################################" > ${ATS_FILE}
        echo "# Copyright (c) 2019-2022, Lawrence Livermore National Security, LLC and" >> ${ATS_FILE}
        echo "# other Serac Project Developers. See the top-level COPYRIGHT file for details." >> ${ATS_FILE}
        echo "#" >> ${ATS_FILE}
        echo "# SPDX-License-Identifier: (BSD-3-Clause)" >> ${ATS_FILE}
        echo "##############################################################################" >> ${ATS_FILE}
        echo "" >> ${ATS_FILE}
        echo "tolerance_test(name=\"${NAME_SERIAL}\"," >> ${ATS_FILE}
        echo "    input_file=\"${INPUT_FILE}\".format(serac_input_files_dir))" >> ${ATS_FILE}
        echo "" >> ${ATS_FILE}
        echo "tolerance_test(name=\"${NAME_PARALLEL}\"," >> ${ATS_FILE}
        echo "    input_file=\"${INPUT_FILE}\".format(serac_input_files_dir)," >> ${ATS_FILE}
        echo "    num_mpi_tasks=2)" >> ${ATS_FILE}
        echo "" >> ${ATS_FILE}

        cd ${INPUT_DIR}

    done

done

