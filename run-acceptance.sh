#!/bin/bash

export SELENIUM=selenium-server-standalone-2.*.jar
export FLIPS_DB=flips_test
export http_proxy=""

if [ ! -f $SELENIUM ]
then
    echo Selenium is missing!
    echo try: wget http://selenium.googlecode.com/files/selenium-server-standalone-2.7.0.jar
    exit 1
fi

java -jar $SELENIUM &
./run &

sleep 5

node_modules/jasmine-node/bin/jasmine-node --coffee spec/acceptance.spec.coffee

trap "kill 0" SIGINT SIGTERM EXIT

