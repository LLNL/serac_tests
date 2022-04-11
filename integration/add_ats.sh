##############################################################################
# Copyright (c) 2019-2022, Lawrence Livermore National Security, LLC and
# other Serac Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (BSD-3-Clause)
##############################################################################

#! /bin/bash
# Description: Generates new ats files for each test based off input file structure

if [ $# -ne 1 ] ; then
    echo "Usage: ./add_ats.sh <SHOULD_OVERRIDE>"
    exit 1
fi

SHOULD_OVERRIDE=$1

# Give warning if choose to override
if [ ${SHOULD_OVERRIDE} -ne 0 ] ; then
    while true; do
        read -p "Are you sure you want to override ALL the .ats files? (y/n) " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

ORIG_DIR=$(pwd) # should be ./serac_repo/tests/integration
INPUT_DIR="${ORIG_DIR}/../../data/input_files/tests/"
TYPES=(solid thermal_solid thermal_conduction)

# For each test type look at each lua file
cd ${INPUT_DIR}
for _type in ${TYPES[@]} ; do

    # For each test in directory "t"
    cd "./${_type}"
    for t in $(ls --color=no) ; do

        # Remove .lua from file name
        t=$(echo $t | awk -F "." '{print $1}')

        # Skip tests that currently fail
        if [ $t == "dyn_amgx_solve" ] ||
           [ $t == "static_amgx_solve" ] ||
           #[ $t == "qs_attribute_solve" ] ||
           [ $t == "static_reaction_exact" ] ; then
            echo "Skipping $t!"
            continue
        fi

        # Go back to tests/integration
        cd ${ORIG_DIR}

        # Skip ats files that already exist (unless SHOULD_OVERRIDE)
        if [ -f "${_type}/${t}/${t}.ats" ] ; then
            if [ ${SHOULD_OVERRIDE} -ne 0 ] ; then
                echo "Overriding $t!"
            else
                echo "Skipping (already exists) $t!"
                continue
            fi
        fi

        # Create a directory in tests/integration for the new .ats
        if [ ! -d ${_type}/${t} ] ; then
            mkdir -vp ${_type}/${t}
        fi
        cd ${_type}

        # Insert the following text into the ats file
        ATS_FILE="${t}/${t}.ats"
        NAME_SERIAL="${t}_serial"
        NAME_PARALLEL="${t}_parallel"
        INPUT_FILE="{0}/tests/${_type}/${t}.lua"
        TOLERANCE_FILE="{0}/tolerance_default.json"

        echo "##############################################################################" > $ATS_FILE
        echo "# Copyright (c) 2019-2022, Lawrence Livermore National Security, LLC and" >> $ATS_FILE
        echo "# other Serac Project Developers. See the top-level COPYRIGHT file for details." >> $ATS_FILE
        echo "#" >> $ATS_FILE
        echo "# SPDX-License-Identifier: (BSD-3-Clause)" >> $ATS_FILE
        echo "##############################################################################" >> $ATS_FILE
        echo "" >> $ATS_FILE
        echo "tolerance_test(name=\"${NAME_SERIAL}\"," >> $ATS_FILE
        echo "    input_file=\"${INPUT_FILE}\".format(serac_input_files_dir)," >> $ATS_FILE
        echo "    num_mpi_tasks=1," >> $ATS_FILE
        echo "    tolerance=\"${TOLERANCE_FILE}\".format(serac_tolerance_json))" >> $ATS_FILE
        echo "" >> $ATS_FILE
        echo "tolerance_test(name=\"${NAME_PARALLEL}\"," >> $ATS_FILE
        echo "    input_file=\"${INPUT_FILE}\".format(serac_input_files_dir)," >> $ATS_FILE
        echo "    num_mpi_tasks=2," >> $ATS_FILE
        echo "    tolerance=\"${TOLERANCE_FILE}\".format(serac_tolerance_json))" >> $ATS_FILE
        echo "" >> $ATS_FILE

        # Go back to data/input_files/tests for more lua files
        cd ${INPUT_DIR}
    done
done

