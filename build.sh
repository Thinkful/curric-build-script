#! /usr/bin/env bash

if [ "$1" == "production" ]
then
  # production options
  echo "Setting 'production' options."
  export MASTER="true"
fi

if [ "$1" == "preview" ]
then
  # preview options
  echo "Setting 'preview' options."
  export S3SERVER=${PREVIEW_S3SERVER}
  export ACCESS_KEY=${PREVIEW_ACCESS_KEY}
  export SECRET_KEY=${PREVIEW_SECRET_KEY}
fi

#run thinkdown
git clone https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/Thinkful/thinkdown
npm install -g gulp
cd thinkdown
npm install
npm link
cd ..
thinkdown --curric=${CURRICULA_FOLDER}

#commit changes to github if we're in the master branch
if [ -n "$MASTER" ]; then
    git add content/structure.xml
    git config --global user.name "CircleCI"
    git config --global user.email "circleci@thinkful.com"
    git commit -m "automatic commit of uuids after pushing to master [CI skip]"
    git push origin master
fi

#push changes to s3 server
echo "[default]
access_key = $ACCESS_KEY
secret_key = $SECRET_KEY
" > ~/.s3cfg

#copy the curriculum.xml file if a new one was created
if [ -e ${CURRICULA_FOLDER}/${CODE}/${VERSION}/spliced.xml ]; then
    echo "Updating spliced.xml"
    s3cmd del ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/spliced.xml
    s3cmd put ${CURRICULA_FOLDER}/${CODE}/${VERSION}/spliced.xml ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/spliced.xml
fi

#copy all the assets if assets exist
#start by deleting all the files in the assets bucket
#this is weirdly complicated, you can't just use a wildcard
#instead, we create an empty directory, sync against it, then delete the empty directory
if [ "`ls -A ${CURRICULA_FOLDER}/${CODE}/${VERSION}/assets`" ]; then
    echo "Updating assets"
    mkdir empty_directory
    s3cmd sync --recursive --delete-removed --force empty_directory ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/assets
    rm -rf empty_directory
    s3cmd put --recursive ${CURRICULA_FOLDER}/${CODE}/${VERSION}/assets/* ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/assets/
fi
