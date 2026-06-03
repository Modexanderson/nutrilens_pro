# This script runs as part of the Podfile to prevent SPM/CocoaPods conflicts.
# google_mobile_ads does not support SPM yet, so we force CocoaPods for all plugins.
system("flutter config --no-enable-swift-package-manager > /dev/null 2>&1")
