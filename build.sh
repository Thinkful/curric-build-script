#! /usr/bin/env bash

#set target
if [ "$CIRCLE_BRANCH" == "master" ]
then
    export TARGET="production"
else
    export TARGET="preview"
fi

echo "****** Installing gulp ******"
npm install -g gulp

echo "****** Installing thinkdown2 ******"
npm install -g thunderbird

echo "****** Running thinkdown2 ******"
echo "thinkdown2 $TARGET --build=$CURRICULA_FOLDER/thinkdown2/$CODE/$VERSION"
thinkdown2 $TARGET --build=${CURRICULA_FOLDER}/thinkdown2/${CODE}/${VERSION}

if [ -e ${CURRICULA_FOLDER}/thinkdown2/${CODE}/${VERSION}/curriculum.json ]
then
    echo "Thinkdown completed and curriculum.json exists."
else
    echo "Thinkdown exited, it has failed, curriculum.json not found."
    exit 1
fi

if [ -e ${CURRICULA_FOLDER}/thinkdown2/${CODE}/${VERSION}/syllabus.json ]
then
    echo "syllabus.json exists."
else
    echo "syllabus.json does not exist."
fi
