#! /bin/bash

if [ $# -ne 1 ] ; then
    echo "./add_ats.sh <SHOULD_CLEAN>"
    exit 1
fi

SHOULD_CLEAN=$1 # remove non-ats, non-baseline files

ORIG_DIR=$(pwd) # should be ./serac_repo/tests/integration

# for each type,
TYPES=(solid thermal_solid thermal_conduction)
for _type in ${TYPES[@]} ; do

    # for each test in directory "t"
    cd "./${_type}"
    for t in $(ls --color=no) ; do

        echo "Writing ats file for ${_type}/${t}..."

        # set dir for new ats file with the name: "t".ats
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

        # remove the extra files
        if [ ${SHOULD_CLEAN} -ne 0 ] ; then
            rm -rf "${t}/${t}_serial"
            rm -rf "${t}/${t}_parallel"
        fi 
    done

    cd ${ORIG_DIR}
done

