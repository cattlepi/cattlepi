#!/bin/bash
SELFDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export SERVERIP=192.168.0.1 # the ip which the server will listen to
cd $SELFDIR && cd .. && bundle exec rake && bundle exec ruby lib/server.rb
