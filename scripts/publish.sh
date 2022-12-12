#!/bin/sh

# turn off cli pager
export AWS_PAGER=""

FUNCTION_NAME=""
AWS_PROFILE_NAME=""
AWS_REGION=""

#get parameters
while getopts f:p:r: opts
do
  case "${opts}" in
    f) FUNCTION_NAME=${OPTARG};;
    p) AWS_PROFILE_NAME=${OPTARG};;
    r) AWS_REGION=${OPTARG};;
  esac
done

if [ ! $FUNCTION_NAME ]
then
  echo "Function not specified"
  exit 1
fi

echo "# Beginning Deployment of $FUNCTION_NAME, aws profile: $AWS_PROFILE_NAME, aws regin: $AWS_REGION"

echo "## Temporarily moving current node_modules (with dev dependencies)..."
mv ./node_modules ./node_modules--temp || { echo "Failed to move node_modules"; exit 1; }

echo "## Installing production dependencies..."
npm install --only=production || { echo "Failed to install dependencies"; exit 1; }
#node-prune

rm -rf ./dist/node_modules
mv ./node_modules ./dist/node_modules

# Clean these up here so webstorm doesn't start indexing them
mv ./node_modules--temp ./node_modules || { echo "Failed to restore dev node_modules"; exit 1; }

echo "## Preparing zip file for deployment..."


# todo this might not be needed now with terraform, but it is putting the function into the root directory
# todo check if this zip happens twice, would be better to use the terraform version if it is
(cd dist; zip -qr ./function.zip .) || { echo "Failed to zip"; exit 1; }
# Make doubly sure it is deleted
rm -rf ./dist/node_modules

# deploy
echo "## Deploying..."
# now handled by terraform
#aws --profile $AWS_PROFILE_NAME --region $AWS_REGION lambda update-function-code --function-name $FUNCTION_NAME --zip-file fileb://function.zip || { echo "Failed to publish"; exit 1; }





#these have been moved to cleanup.sh

# Bump version
# todo when move all scripts to one place, make sure this is executed on the right package.json
# bump version without creating ugly commits: https://stackoverflow.com/questions/66717190/is-there-a-way-to-bump-the-version-without-version-commits
#npm version --commit-hooks false --git-tag-version false minor

#echo "## Cleaning up..."
#rm ./function.zip

#echo "# Done."
#exit 0
