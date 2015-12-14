#!/usr/bin/env bash

set -e

xcodebuild -workspace SwiftyJSON.xcworkspace -scheme "TreeSet" -destination "platform=iOS Simulator,name=iPhone 6s" test