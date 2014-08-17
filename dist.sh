echo "Distribute WhatTheForms"
mkdir -p gen/dist/client/gen

gulp

cp package.json gen/dist
cp README.md gen/dist
cp client/gen/* gen/dist/client/gen
cp gen/WhatTheForms.js gen/dist/WhatTheForms.js

awk 'FNR==1 && NR!=1 {print "\n\n"}{print}' src/*.coffee > gen/WhatTheForms.coffee
coffee -c gen/WhatTheForms.coffee
cp gen/WhatTheForms.js gen/dist

echo "Ready to publish"
echo "npm publish gen/dist"
