#!/bin/bash

# This script checks correctnes of coding style
# WORD OF WARNING: Dear students! Don't write things like that in bash! Please, don't. Use python or something.
# That's not a full Jesus-weeps-horrible but it gets pretty close. I discovered that when I was too deep to bail out.

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

# param - project directory
function check {

    project=$1

    cd ${project}/src/main
    
    declare -A results

    for file in *.c; do
        check_file ${file}
        results["${file}"]=$?
    done

    echo
    echo "##############################################"
    echo 
    echo "TOTAL:"

    for r in ${results[@]}; do
        if [[ $r -eq 1 ]]; then
            echo -e "\e[41mStyle check failed!\e[0m"
            return 1
        fi
    done

    echo -e "\e[30;42mStyle check passed!\e[0m"
    return 0
}

function check_file {

    if [ $# -ne 1 ] 
    then
        echo -e "\e[41mNot enough arguments!\e[0m"
        echo "Arguments are: input file"
        exit 1
    fi

    input=$1

    echo
    echo "****************************************************************************"
    echo "****************************************************************************"
    
    echo
    echo "Starting check of file '${input}'"
    echo
    
    # add newline at the end of the file, otherwise output will be corrupted
    sed -i -e '$a\' ${input}

    # get filename without extension
    input_name="${input%.*}"

    astyle --style=allman --indent=spaces=4 --fill-empty-lines < "${input}" > "${input_name}"_allman_4_spaces.c
    astyle --style=allman --indent=spaces=2 --fill-empty-lines < "${input}" > "${input_name}"_allman_2_spaces.c
    astyle --style=allman --indent=tab      --fill-empty-lines < "${input}" > "${input_name}"_allman_tabs.c

    astyle --style=java --indent=spaces=4 --fill-empty-lines < "${input}" > "${input_name}"_java_4_spaces.c
    astyle --style=java --indent=spaces=2 --fill-empty-lines < "${input}" > "${input_name}"_java_2_spaces.c
    astyle --style=java --indent=tab      --fill-empty-lines < "${input}" > "${input_name}"_java_tabs.c

    correct_files=(
        "${input_name}"_allman_4_spaces.c
        "${input_name}"_allman_2_spaces.c
        "${input_name}"_allman_tabs.c
        "${input_name}"_java_4_spaces.c
        "${input_name}"_java_2_spaces.c
        "${input_name}"_java_tabs.c
       )       
    
    # check how much differences are there between input file and correct ones
    declare -A  diffs

    for f in ${correct_files[@]}; do
      diffs[$f]=$(count_diffs "${input}" "${f}")
    done

    echo 
    echo ----

    # here goes almost unbearable kludge - sorting associative array
    # by sorting strings

    best_match=$(for d in "${!diffs[@]}"; do
        echo $d ':' ${diffs["$d"]}
    done |
    sort -n -k3 | 
    # and then removing everything (apart from the first array key) from the output
    sed s/:.*// | head -n1 | sed 's/[ \t]*$//' )

    # have we found a perfect match?
    if [[ diffs["$best_match"] -eq 0 ]]; then

        # clean up the temporary files
        for f in ${correct_files[@]}; do
          rm  -f ${f}
        done

        echo
        echo -e "\e[30;42mMatching style found!\e[0m It was '${best_match}', wasn't it?"
        return 0
    fi

    echo
    echo -e "\e[41mPerfect style match was not found!\e[0m"
    echo 

    echo "The closest match is estimated as '${best_match}' with ${diffs[${best_match}]} different line(s)"
    echo 
    echo -e "Printing the diff; leading tabs are shown as \e[48;5;90m->\e[0m and spaces as \e[48;5;130m.\e[0m "

    echo 


    # match was not perfect - display the difference
    print_style_diff "${input}" "${best_match}"

    # clean up the temporary files
    for f in ${correct_files[@]}; do
      rm  -f ${f}
    done

    # no style match was found by check_style
    return 1
}

# removes trailing space and
# returns (by echoing) the number of different lines in two files
# args: file_1 and file_2
function count_diffs {

    file_1=$1
    file_2=$2
   
    # remove trailing spaces
    sed -i 's/[[:blank:]]*$//' ${file_1}
    sed -i 's/[[:blank:]]*$//' ${file_2}
    
    different_lines=$(diff -y --suppress-common-lines --ignore-trailing-space ${file_1} ${file_2} | wc -l)

    # since we return value by echoing, printing is done to stderr
    # that's dumb but simple
    printf 'Comparing %s and %-25s; different lines found: %s\n' "$file_1" "$file_2" "$different_lines" >&2
        
    # echo $different_lines >&2
    echo $different_lines
}

function print_style_diff {

    user_file=$1
    correct_file=$2
    
    # get filenames without extension
    user_file_name="${user_file%.*}"
    correct_file_name="${correct_file%.*}"
    
    # replace tab with red '->' and space with yellow '.'
    ${SCRIPTPATH}/replace_tabs_and_spaces  ${user_file} > ${user_file_name}_no_space_no_tab.txt
    ${SCRIPTPATH}/replace_tabs_and_spaces  ${correct_file}  > ${correct_file_name}_no_space_no_tab.txt
    
    # save difference to a temp file
    
    diff --ignore-trailing-space --old-line-format="correct line %2dn: %L" --new-line-format="   your line %2dn: %L" --unchanged-line-format="" \
    ${correct_file_name}_no_space_no_tab.txt ${user_file_name}_no_space_no_tab.txt > diff_output.txt

    # show diff with colors, line by line
    while IFS="" read -r p || [ -n "$p" ]
    do
      echo -e "$p"
    done < diff_output.txt   
}

# set -e
# set -x

echo "Check part 1"

check "${SCRIPTPATH}/../part_1"

res1=$?

echo
echo "-------------------------------"
echo

echo "Check part 2"

check "${SCRIPTPATH}/../part_2"

res2=$?

echo
echo "-------------------------------"
echo

echo "Check part 3"

check "${SCRIPTPATH}/../part_3"

res3=$?

if [[ $res1 = 0 && $res2 = 0 && $res3 == 0 ]]; then
    exit 0
else 
    exit 1
fi


