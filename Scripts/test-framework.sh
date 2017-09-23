#!/bin/bash

bash Scripts/setup-framework.sh
xcodebuild -workspace WKZombie.xcworkspace -scheme WKZombie -sdk iphonesimulator11.0 -destination 'platform=iOS Simulator,name=iPhone 8,OS=11.0' build test
