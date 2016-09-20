#!/bin/bash

bash Scripts/setup-framework.sh
xcodebuild -workspace WKZombie.xcworkspace -scheme WKZombie -sdk iphonesimulator10.0 -destination 'platform=iOS Simulator,name=iPhone 6s,OS=10.0' build test
