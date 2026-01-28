# Code Signing and Notarization Guide

This guide explains how to sign and notarize Apple Books Export for distribution.

## Prerequisites

1. **Certificate File**: `cert.p12` (Developer ID Application certificate)
   - ⚠️ **NEVER commit this file to git** (already in .gitignore)
   - Keep it in the project root directory only when signing

2. **Apple ID**: Your Apple developer account email

3. **App-Specific Password**: Create at [appleid.apple.com](https://appleid.apple.com)
   - Sign in → Security → App-Specific Passwords
   - Generate new password for "notarytool"

4. **Team ID**: Automatically extracted from certificate (or enter manually)

## Quick Start

```bash
# Make sure cert.p12 is in the project root
./Scripts/sign-and-notarize.sh
```

The script will:
1. ✅ Prompt for certificate password
2. ✅ Import certificate to temporary keychain
3. ✅ Build universal binary (Intel + Apple Silicon)
4. ✅ Create app bundle with Info.plist
5. ✅ Sign app with hardened runtime
6. ✅ Create DMG with Applications folder
7. ✅ Sign DMG
8. ✅ Submit for notarization (optional)
9. ✅ Staple notarization ticket
10. ✅ Clean up temporary keychain

## Interactive Prompts

The script will ask for:

1. **Certificate Password**: Password for cert.p12
2. **Apple ID**: Your developer email (e.g., denya.msk@gmail.com)
3. **App-Specific Password**: Generated at appleid.apple.com
4. **Notarize Now?**: y/n (can skip and notarize manually later)

## Expected Output

```
=====================================
Apple Books Export - Sign & Notarize
=====================================

Step 1: Certificate Password
Step 2: Importing Certificate
✓ Certificate imported
Step 3: Finding Signing Identity
✓ Found: Developer ID Application: Your Name (TEAMID)
✓ Team ID: TEAMID
Step 4: Building Universal Binary
✓ Build complete
Step 5: Creating App Bundle
✓ App bundle created
Step 6: Code Signing
✓ App signed
✓ Signature verified
Step 7: Creating DMG
✓ DMG created
Step 8: Signing DMG
✓ DMG signed
Step 9: Notarization Setup
Step 10: Submitting for Notarization
✓ Notarization ticket stapled
Cleanup
✓ Temporary keychain removed

=====================================
✓ SUCCESS!
=====================================

Signed DMG: AppleBooksExport.dmg
Status: Signed and Notarized (ready for distribution)
```

## Verification

After signing, verify the DMG:

```bash
# Verify app signature
codesign --verify --deep --strict --verbose=2 AppleBooksExport.app

# Verify DMG signature
codesign --verify --deep --strict --verbose=2 AppleBooksExport.dmg

# Verify notarization (should say "accepted")
spctl -a -vv AppleBooksExport.app

# Test DMG
open AppleBooksExport.dmg
```

## Manual Notarization

If you skipped notarization during signing, you can notarize manually:

```bash
# Submit for notarization
xcrun notarytool submit AppleBooksExport.dmg \
    --apple-id "your-email@example.com" \
    --password "xxxx-xxxx-xxxx-xxxx" \
    --team-id "YOURTEAMID" \
    --wait

# Staple ticket (after successful notarization)
xcrun stapler staple AppleBooksExport.dmg

# Verify
xcrun stapler validate AppleBooksExport.dmg
```

## Troubleshooting

### "No Developer ID Application certificate found"

**Cause**: Certificate is "Apple Development" not "Developer ID Application"

**Solution**:
- Script will use available certificate with a warning
- App can be used locally but not distributed publicly
- For distribution, obtain "Developer ID Application" certificate from Apple Developer portal

### "Certificate password incorrect"

**Cause**: Wrong password for cert.p12

**Solution**: Re-run script with correct password

### "Notarization failed"

**Cause**: Apple ID or app-specific password incorrect, or Team ID mismatch

**Solution**:
1. Verify credentials at [appleid.apple.com](https://appleid.apple.com)
2. Check Team ID: `security find-certificate -a -c "Developer ID" ~/Library/Keychains/login.keychain-db`
3. View detailed logs: `xcrun notarytool log <submission-id> --apple-id EMAIL --password PASSWORD --team-id TEAMID`
4. Check status at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)

### "Build failed"

**Cause**: Missing dependencies or build errors

**Solution**:
1. Test build manually: `swift build -c release`
2. Check for Swift errors
3. Ensure all dependencies are available

### "DMG verification fails"

**Cause**: Signature or notarization issue

**Solution**:
```bash
# Check what went wrong
codesign -dvv AppleBooksExport.dmg
spctl -a -vv --assess AppleBooksExport.app
```

## Certificate Types

| Certificate Type | Use Case | Notarization |
|-----------------|----------|--------------|
| **Developer ID Application** | Public distribution | ✅ Required |
| **Apple Development** | Local testing only | ❌ Not applicable |
| **Mac App Store** | App Store only | ✅ Automatic |

## Security Notes

1. **Never commit cert.p12 to git**
   - Already in .gitignore
   - Delete after signing if not needed

2. **Passwords are never stored**
   - Script prompts interactively
   - Nothing written to disk
   - Temporary keychain auto-deleted

3. **Temporary keychain**
   - Created with random password
   - Used only during signing
   - Automatically removed after completion

## Distribution

After successful signing and notarization:

1. **Test locally**: Open AppleBooksExport.dmg and drag to Applications
2. **Upload to GitHub**: Create release and attach DMG
3. **Share directly**: Email or cloud storage link
4. **Users can install**: macOS will verify signature and notarization automatically

## Files Created

- `AppleBooksExport.app` - Signed app bundle (intermediate)
- `AppleBooksExport.dmg` - Signed and notarized installer (distribute this)

## Manual Signing (Alternative)

If you prefer manual control:

```bash
# 1. Import certificate
security import cert.p12 -k ~/Library/Keychains/login.keychain-db

# 2. Build
swift build -c release --arch arm64 --arch x86_64

# 3. Create app bundle
mkdir -p AppleBooksExport.app/Contents/MacOS
cp .build/apple/Products/Release/AppleBooksExport AppleBooksExport.app/Contents/MacOS/
# (create Info.plist manually)

# 4. Sign
codesign --sign "Developer ID Application: Your Name" \
    --options runtime \
    --entitlements entitlements.plist \
    --timestamp \
    AppleBooksExport.app

# 5. Create DMG
hdiutil create -volname "Apple Books Export" \
    -srcfolder AppleBooksExport.app \
    -ov -format UDZO \
    AppleBooksExport.dmg

# 6. Notarize
xcrun notarytool submit AppleBooksExport.dmg \
    --apple-id "email" \
    --password "password" \
    --team-id "TEAMID" \
    --wait

# 7. Staple
xcrun stapler staple AppleBooksExport.dmg
```

## Resources

- [Apple Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)
- [App-Specific Passwords](https://support.apple.com/en-us/HT204397)
- [Developer ID Certificates](https://developer.apple.com/support/developer-id/)

## Summary

The `sign-and-notarize.sh` script handles the complete workflow:

✅ Secure certificate handling (temporary keychain)
✅ Universal binary build (Intel + Apple Silicon)
✅ Professional DMG with Applications folder
✅ Code signing with hardened runtime
✅ Apple notarization
✅ Automatic cleanup
✅ Interactive prompts (no stored credentials)

**Result**: Production-ready DMG that installs without warnings on any Mac.
