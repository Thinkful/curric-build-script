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

#commit changes to github if we're in the master branch
if [ -n "$MASTER" ]
then
    echo "Pushing structure.xml with uuid's to github"
    git add -u content
    git add content/structure.xml
    git config --global user.name "CircleCI"
    git config --global user.email "circleci@thinkful.com"
    # don't fail if there's nothing to commit
    git diff-index --quiet HEAD || git commit -m "automatic commit of uuids after pushing to master [CI skip]"

    PUSH_MASTER_OUTPUT=$(git push origin master --force 2>&1)
    if [[ $PUSH_MASTER_OUTPUT =~ "ERROR" ]]
    then
      echo $PUSH_MASTER_OUTPUT
      echo "Aborting, error pushing to GitHub. This curriculum needs a read+write key in CI."
      exit 1
    fi

    git checkout preview --force
    git merge --no-ff master -m="preview < master [CI skip]"
    git push origin preview --force
fi

#
# Push the new curriculum to S3
#

echo "[default]
access_key = $ACCESS_KEY
secret_key = $SECRET_KEY
" > ~/.s3cfg

# Copy the syllabus.json file if a new one was created
# NOTE: thunderbird should be removed from local path when we migrate
if [ -e ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/syllabus.json ]
then
    echo "Updating syllabus.json on ${S3SERVER}"
    s3cmd del ${S3SERVER}/syllabus/${CODE}/${VERSION}/syllabus.json
    s3cmd put ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/syllabus.json ${S3SERVER}/syllabus/${CODE}/${VERSION}/syllabus.json
fi

# Copy the curriculum.json file if a new one was created
# NOTE: thunderbird should be removed from local path when we migrate
if [ -e ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/curriculum.json ]
then
    echo "Updating curriculum.json on ${S3SERVER}"
    s3cmd del ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/curriculum.json
    s3cmd put ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/curriculum.json ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/curriculum.json
fi

#copy all the assets if assets exist
#start by deleting all the files in the assets bucket
#this is weirdly complicated, you can't just use a wildcard
#instead, we create an empty directory, sync against it, then delete the empty directory
if [ "`ls -A ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/assets`" ]
then
    echo "Updating thunderbird assets on ${S3SERVER}"
    mkdir empty_directory
    s3cmd sync --recursive --delete-removed --force empty_directory ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/assets2
    rm -rf empty_directory
    s3cmd put --recursive ${CURRICULA_FOLDER}/thunderbird/${CODE}/${VERSION}/assets/* ${S3SERVER}/curricula/${SECRET_PATH_KEY}/${CODE}/${VERSION}/assets2/
fi

if [ -n "$MASTER" ]
then
    echo "Bumping curriculum version"
    curl -X POST -H "Content-Type: application/json" --data '{"secret_key":"'$SECRET_PATH_KEY'"}' https://www.thinkful.com/webhooks/update_curriculum_version
fi
