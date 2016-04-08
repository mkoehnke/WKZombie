#!/bin/bash

if ! command -v carthage > /dev/null; then
  printf 'Carthage is not installed.\n'
  printf 'See https://github.com/Carthage/Carthage for install instructions.\n'
  exit 1
fi

#carthage update --platform all --use-submodules --no-use-binaries
carthage update --platform all --no-use-binaries
