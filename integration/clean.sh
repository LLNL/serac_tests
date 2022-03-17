#! /bin/bash
# desc: removes non-ats, non-baseline files

ORIG_DIR=$(pwd) # should be ./serac_repo/tests/integration

# for each type,
TYPES=(solid thermal_solid thermal_conduction)
for _type in ${TYPES[@]}
    do

    cd "./${_type}"

    # for each test in directory "t"
    for t in $(ls --color=no) 
        do

        # remove the extra files
        rm -rf "${t}/${t}_serial"
        rm -rf "${t}/${t}_parallel"
    done

    cd ..
done
