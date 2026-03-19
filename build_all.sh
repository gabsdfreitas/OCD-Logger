#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${BLUE}=== OCD Logger Build Script ===${NC}\n"

# Build macOS
echo -e "${BLUE}Building for macOS...${NC}"
flutter build macos --release
echo -e "${GREEN}✓ macOS build complete${NC}\n"

# Build iOS
echo -e "${BLUE}Building for iOS...${NC}"
flutter build ios --release
echo -e "${GREEN}✓ iOS build complete${NC}\n"

# Create iOS archive
echo -e "${BLUE}Creating iOS archive...${NC}"
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -derivedDataPath build/ios_build archive -archivePath build/ios_build/ocd_logger.xcarchive > /dev/null 2>&1
echo -e "${GREEN}✓ iOS archive created${NC}\n"

# Export IPA
echo -e "${BLUE}Exporting IPA...${NC}"
cd "$PROJECT_DIR"
xcodebuild -exportArchive -archivePath ios/build/ios_build/ocd_logger.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/ios_ipa > /dev/null 2>&1
echo -e "${GREEN}✓ IPA export complete${NC}\n"

# Display results
echo -e "${BLUE}=== Build Results ===${NC}"
echo -e "${GREEN}macOS:${NC} build/macos/Build/Products/Release/OCD Logger.app"
echo -e "${GREEN}iOS IPA:${NC} build/ios_ipa/ocd_logger.ipa"
echo ""
echo -e "${GREEN}All builds complete!${NC}"
