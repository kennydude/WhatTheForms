echo "Distribute WhatTheForms"
mkdir -p gen/dist/client/gen
mkdir -p gen/dist/src

rm gen/WhatTheForms.js

gulp dist

cp package.json gen/dist
cp README.md gen/dist
cp client/gen/* gen/dist/client/gen
cp gen/WhatTheForms.js gen/dist/src
cp client/*.js gen/dist/client
cp -rf templates gen/dist

echo "Ready to publish"
echo "npm publish gen/dist"
