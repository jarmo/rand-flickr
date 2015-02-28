#!/bin/bash

cd `dirname $0` 
./stop.sh
bundle exec rake start

