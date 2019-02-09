#!/usr/bin/env bash
set -e

function runUITests {
    mobile-center test run xcuitest --app "Inhumans/Test" --devices "Inhumans/iphone-9-dot-1-11-dot-0" --test-series "ui-tests" --locale "en_US" --build-dir APPCENTER_OUTPUT_DIRECTORY --async 
}

if [ "$APPCENTER_BRANCH" == "development" ]; then
    # runUITests
    echo "Need to run tests"
fi