#! /bin/bash

export PATH=$PATH:$AGENT_WORKSPACE/slc_cli

echo "PROJECTS_NAME = $PROJECTS_NAME"
echo "AGENT_WORKSPACE = $AGENT_WORKSPACE"
echo "BOARD_ID = $BOARD_IDs"
echo "GIT_BRANCH = $GIT_BRANCH"
echo "GIT_COMMIT = $GIT_COMMIT"

##### GET GIT BRANCH & COMMIT ID #####
PROJECT_BRANCH=${GIT_BRANCH//'/'/'_'}
COMMIT_ID=${GIT_COMMIT:0:8}

##### CLONE OR PULL THE LATEST GSDK FROM GITHUB #####
if [ ! -d gecko_sdk ]
then
    echo "Cloning GSDK... from Github"
    git clone https://github.com/SiliconLabs/gecko_sdk.git
    if [ $? -ne 0 ]
    then 
        echo "Failed to clone GSDK! Exiting..."
        exit 1
    fi
fi
echo "Going to ./gecko_sdk directory & git pull"
cd ./gecko_sdk
git lfs pull origin
git log -n3
GSDK_BRANCH=`git rev-parse --abbrev-ref HEAD`
GSDK_TAG=`git describe --tag`
cd ../

##### CLEAN & CREATE THE OUTPUT FOLDER CONTAINING BINARY HEX FILE #####
rm -rf BIN_*
OUT_FOLDER=BIN_${PROJECT_BRANCH}_${COMMIT_ID}_${GSDK_BRANCH}_${GSDK_TAG}
mkdir $OUT_FOLDER

##### INITIALIZE SDK & TOOLCHAIN #####
slc signature trust --sdk ./gecko_sdk/
slc configuration --sdk ./gecko_sdk/
slc configuration --gcc-toolchain $AGENT_WORKSPACE/gnu_arm

##### SUBSTITUE SEPERATORS (:) OF PROJECT NAMES BY THE WHITE SPACES & CONVERT TO AN ARRAY #####
SEPERATOR=","
WHITESPACE=" "
projects=(${PROJECTS_NAME//$SEPERATOR/$WHITESPACE})
board_ids=(${BOARD_IDs//$SEPERATOR/$WHITESPACE})


echo "board_ids = $board_ids"

##### LOOP THROUGH PROJECTS #####
for project in ${projects[@]}
do 
    echo $project
    if [ -d out_$project ] 
    then
        echo "Removing the older out_$project"
        rm -rf out_$project
    fi

    # Create output project folder
    mkdir out_$project && mkdir ./$OUT_FOLDER/out_$project

    for board_id in ${board_ids[@]}
    do
        echo "board_id = $board_id"

        BRD_PRJ_NAME=${board_id}_${project}
        mkdir ./out_$project/$BRD_PRJ_NAME


        # Generating the projects
        echo "Generating a new out_$project/$BRD_PRJ_NAME"
        slc generate --generator-timeout=180 ./$project/$project.slcp -np \
                    -d out_$project/$BRD_PRJ_NAME -o makefile \
                    --with $board_id,EFM32GG11B820F2048GL192
        if [ $? -ne 0 ];then
            echo "Failed to generate $BRD_PRJ_NAME! Exiting.."
            exit 1
        fi
        
        # Building the projects
        echo "Going to the out_$project/$BRD_PRJ_NAME & building"
        cd ./out_$project/$BRD_PRJ_NAME
        echo "===================> Begin <===================="
        make -j12 -f $project.Makefile clean all
        
        if [ $? -eq 0 ];then
            # Copy the built binary file to output folder & add md5sum 
            cp build/debug/*.hex ../../$OUT_FOLDER
            md5sum build/debug/*.hex >> ../../$OUT_FOLDER/md5sum_check
        else
            echo "Failed to build $BRD_PRJ_NAME! Exiting..."
            exit 1

        fi    
        echo "===================> Finished <=================="
        cd ../../
    done
done

##### PACKAGING THE BINARY OUTPUT FILES #####
tar -cvf $OUT_FOLDER.tar.gz $OUT_FOLDER/*
