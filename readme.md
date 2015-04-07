# Curriculum CI Script

This script is used by each curriculum's CI script to:

 - Install thunderbird (npm install -g thunderbird)
 - Run it on the curriculum
 - Commit UUID's to structure.xml
 - Commit and Push the modified structure.xml to GitHub
 - Delete existing spliced.xml on s3
 - Push the spliced.xml onto s3
 - Delete existing s3 assets associated with this curriculum
 - Push the assets/ folder to a specific s3
