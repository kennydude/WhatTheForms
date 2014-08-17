echo "Distribute WhatTheForms"
mkdir -p gen/dist/client/gen

gulp dist

cp package.json gen/dist
cp README.md gen/dist
cp client/gen/* gen/dist/client/gen
cp gen/WhatTheForms.js gen/dist/WhatTheForms.js
cp gen/WhatTheForms.js gen/dist

echo "Ready to publish"
echo "npm publish gen/dist"
