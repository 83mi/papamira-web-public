#!/bin/bash

export RACK_ENV=test
export PPAP_S_API_KEY=0001
export PPAP_V_API_KEY=0002
export PPAP_B_API_KEY=0003
export PPAP_G_API_KEY=0004

ruby test/001_basic_test.rb
