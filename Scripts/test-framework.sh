#!/bin/bash

bash Scripts/setup-framework.sh
xcodebuild -workspace WKZombie.xcworkspace -scheme WKZombie -sdk iphonesimulator build test

