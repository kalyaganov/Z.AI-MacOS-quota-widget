# Architecture

**Analysis Date:** 2026-03-21

## Pattern Overview

**Overall:** MVVM (Model-View-ViewModel) with SwiftUI

**Key Characteristics:**
- Native macOS menu bar application (LSUIElement = true)
- Single shared state via singleton ViewModels
- Actor-based API service for thread-safe networking
- Reactive data binding with SwiftUI @Published properties
- Secure credential storage via macOS Keychain

## Layers

**View Layer:**
- Purpose: UI rendering and user interaction handling
- Location: `ZaiSubscriptionWidget/Views/`
- Contains: SwiftUI Views (`MenuBarView.swift`, `SettingsView.swift`)
- Depends on: ViewModels (via @ObservedObject)
- Used by: App entry point

**ViewModel Layer:**
- Purpose: Business logic, state management, and coordination
- Location: `ZaiSubscriptionWidget/ViewModels/`
- Contains: `UsageViewModel.swift` - single source of truth for app state
- Depends on: Services (ZaiAPIService, KeychainService)
- Used by: Views (MenuBarView, SettingsView)

**Service Layer:**
- Purpose: External integrations and platform-specific functionality
- Location: `ZaiSubscriptionWidget/Services/`
- Contains: `ZaiAPIService.swift` (networking), `KeychainService.swift` (secure storage)
- Depends on: Foundation, Security frameworks
- Used by: ViewModels

**Model Layer:**
- Purpose: Data structures and API response parsing
- Location: `ZaiSubscriptionWidget/Models/`
- Contains: `ModelUsage.swift`, `ToolUsage.swift`, `QuotaLimit.swift`
- Depends on: Foundation (Codable)
- Used by: Services (decoding), ViewModels (state)

## Data Flow

**App Startup Flow:**

1. `ZaiSubscriptionWidgetApp.swift` initializes with `@main` attribute
2. `AppDelegate` registered via `@NSApplicationDelegateAdaptor`
3. `UsageViewModel.shared` singleton created and injected into views
4. Saved settings loaded from Keychain and UserDefaults
5. Auto-refresh timer started if API key exists and auto-refresh enabled

**Data Refresh Flow:**

1. Timer fires (or manual refresh triggered) → `UsageViewModel.refresh()` called
2. ViewModel calls `ZaiAPIService.fetchQuotaLimit(apiKey:)`
3. API service builds request with Bearer token and time window params
4. Response decoded into `QuotaLimitResponse` model
5. ViewModel updates `@Published var quotaLimits`
6. SwiftUI observes change and re-renders `MenuBarView`

**Settings Save Flow:**

1. User enters API key in `SettingsView`
2. `saveAPIKey()` called on `UsageViewModel`
3. ViewModel saves to `KeychainService` and updates `@Published var apiKey`
4. Timer updated/started for auto-refresh
5. View observes change and shows confirmation

**State Management:**
- Single `UsageViewModel.shared` singleton holds all app state
- `@Published` properties trigger SwiftUI view updates
- UserDefaults for non-sensitive preferences (auto-refresh settings)
- Keychain for sensitive data (API key)

## Key Abstractions

**UsageViewModel:**
- Purpose: Central state management and business logic coordinator
- Examples: `ZaiSubscriptionWidget/ViewModels/UsageViewModel.swift`
- Pattern: Singleton with @MainActor isolation, ObservableObject protocol

**ZaiAPIService:**
- Purpose: Thread-safe HTTP client for Z.AI API
- Examples: `ZaiSubscriptionWidget/Services/ZaiAPIService.swift`
- Pattern: Actor-based singleton for concurrency safety

**KeychainService:**
- Purpose: Secure credential storage using macOS Security framework
- Examples: `ZaiSubscriptionWidget/Services/KeychainService.swift`
- Pattern: Class singleton with Security framework APIs

**Response Models:**
- Purpose: Type-safe API response parsing
- Examples: `ZaiSubscriptionWidget/Models/*.swift`
- Pattern: Codable structs with computed properties for display formatting

## Entry Points

**App Entry Point:**
- Location: `ZaiSubscriptionWidget/ZaiSubscriptionWidgetApp.swift`
- Triggers: macOS launches app bundle
- Responsibilities: Initialize SwiftUI App, register AppDelegate, create MenuBarExtra

**Settings Window:**
- Location: `ZaiSubscriptionWidget/ZaiSubscriptionWidgetApp.swift` (AppDelegate.showSettingsWindow)
- Triggers: User clicks gear icon in menu bar view
- Responsibilities: Create/show NSWindow with SettingsView, manage window lifecycle

**Menu Bar View:**
- Location: `ZaiSubscriptionWidget/Views/MenuBarView.swift`
- Triggers: User clicks menu bar icon
- Responsibilities: Display quota usage, refresh button, settings access, quit action

## Error Handling

**Strategy:** Typed errors with LocalizedError conformance

**Patterns:**
- `APIError` enum in `ZaiAPIService.swift` covers all network/API failure cases
- `KeychainError` enum in `KeychainService.swift` covers keychain operation failures
- Error messages surfaced to user via `viewModel.error` @Published property
- Errors displayed inline in MenuBarView with warning icon

```swift
// Error types defined in ZaiAPIService.swift
enum APIError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case httpError(Int, Data?)
    case decodingError(Error)
    case networkError(Error)
}
```

## Cross-Cutting Concerns

**Logging:** Console output via print/debugPrint (no structured logging framework)

**Validation:** API key validation checks for non-empty trimmed string

**Authentication:** Bearer token in Authorization header, stored in Keychain

**Concurrency:**
- `@MainActor` on UsageViewModel for UI thread safety
- `actor` on ZaiAPIService for thread-safe networking
- `Task` blocks for async operations in views

**Security:**
- App Sandbox enabled (`com.apple.security.app-sandbox`)
- Network client entitlement (`com.apple.security.network.client`)
- API key stored in macOS Keychain, not UserDefaults

---

*Architecture analysis: 2026-03-21*
