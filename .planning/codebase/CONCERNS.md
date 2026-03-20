# Codebase Concerns

**Analysis Date:** 2026-03-21

## Tech Debt

**Unused Model/Tool Usage Features:**
- Issue: `fetchModelUsage()` and `fetchToolUsage()` methods exist in API service but are never called. The corresponding `@Published` properties `modelUsage` and `toolUsage` in ViewModel remain empty.
- Files: 
  - `ZaiSubscriptionWidget/Services/ZaiAPIService.swift` (lines 42-63)
  - `ZaiSubscriptionWidget/ViewModels/UsageViewModel.swift` (lines 8-9)
- Impact: Dead code increases maintenance burden; users cannot see model/tool breakdown despite UI/Models existing for this purpose
- Fix approach: Either implement the full feature by calling these methods in `refresh()`, or remove the unused code

**Force Unwraps in Date Handling:**
- Issue: Three force unwraps used in `getTimeWindow()` method - two on date construction
- Files: `ZaiSubscriptionWidget/Services/ZaiAPIService.swift` (lines 79, 134, 143)
- Impact: Potential crash if date calculations fail unexpectedly
- Fix approach: Replace force unwraps with guard statements and proper error handling

**Silent Error Suppression on Keychain Save:**
- Issue: `try?` silently ignores Keychain save errors in `didSet` observer
- Files: `ZaiSubscriptionWidget/ViewModels/UsageViewModel.swift` (line 19)
- Impact: User's API key may fail to save without any notification
- Fix approach: Add error state publishing and UI feedback when save fails

## Known Bugs

**No known critical bugs detected.** Code compiles and runs, but see Tech Debt section for potential runtime issues.

## Security Considerations

**API Key Storage:**
- Risk: API key stored in macOS Keychain (good), but silent failure on save could leave key unencrypted if fallback occurs
- Files: `ZaiSubscriptionWidget/Services/KeychainService.swift`
- Current mitigation: Uses macOS Security framework with proper service/account identifiers
- Recommendations: Add explicit success/failure feedback when saving API key

**HTTP Response Data Exposure:**
- Risk: `httpError` case captures response `Data?` but never uses or sanitizes it - could potentially log sensitive data
- Files: `ZaiSubscriptionWidget/Services/ZaiAPIService.swift` (line 7)
- Current mitigation: Data is not logged anywhere
- Recommendations: Consider removing unused data capture or using it for structured error reporting

**Unsigned Application:**
- Risk: App is not signed with Apple Developer certificate
- Files: Documented in `README.md`
- Current mitigation: README documents workaround (right-click → Open)
- Recommendations: Consider obtaining Apple Developer certificate for proper distribution

## Performance Bottlenecks

**Sequential API Calls:**
- Problem: Only one API call (`fetchQuotaLimit`) is currently made, but when model/tool usage is added, calls would be sequential
- Files: `ZaiSubscriptionWidget/ViewModels/UsageViewModel.swift` (lines 124-126)
- Cause: Sequential `await` calls instead of parallel
- Improvement path: Use `TaskGroup` or `async let` for parallel API calls when all three endpoints are needed

## Fragile Areas

**Date Window Calculation:**
- Files: `ZaiSubscriptionWidget/Services/ZaiAPIService.swift` (lines 118-149)
- Why fragile: Complex calendar arithmetic with force unwraps; depends on system calendar/timezone; edge cases around midnight/day boundaries
- Safe modification: Add unit tests for edge cases (midnight crossovers, timezone changes, daylight saving)
- Test coverage: None - no tests exist for this logic

**Settings Persistence Logic:**
- Files: `ZaiSubscriptionWidget/ViewModels/UsageViewModel.swift` (lines 85-99)
- Why fragile: Uses UserDefaults with magic string keys; `autoRefreshEnabled` has special first-run handling that could confuse future modifications
- Safe modification: Encapsulate UserDefaults access in a dedicated SettingsService
- Test coverage: None

**Settings Window Management:**
- Files: `ZaiSubscriptionWidget/ZaiSubscriptionWidgetApp.swift` (lines 6-31)
- Why fragile: Manual window lifecycle management with `NSWindow` references; potential memory issues if window handling changes
- Safe modification: Consider using SwiftUI Settings scene for macOS 13+
- Test coverage: None

## Scaling Limits

**Not applicable** - This is a small menu bar app with single-user local data. No scaling concerns identified.

## Dependencies at Risk

**No external dependencies** - Project uses only Apple frameworks:
- Foundation
- SwiftUI
- Security (Keychain)

No third-party packages in `Package.swift` or otherwise.

## Missing Critical Features

**Model/Tool Usage Display:**
- Problem: Data models and API methods exist for model usage breakdown and tool call statistics, but they're never fetched or displayed
- Blocks: Users cannot see per-model token breakdown or MCP tool call statistics (features advertised in README)

**Offline/Error State Handling:**
- Problem: No retry mechanism for failed API calls; user must manually refresh
- Blocks: Poor UX when network is temporarily unavailable

## Test Coverage Gaps

**Complete Absence of Tests:**
- What's not tested: All functionality - no test files exist
- Files: All Swift files in `ZaiSubscriptionWidget/`
- Risk: Any refactoring could introduce regressions undetected
- Priority: High

**Specific Untested Areas:**

| Component | File | Priority |
|-----------|------|----------|
| Date window calculation | `ZaiAPIService.swift:118-149` | High |
| Keychain operations | `KeychainService.swift` | High |
| API error handling | `ZaiAPIService.swift:3-27` | Medium |
| ViewModel state transitions | `UsageViewModel.swift` | Medium |
| Settings persistence | `UsageViewModel.swift:85-99` | Medium |

## Code Quality Issues

**Magic Numbers:**
- Files: `ZaiSubscriptionWidget/Services/ZaiAPIService.swift` (timeout values 30, 60)
- Files: `ZaiSubscriptionWidget/Views/SettingsView.swift` (sleep duration 2_000_000_000)
- Recommendation: Extract to named constants

**Duplicate Number Formatting:**
- Issue: Identical formatting logic in `ModelUsageItem.formatNumber()` and `ToolUsageItem.formattedCallCount`
- Files: 
  - `ZaiSubscriptionWidget/Models/ModelUsage.swift` (lines 34-42)
  - `ZaiSubscriptionWidget/Models/ToolUsage.swift` (lines 16-24)
- Recommendation: Extract to shared utility

**HTTP Status Code Range:**
- Issue: Uses `200...299` for success but doesn't handle specific status codes differently
- Files: `ZaiSubscriptionWidget/Services/ZaiAPIService.swift` (line 106)
- Recommendation: Consider specific handling for 401 (auth), 429 (rate limit), etc.

---

*Concerns audit: 2026-03-21*
