#! /usr/bin/env bash

#run thinkdown
git clone https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/Thinkful/thinkdown
git clone https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/Thinkful/eagle-flavored-thinkdown thinkdown2
npm install -g gulp
echo "****** Installing legacy thinkdown ******"
cd thinkdown
npm install
npm link
cd ..
echo "****** Running thinkdown (one) ******"
thinkdown --curric=${CURRICULA_FOLDER}

echo "****** Installing thinkdown2 ******"
cd thinkdown2
npm install
npm link
cd ..
echo "****** Running thinkdown2 ******"
thinkdown2 --build=${CURRICULA_FOLDER}/thinkdown2/${CODE}/${VERSION}

if [ -e ${CURRICULA_FOLDER}/${CODE}/${VERSION}/spliced.xml ]
then
    echo "Thinkdown completed, spliced.xml exists."
else
    echo "Thinkdown exited, but seems to have failed, spliced.xml not found."
    exit 1
fi

