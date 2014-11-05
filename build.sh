#! /usr/bin/env bash

#run thinkdown
git clone https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/Thinkful/eagle-flavored-thinkdown thinkdown2
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
    echo "Thinkdown completed, curriculum.json exists."
else
    echo "Thinkdown exited, it has failed, curriculum.json not found."
    exit 1
fi

