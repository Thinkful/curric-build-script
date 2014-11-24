#! /usr/bin/env bash

#run thinkdown
git clone -b feature/safe-load-yaml https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/Thinkful/eagle-flavored-thinkdown thinkdown2
npm install -g gulp

echo "****** Installing thinkdown2 ******"
cd thinkdown2
npm install
npm link
cd ..

echo "****** Running thinkdown2 ******"
thinkdown2 --build=${CURRICULA_FOLDER}/thinkdown2/${CODE}/${VERSION}

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
