# Coding Conventions

**Analysis Date:** 2026-03-21

## Naming Patterns

**Files:**
- PascalCase matching the primary type: `ZaiSubscriptionWidgetApp.swift`, `UsageViewModel.swift`
- Grouped by role in subdirectories: `Models/`, `Services/`, `ViewModels/`, `Views/`

**Types (Structs, Classes, Enums):**
- PascalCase: `UsageViewModel`, `ZaiAPIService`, `KeychainService`
- Models suffix: `Item` for collection elements (`ModelUsageItem`, `ToolUsageItem`, `QuotaLimitItem`)
- Response suffix: `Response` for API response wrappers (`ModelUsageResponse`, `QuotaLimitResponse`)
- Service suffix: `Service` for service classes (`ZaiAPIService`, `KeychainService`)
- ViewModel suffix: `ViewModel` for observable objects (`UsageViewModel`)
- View suffix: `View` for SwiftUI views (`MenuBarView`, `SettingsView`)
- Error suffix: `Error` for error enums (`APIError`, `KeychainError`)

**Functions & Methods:**
- camelCase: `fetchModelUsage()`, `saveAPIKey()`, `loadSavedSettings()`
- Boolean getters start with `is`, `has`: `isToken5HourLimit`, `hasAPIKey`
- Factory/formatting methods use `formatted` prefix: `formattedPercentage`, `formattedCallCount`

**Variables & Properties:**
- camelCase: `apiKey`, `quotaLimits`, `refreshInterval`
- Private backing storage with underscore prefix not used; direct `@Published` properties preferred
- Constants: camelCase for local constants, PascalCase for static type-level constants

**Enum Cases:**
- camelCase: `.noAPIKey`, `.invalidURL`, `.httpError`, `.networkError`
- Nested enums use dot notation: `UsageViewModel.RefreshInterval.fiveMinutes`

## Code Style

**Formatting:**
- No SwiftFormat or SwiftLint configuration present
- Indentation: 4 spaces (standard Swift convention)
- Max line length: Not enforced, observed ~100 characters max
- Trailing closures preferred for completion handlers

**Structure:**
- MARK comments not used
- Extensions used sparingly (primarily for protocol conformance)
- Computed properties grouped with stored properties

## Import Organization

**Order:**
1. Framework imports (alphabetical within groups):
   - `import Foundation`
   - `import SwiftUI`
   - `import Combine`
   - `import Security` (when needed)

**Pattern:**
- One import per line
- No explicit import grouping comments
- No third-party dependencies

## Error Handling

**Patterns:**
- Custom error enums conforming to `Error` and `LocalizedError`:
```swift
enum APIError: Error, LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case httpError(Int, Data?)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured. Please add your API key in Settings."
        // ...
        }
    }
}
```
- User-friendly error messages in `errorDescription`
- Associated values for context (`httpError(Int, Data?)`)
- Throwing functions use `throws` and `try`/`catch`

**Error Propagation:**
- Services throw typed errors
- ViewModels catch and store as `String?` for display:
```swift
do {
    self.quotaLimits = try await apiService.fetchQuotaLimit(apiKey: apiKey)
} catch {
    self.error = error.localizedDescription
}
```

## Logging

**Framework:** OSLog not used; errors surfaced to UI only

**Patterns:**
- No explicit logging statements in current codebase
- Errors displayed to user via `@Published var error: String?`
- Debug prints not present in production code

## Comments

**When to Comment:**
- Minimal inline comments; code is self-documenting
- No documentation comments (Swift DocC) present

**JSDoc/TSDoc Equivalent (Swift Documentation):**
- Not currently used
- Public APIs lack documentation comments

## Function Design

**Size:** Functions generally under 30 lines; `getTimeWindow()` at ~30 lines is the longest

**Parameters:** 
- Primary parameters first, closures last
- Default values used sparingly

**Return Values:**
- Async functions return typed values or throw
- Computed properties for derived values

## Module Design

**Exports:**
- Each file declares one primary type
- No barrel files or re-exports

**Access Control:**
- `private` for implementation details
- `internal` (default) for most members
- No `public` or `open` access levels (app target, not library)

## Architecture Patterns

**MVVM:**
- Models: Plain structs with `Codable` conformance in `Models/`
- ViewModels: `@MainActor` classes with `@Published` properties in `ViewModels/`
- Views: SwiftUI `View` structs in `Views/`

**Services:**
- Singleton pattern: `static let shared`
- `actor` for thread-safe services (`ZaiAPIService`)
- `class` for stateful services (`KeychainService`)

**Concurrency:**
- `async/await` for all asynchronous operations
- `@MainActor` for UI-bound ViewModels
- `Task` for bridging sync to async contexts
- Actors for data isolation

## SwiftUI Conventions

**Property Wrappers:**
- `@StateObject` for ViewModel ownership: `@StateObject private var viewModel = UsageViewModel.shared`
- `@ObservedObject` for passed-in ViewModels: `@ObservedObject var viewModel: UsageViewModel`
- `@Published` for reactive state
- `@State` for local view state: `@State private var tempAPIKey: String = ""`

**View Composition:**
- Private computed properties for subviews: `private var noAPIKeyView: some View`
- Extract complex views into separate properties
- Use `VStack`, `HStack`, `ZStack` for layout

---

*Convention analysis: 2026-03-21*
