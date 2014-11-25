#! /usr/bin/env bash

#set target
if [ "$CIRCLE_BRANCH" == "test-deploy-script" ]
then
    export TARGET="production"
else
    export TARGET="preview"
fi

#run thinkdown
git clone https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/Thinkful/eagle-flavored-thinkdown thinkdown2
npm install -g gulp

echo "****** Installing thinkdown2 ******"
cd thinkdown2
npm install
npm link
cd ..

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
