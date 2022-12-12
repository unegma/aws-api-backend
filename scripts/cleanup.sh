#!/bin/sh
cd dist

# Bump version
# todo when move all scripts to one place, make sure this is executed on the right package.json
# bump version without creating ugly commits: https://stackoverflow.com/questions/66717190/is-there-a-way-to-bump-the-version-without-version-commits
npm version --commit-hooks false --git-tag-version false minor

#todo fix function.zip not being deleted
echo "## Cleaning up..."
rm ./function.zip

echo "# Done."
exit 0
