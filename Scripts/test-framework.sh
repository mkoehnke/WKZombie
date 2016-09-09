#!/bin/bash

bash Scripts/setup-framework.sh
xcodebuild -workspace WKZombie.xcworkspace -scheme WKZombie -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0' build test
