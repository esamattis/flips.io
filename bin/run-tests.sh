
export FLIPS_DB=flips_test

# http_proxy="" curl -X DELETE http://localhost:5984/$FLIPS_DB/

node_modules/jasmine-node/bin/jasmine-node --coffee spec/urlgenerator.spec.coffee

