#!/bin/bash

#Checking the input arguments
usage="Usage: vfvs_prepare_zincids2smiles.sh <input_list> <smiles_collection_folder> <smile_collection_folder_format> <output_filename>

The <input_list> has to contain the collection in the first column and the ZINC-ID in the second column.
The colums have to be separated by single spaces.
All path names have to be relative to the working directory.
<smiles_collection_folder_format>
    * tranche: smiles_collection_folder/<tranche>/<collection>.smi
    * meta_tranche: smiles_collection_folder/<metatranche>/<tranche>.smi"

if [ "${1}" == "-h" ]; then
   echo -e "\n${usage}\n\n"
   exit 0 
fi

if [[ "$#" -ne "4" ]]; then
   echo -e "\nWrong number of arguments. Exiting.\n"
   echo -e "${usage}\n\n"
   exit 1
fi

# Standard error response 
error_response_nonstd() {
    echo
    echo
    echo "Error was trapped which is a nonstandard error."
    echo "Error in bash script $(basename ${BASH_SOURCE[0]})"
    echo "Error on line $1"
    echo
    exit 1
}
trap 'error_response_nonstd $LINENO' ERR

clean_exit() {
    echo
}
trap 'clean_exit' EXIT

# Variables
input_file="$1"
smiles_folder="$2"
smiles_folder_format="$3"
output_file="$4"

# Body
while read -r line; do 
    tranche=$(echo -n "$line" | awk -F '[_]' '{print $1}')
    collection=$(echo -n "$line" | awk -F '[_ ]' '{print $2}')
    compound_id=$(echo -n "$line" | awk -F '[ ]' '{print $2}')
    metatranche=${tranche:0:2}
    trap '' ERR
    if [ "${smiles_folder_format}" == "tranche" ]; then
        smiles=$(grep -w "${compound_id/_T*}" ${smiles_folder}/${tranche}/${collection}.* | awk '{print $1}')
    elif [ "${smiles_folder_format}" == "meta_tranche" ]; then
        smiles=$(grep -w "${compound_id/_T*}" ${smiles_folder}/${metatranche}/${tranche}.* | awk '{print $1}')
    fi
    
    if [ -n "${smiles}" ]; then
        echo "${smiles} ${compound_id}" >> ${output_file}
        echo "Compound ${compound_id} of collection ${tranche}_${collection} successfully extracted"
    else 
        echo ${compound_id} ${collection} >> ${output_file}.failed
        echo "Compound ${compound_id} of collection ${tranche}_${collection} failed to extract"
    fi
    trap 'error_response_nonstd $LINENO' ERR
done < "${input_file}"

echo -e "\n * The SMILES of the compounds have been prepared\n\n"
