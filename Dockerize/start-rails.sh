#!/bin/bash

bundle exec rake db:create db:migrate
bundle exec rails s -p 3030 -b '0.0.0.0' -d
bundle exec rake jobs:work
