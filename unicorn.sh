#!/bin/bash
RAILS_ENV=production bundle exec unicorn -c config/unicorn.rb
