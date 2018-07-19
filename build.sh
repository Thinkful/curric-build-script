#! /usr/bin/env bash
set -e

#set target
if [ "$CIRCLE_BRANCH" == "master" ]
then
    export TARGET="production"
else
    export TARGET="preview"
fi

#run thunderbird
echo "****** Installing thunderbird ******"
npm install -g gulp
npm install -g thunderbird


echo "****** Running thunderbird ******"
echo "thunderbird $TARGET --build=$CURRICULA_FOLDER/thunderbird/$CODE/$VERSION"
thunderbird $TARGET --build=${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}

if [ -e ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/curriculum.json ]
then
    echo "Thunderbird completed and curriculum.json exists."
else
    echo "Thunderbird exited, it has failed, curriculum.json not found."
    exit 1
fi

if [ -e ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/syllabus.json ]
then
    echo "syllabus.json exists."
else
    echo "syllabus.json does not exist."
fi
