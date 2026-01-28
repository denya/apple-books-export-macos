#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Apple Books Export - Sign & Notarize${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Check if cert.p12 exists
if [ ! -f "cert.p12" ]; then
    echo -e "${RED}Error: cert.p12 not found in current directory${NC}"
    echo "Please place your certificate file in the project root"
    exit 1
fi

# Step 1: Get certificate password
echo -e "${YELLOW}Step 1: Certificate Password${NC}"
echo -n "Enter password for cert.p12: "
read -s CERT_PASSWORD
echo ""

if [ -z "$CERT_PASSWORD" ]; then
    echo -e "${RED}Error: Password cannot be empty${NC}"
    exit 1
fi

# Step 2: Import certificate to temporary keychain
echo -e "${YELLOW}Step 2: Importing Certificate${NC}"
KEYCHAIN_NAME="build-$(date +%s).keychain"
KEYCHAIN_PASSWORD=$(openssl rand -base64 32)

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME" 2>/dev/null || true
security default-keychain -s "$KEYCHAIN_NAME"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME"
security set-keychain-settings -t 3600 -u "$KEYCHAIN_NAME"

if ! echo "$CERT_PASSWORD" | security import cert.p12 -k "$KEYCHAIN_NAME" -P "$CERT_PASSWORD" -T /usr/bin/codesign -T /usr/bin/productsign 2>/dev/null; then
    echo -e "${RED}Error: Failed to import certificate. Check password.${NC}"
    security delete-keychain "$KEYCHAIN_NAME" 2>/dev/null || true
    exit 1
fi

security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_NAME" >/dev/null 2>&1

echo -e "${GREEN}✓ Certificate imported${NC}"

# Step 3: Find signing identity
echo -e "${YELLOW}Step 3: Finding Signing Identity${NC}"

# Try to find Developer ID Application first (for distribution)
IDENTITY=$(security find-identity -v -p codesigning "$KEYCHAIN_NAME" | grep "Developer ID Application" | head -1 | awk '{print $2}')

# If not found, try Apple Development (for local signing)
if [ -z "$IDENTITY" ]; then
    IDENTITY=$(security find-identity -v -p codesigning "$KEYCHAIN_NAME" | grep "Apple Development" | head -1 | awk '{print $2}')
    CERT_TYPE="development"
    echo -e "${BLUE}Note: Using Apple Development certificate (not for public distribution)${NC}"
else
    CERT_TYPE="distribution"
fi

if [ -z "$IDENTITY" ]; then
    echo -e "${RED}Error: No valid signing certificate found${NC}"
    echo "Available identities:"
    security find-identity -v -p codesigning "$KEYCHAIN_NAME"
    security delete-keychain "$KEYCHAIN_NAME"
    exit 1
fi

IDENTITY_NAME=$(security find-identity -v -p codesigning "$KEYCHAIN_NAME" | grep "$IDENTITY" | sed 's/.*"\(.*\)"/\1/')
echo -e "${GREEN}✓ Found: $IDENTITY_NAME${NC}"

# Step 4: Extract Team ID
TEAM_ID=$(security find-certificate -a -c "$IDENTITY_NAME" "$KEYCHAIN_NAME" -p | openssl x509 -noout -text | grep "OU=" | head -1 | sed 's/.*OU=\([^,]*\).*/\1/' | tr -d ' ')

if [ -z "$TEAM_ID" ]; then
    echo -e "${YELLOW}Warning: Could not automatically extract Team ID${NC}"
    echo -n "Please enter your Team ID manually: "
    read TEAM_ID
else
    echo -e "${GREEN}✓ Team ID: $TEAM_ID${NC}"
fi

# Step 5: Build app
echo ""
echo -e "${YELLOW}Step 4: Building Universal Binary${NC}"
echo "This may take a minute..."

if ! swift build -c release --arch arm64 --arch x86_64; then
    echo -e "${RED}Error: Build failed${NC}"
    security delete-keychain "$KEYCHAIN_NAME"
    exit 1
fi

echo -e "${GREEN}✓ Build complete${NC}"

# Step 6: Create app bundle
echo -e "${YELLOW}Step 5: Creating App Bundle${NC}"
rm -rf AppleBooksExport.app
mkdir -p AppleBooksExport.app/Contents/{MacOS,Resources}
cp .build/apple/Products/Release/AppleBooksExport AppleBooksExport.app/Contents/MacOS/

# Create Info.plist
cat > AppleBooksExport.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>AppleBooksExport</string>
    <key>CFBundleIdentifier</key>
    <string>com.applebooksexport.macos</string>
    <key>CFBundleName</key>
    <string>AppleBooksExport</string>
    <key>CFBundleDisplayName</key>
    <string>Apple Books Export</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026. All rights reserved.</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
</dict>
</plist>
EOF

echo -e "${GREEN}✓ App bundle created${NC}"

# Step 7: Sign the app
echo -e "${YELLOW}Step 6: Code Signing${NC}"

if ! codesign --force --deep \
    --sign "$IDENTITY" \
    --options runtime \
    --entitlements entitlements.plist \
    --timestamp \
    AppleBooksExport.app; then
    echo -e "${RED}Error: Code signing failed${NC}"
    security delete-keychain "$KEYCHAIN_NAME"
    exit 1
fi

echo -e "${GREEN}✓ App signed${NC}"

# Verify signature
if codesign --verify --verbose AppleBooksExport.app 2>&1; then
    echo -e "${GREEN}✓ Signature verified${NC}"
else
    echo -e "${RED}Warning: Signature verification failed${NC}"
fi

# Step 8: Create DMG
echo -e "${YELLOW}Step 7: Creating DMG${NC}"
rm -rf dmg-staging AppleBooksExport.dmg
mkdir -p dmg-staging
cp -R AppleBooksExport.app dmg-staging/
ln -s /Applications dmg-staging/Applications

hdiutil create -volname "Apple Books Export" \
    -srcfolder dmg-staging \
    -ov -format UDZO \
    AppleBooksExport.dmg >/dev/null

rm -rf dmg-staging
echo -e "${GREEN}✓ DMG created${NC}"

# Step 9: Sign DMG
echo -e "${YELLOW}Step 8: Signing DMG${NC}"
codesign --sign "$IDENTITY" --timestamp AppleBooksExport.dmg
echo -e "${GREEN}✓ DMG signed${NC}"

# Step 10: Notarization (only for distribution certificates)
if [ "$CERT_TYPE" = "distribution" ]; then
    echo ""
    echo -e "${YELLOW}Step 9: Notarization Setup${NC}"
    echo "For notarization, you need:"
    echo "  1. Your Apple ID email"
    echo "  2. An app-specific password (create at appleid.apple.com)"
    echo ""
    echo -n "Do you want to notarize now? (y/n): "
    read NOTARIZE_NOW

    if [ "$NOTARIZE_NOW" = "y" ] || [ "$NOTARIZE_NOW" = "Y" ]; then
        echo -n "Enter your Apple ID (e.g., denya.msk@gmail.com): "
        read APPLE_ID

        echo -n "Enter app-specific password: "
        read -s APP_PASSWORD
        echo ""

        # Step 11: Submit for notarization
        echo -e "${YELLOW}Step 10: Submitting for Notarization${NC}"
        echo "This may take 3-10 minutes..."

        if xcrun notarytool submit AppleBooksExport.dmg \
            --apple-id "$APPLE_ID" \
            --password "$APP_PASSWORD" \
            --team-id "$TEAM_ID" \
            --wait; then

            # Step 12: Staple notarization ticket
            echo -e "${YELLOW}Step 11: Stapling Notarization Ticket${NC}"
            xcrun stapler staple AppleBooksExport.dmg
            echo -e "${GREEN}✓ Notarization ticket stapled${NC}"
            NOTARIZED=true
        else
            echo -e "${RED}Notarization failed${NC}"
            echo "You can check the status at: https://appstoreconnect.apple.com"
            NOTARIZED=false
        fi
    else
        echo -e "${BLUE}Skipping notarization${NC}"
        NOTARIZED=false
    fi
else
    echo ""
    echo -e "${BLUE}Note: Notarization requires a Developer ID Application certificate${NC}"
    echo "Your app is signed but not notarized (local use only)"
    NOTARIZED=false
fi

# Clean up
echo ""
echo -e "${YELLOW}Cleanup${NC}"
security delete-keychain "$KEYCHAIN_NAME"
echo -e "${GREEN}✓ Temporary keychain removed${NC}"

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}✓ SUCCESS!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "Signed DMG: ${GREEN}AppleBooksExport.dmg${NC}"

if [ "$NOTARIZED" = true ]; then
    echo -e "Status: ${GREEN}Signed and Notarized${NC} (ready for distribution)"
else
    echo -e "Status: ${YELLOW}Signed only${NC} (local use or notarize manually)"
fi

echo ""
echo "You can now:"
echo "  1. Test: open AppleBooksExport.dmg"
echo "  2. Verify: spctl -a -vv AppleBooksExport.app"

if [ "$NOTARIZED" = true ]; then
    echo "  3. Distribute: Upload to GitHub releases or share directly"
else
    echo "  3. Notarize manually: xcrun notarytool submit AppleBooksExport.dmg --apple-id EMAIL --password PASSWORD --team-id $TEAM_ID --wait"
fi

echo ""
