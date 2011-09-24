#!/bin/bash

./run &
java -jar selenium-server-standalone-2.7.0.jar &

sleep 3

node_modules/jasmine-node/bin/jasmine-node --coffee spec/

trap "kill 0" SIGINT SIGTERM EXIT

