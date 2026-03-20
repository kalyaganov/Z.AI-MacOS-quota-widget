# Technology Stack

**Analysis Date:** 2026-03-21

## Languages

**Primary:**
- Swift 5.9 - All application code, UI, and business logic

**Secondary:**
- None - Pure Swift codebase

## Runtime

**Environment:**
- macOS 13.0 (Ventura) or later - Minimum deployment target
- Native macOS application (menu bar app)

**Package Manager:**
- Swift Package Manager (SPM)
- Config: `Package.swift`

## Frameworks

**Core:**
- SwiftUI - UI framework for all views and menu bar interface
- Foundation - Core utilities, networking (URLSession), date formatting
- Combine - Reactive state management with `@Published` properties
- Security - macOS Keychain access for secure credential storage
- AppKit - NSApplication, NSWindow for settings window management

**Testing:**
- Not configured - No test targets detected in project

**Build/Dev:**
- Xcode 15.0+ - Primary IDE and build tool
- xcodebuild - Command-line build tool for CI/CD

## Key Dependencies

**Critical:**
- None - Zero external dependencies; uses only Apple system frameworks

**Infrastructure:**
- URLSession - Native HTTP networking (configured with 30s request timeout, 60s resource timeout)
- Keychain Services - Secure credential storage via Security framework

## Configuration

**Environment:**
- No `.env` files - API key stored in macOS Keychain at runtime
- User preferences stored in `UserDefaults`:
  - `autoRefreshEnabled` (Bool)
  - `autoRefreshEnabledSet` (Bool flag)
  - `refreshInterval` (Int, minutes)

**Build:**
- `Package.swift` - Swift Package Manager configuration
- `ZaiSubscriptionWidget.xcodeproj/project.pbxproj` - Xcode project configuration
- `ZaiSubscriptionWidget/Info.plist` - App bundle metadata
- `ZaiSubscriptionWidget/Entitlements.entitlements` - App sandbox and network permissions

## Platform Requirements

**Development:**
- macOS 13.0+ (Ventura)
- Xcode 15.0+
- Swift 5.9

**Production:**
- macOS 13.0+ (Ventura)
- Distributed as unsigned DMG via GitHub Releases
- App Sandbox enabled with network client entitlement

---

*Stack analysis: 2026-03-21*
