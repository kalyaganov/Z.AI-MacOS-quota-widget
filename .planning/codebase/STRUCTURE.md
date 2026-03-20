# Codebase Structure

**Analysis Date:** 2026-03-21

## Directory Layout

```
zai-subscripton-info/
├── .github/                    # CI/CD workflows
│   └── workflows/              # GitHub Actions
│       ├── build.yml           # Build on push/PR
│       └── release.yml         # Create DMG on release
├── .build/                     # Swift build artifacts (gitignored)
├── build/                      # Xcode build output
├── docs/                       # Documentation
│   └── PLAN.md                 # Development planning
├── screenshots/                # App screenshots for README
├── ZaiSubscriptionWidget/      # Main source code
│   ├── Models/                 # Data models
│   ├── Services/               # Networking and storage
│   ├── ViewModels/             # Business logic
│   ├── Views/                  # SwiftUI views
│   ├── Assets.xcassets/        # App icons and images
│   ├── Info.plist              # App configuration
│   ├── Entitlements.entitlements # Sandbox permissions
│   └── ZaiSubscriptionWidgetApp.swift  # Entry point
├── ZaiSubscriptionWidget.xcodeproj/  # Xcode project
├── Package.swift               # Swift Package Manager config
├── README.md                   # Project documentation
├── icon.png                    # App icon for README
└── .gitignore                  # Git ignore rules
```

## Directory Purposes

**ZaiSubscriptionWidget/:**
- Purpose: All source code and resources for the macOS app
- Contains: Swift files, assets, plist configs
- Key files: `ZaiSubscriptionWidgetApp.swift` (entry), `Info.plist` (config)

**ZaiSubscriptionWidget/Models/:**
- Purpose: Data structures for API responses
- Contains: Codable structs matching Z.AI API response shapes
- Key files: `QuotaLimit.swift`, `ModelUsage.swift`, `ToolUsage.swift`

**ZaiSubscriptionWidget/Services/:**
- Purpose: External integrations and platform services
- Contains: API client and secure storage implementations
- Key files: `ZaiAPIService.swift`, `KeychainService.swift`

**ZaiSubscriptionWidget/ViewModels/:**
- Purpose: State management and business logic
- Contains: ObservableObject classes for SwiftUI binding
- Key files: `UsageViewModel.swift`

**ZaiSubscriptionWidget/Views/:**
- Purpose: SwiftUI view declarations
- Contains: UI components for menu bar and settings
- Key files: `MenuBarView.swift`, `SettingsView.swift`

**ZaiSubscriptionWidget/Assets.xcassets/:**
- Purpose: Image assets and app icons
- Contains: AppIcon.appiconset, MenuBarIcon.imageset
- Key files: `Contents.json` (asset catalog)

**.github/workflows/:**
- Purpose: CI/CD automation
- Contains: GitHub Actions workflow definitions
- Key files: `build.yml`, `release.yml`

**build/:**
- Purpose: Xcode build artifacts
- Contains: Compiled app, logs, cache
- Generated: Yes (by xcodebuild)
- Committed: No (should be gitignored)

## Key File Locations

**Entry Points:**
- `ZaiSubscriptionWidget/ZaiSubscriptionWidgetApp.swift`: SwiftUI App struct with @main

**Configuration:**
- `Package.swift`: Swift Package Manager manifest, defines macOS 13 platform
- `ZaiSubscriptionWidget/Info.plist`: Bundle config, LSUIElement=true for menu bar only
- `ZaiSubscriptionWidget/Entitlements.entitlements`: App sandbox and network permissions

**Core Logic:**
- `ZaiSubscriptionWidget/ViewModels/UsageViewModel.swift`: Central state management
- `ZaiSubscriptionWidget/Services/ZaiAPIService.swift`: HTTP client for Z.AI API
- `ZaiSubscriptionWidget/Services/KeychainService.swift`: Secure credential storage

**UI Components:**
- `ZaiSubscriptionWidget/Views/MenuBarView.swift`: Menu bar dropdown content
- `ZaiSubscriptionWidget/Views/SettingsView.swift`: Settings window with tabs

**Data Models:**
- `ZaiSubscriptionWidget/Models/QuotaLimit.swift`: Quota response parsing
- `ZaiSubscriptionWidget/Models/ModelUsage.swift`: Model token usage parsing
- `ZaiSubscriptionWidget/Models/ToolUsage.swift`: Tool call statistics parsing

**Testing:**
- No test files currently exist in this project

## Naming Conventions

**Files:**
- Swift files: PascalCase matching primary type (e.g., `UsageViewModel.swift`)
- View files: Descriptive noun + "View" suffix (e.g., `MenuBarView.swift`)
- Model files: Descriptive noun matching struct (e.g., `QuotaLimit.swift`)
- Service files: Descriptive noun + "Service" suffix (e.g., `KeychainService.swift`)

**Directories:**
- Plural nouns for categories: `Models/`, `Views/`, `Services/`, `ViewModels/`
- Lowercase with hyphens for config: `.github/`, `.build/`

**Types:**
- Structs: PascalCase (e.g., `ModelUsageItem`, `QuotaLimitResponse`)
- Enums: PascalCase (e.g., `APIError`, `RefreshInterval`)
- Classes: PascalCase (e.g., `UsageViewModel`, `ZaiAPIService`)
- Actors: PascalCase (e.g., `ZaiAPIService`)

## Where to Add New Code

**New Feature:**
- Primary code: Add to appropriate layer directory
  - Data structure → `ZaiSubscriptionWidget/Models/`
  - Business logic → `ZaiSubscriptionWidget/ViewModels/`
  - External integration → `ZaiSubscriptionWidget/Services/`
  - UI component → `ZaiSubscriptionWidget/Views/`
- Update: Modify `UsageViewModel.swift` if state management needed

**New API Endpoint:**
- Model: Add response struct to `ZaiSubscriptionWidget/Models/`
- Service: Add fetch method to `ZaiAPIService.swift`
- ViewModel: Add @Published property and async fetch call to `UsageViewModel.swift`
- View: Add UI to display in `MenuBarView.swift`

**New Setting/Preference:**
- ViewModel: Add @Published property with UserDefaults persistence to `UsageViewModel.swift`
- View: Add UI control to `SettingsView.swift`

**New View:**
- Implementation: Create new file in `ZaiSubscriptionWidget/Views/`
- Integration: Import in `ZaiSubscriptionWidgetApp.swift` or existing views

**Utilities:**
- Shared helpers: Create `ZaiSubscriptionWidget/Utils/` directory if needed
- Extensions: Create `ZaiSubscriptionWidget/Extensions/` directory if needed

## Special Directories

**.build/:**
- Purpose: Swift Package Manager build cache
- Contains: Compiled modules, package checkouts
- Generated: Yes (by swift build)
- Committed: No (gitignored)

**build/:**
- Purpose: Xcode derived data output
- Contains: Compiled app bundle, build logs
- Generated: Yes (by xcodebuild)
- Committed: No (should be gitignored)

**ZaiSubscriptionWidget.xcodeproj/:**
- Purpose: Xcode project configuration
- Contains: project.pbxproj (build settings), workspace
- Generated: No
- Committed: Yes

**.github/workflows/:**
- Purpose: GitHub Actions CI/CD
- Contains: YAML workflow definitions
- Generated: No
- Committed: Yes

## Build Outputs

**Development Build:**
```bash
# Via Xcode
open ZaiSubscriptionWidget.xcodeproj
# Press ⌘R to build and run

# Via command line
xcodebuild -project ZaiSubscriptionWidget.xcodeproj \
  -scheme ZaiSubscriptionWidget \
  -configuration Release \
  build
# Output: build/Build/Products/Release/ZaiSubscriptionWidget.app
```

**Release DMG:**
- Created by `.github/workflows/release.yml` on GitHub release
- Output: `ZaiSubscriptionWidget-{version}.dmg`

---

*Structure analysis: 2026-03-21*
