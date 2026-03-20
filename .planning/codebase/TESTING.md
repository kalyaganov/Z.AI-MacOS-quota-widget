# Testing Patterns

**Analysis Date:** 2026-03-21

## Test Framework

**Runner:**
- **Not configured** - No test target exists in the project
- XCTest enabled in build settings (`ENABLE_TESTABILITY = YES`) but no test files present

**Assertion Library:**
- XCTest would be the standard (not yet used)

**Run Commands:**
```bash
# No tests currently exist
# Future tests would run via:
xcodebuild test -project ZaiSubscriptionWidget.xcodeproj \
  -scheme ZaiSubscriptionWidget \
  -destination 'platform=macOS'
```

## Test File Organization

**Location:**
- **No test directory exists**
- Standard Swift convention would be a `ZaiSubscriptionWidgetTests/` directory at project root
- Alternatively, co-located `*Tests.swift` files (not observed)

**Naming:**
- Not applicable (no tests)
- Standard convention would be: `<ModuleName>Tests.swift`

**Expected Structure:**
```
ZaiSubscriptionWidget/
├── Models/
│   ├── ModelUsage.swift
│   └── ModelUsageTests.swift  # Co-located option
├── ...
ZaiSubscriptionWidgetTests/    # Separate directory option
├── ModelUsageTests.swift
├── ToolUsageTests.swift
├── QuotaLimitTests.swift
├── ZaiAPIServiceTests.swift
├── KeychainServiceTests.swift
└── UsageViewModelTests.swift
```

## Test Structure

**Suite Organization:**
- Not applicable - no tests exist

**Expected Pattern (XCTest):**
```swift
import XCTest
@testable import ZaiSubscriptionWidget

final class ModelUsageItemTests: XCTestCase {
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Total Tokens
    
    func testTotalTokens_sumsInputAndOutput() {
        let item = ModelUsageItem(
            model: "test",
            inputTokens: 100,
            outputTokens: 50
        )
        
        XCTAssertEqual(item.totalTokens, 150)
    }
    
    // MARK: - Formatting
    
    func testFormattedTotalTokens_formatsMillions() {
        let item = ModelUsageItem(
            model: "test",
            inputTokens: 1_500_000,
            outputTokens: 0
        )
        
        XCTAssertEqual(item.formattedTotalTokens, "1.5M")
    }
}
```

## Mocking

**Framework:** Not configured

**Patterns for Services:**
```swift
// Protocol-based mocking (recommended pattern)
protocol APIServiceProtocol {
    func fetchModelUsage(apiKey: String) async throws -> [ModelUsageItem]
    func fetchToolUsage(apiKey: String) async throws -> [ToolUsageItem]
    func fetchQuotaLimit(apiKey: String) async throws -> [QuotaLimitItem]
}

// Production implementation
actor ZaiAPIService: APIServiceProtocol { ... }

// Test mock
class MockAPIService: APIServiceProtocol {
    var mockModelUsage: [ModelUsageItem] = []
    var mockError: Error?
    
    func fetchModelUsage(apiKey: String) async throws -> [ModelUsageItem] {
        if let error = mockError { throw error }
        return mockModelUsage
    }
}
```

**What to Mock:**
- Network calls (`ZaiAPIService`)
- Keychain operations (`KeychainService`)
- System time (for time-dependent logic)

**What NOT to Mock:**
- Plain data models (structs)
- Computed properties on models
- Simple formatting functions

## Fixtures and Factories

**Test Data:**
```swift
// Expected pattern for test fixtures
extension ModelUsageItem {
    static func fixture(
        model: String = "glm-4",
        inputTokens: Int = 1000,
        outputTokens: Int = 500
    ) -> ModelUsageItem {
        ModelUsageItem(
            model: model,
            inputTokens: inputTokens,
            outputTokens: outputTokens
        )
    }
}

extension QuotaLimitItem {
    static func fixture(
        type: String = "TOKENS_LIMIT",
        unit: Int = 3,
        percentage: Double = 50.0
    ) -> QuotaLimitItem {
        // ... factory implementation
    }
}
```

**Location:**
- Should be in test target or shared test utilities
- Extension on model types with `fixture()` static methods

## Coverage

**Requirements:** None enforced

**Current Coverage:** 0% (no tests)

**View Coverage:**
```bash
# Future command when tests exist
xcodebuild test -project ZaiSubscriptionWidget.xcodeproj \
  -scheme ZaiSubscriptionWidget \
  -enableCodeCoverage YES \
  -destination 'platform=macOS'
```

## Test Types

**Unit Tests:**
- **Priority areas:**
  - `ModelUsageItem` - formatting, totals
  - `ToolUsageItem` - call count formatting
  - `QuotaLimitItem` - type detection, percentage calculations
  - `UsageViewModel.RefreshInterval` - raw value conversions

**Integration Tests:**
- **Priority areas:**
  - `ZaiAPIService` - actual network calls (with test API keys)
  - `KeychainService` - actual keychain operations
  - `UsageViewModel` - end-to-end refresh flow

**E2E Tests:**
- Not used
- XCUITest would be framework for UI testing
- Menu bar apps have limited E2E testability

## Common Patterns

**Async Testing:**
```swift
func testFetchModelUsage_returnsData() async throws {
    let service = ZaiAPIService.shared
    
    let result = try await service.fetchModelUsage(apiKey: "test-key")
    
    XCTAssertFalse(result.isEmpty)
}
```

**Error Testing:**
```swift
func testFetchModelUsage_noAPIKey_throwsError() async {
    let service = MockAPIService()
    service.mockError = APIError.noAPIKey
    
    do {
        _ = try await service.fetchModelUsage(apiKey: "")
        XCTFail("Expected error to be thrown")
    } catch let error as APIError {
        XCTAssertEqual(error, .noAPIKey)
    } catch {
        XCTFail("Unexpected error type: \(error)")
    }
}
```

## Testing Priorities

**High Priority (Core Logic):**
1. `ZaiAPIService/Models/ModelUsage.swift` - Token formatting, totals
2. `ZaiAPIService/Models/QuotaLimit.swift` - Type detection, percentages
3. `ZaiAPIService/Services/ZaiAPIService.swift` - Error handling, time windows

**Medium Priority (ViewModels):**
1. `ZaiAPIService/ViewModels/UsageViewModel.swift` - State management, refresh logic

**Lower Priority (Views):**
1. `MenuBarView.swift` - UI state rendering (snapshot tests)
2. `SettingsView.swift` - Form validation

## Test Setup Required

To add testing to this project:

1. **Add test target:**
```bash
# In Xcode: File → New → Target → Unit Testing Bundle
# Name: ZaiSubscriptionWidgetTests
```

2. **Update Package.swift (if using SPM):**
```swift
targets: [
    .executableTarget(name: "ZaiSubscriptionWidget", path: "ZaiSubscriptionWidget"),
    .testTarget(
        name: "ZaiSubscriptionWidgetTests",
        dependencies: ["ZaiSubscriptionWidget"],
        path: "ZaiSubscriptionWidgetTests"
    )
]
```

3. **Create test directory:**
```bash
mkdir ZaiSubscriptionWidgetTests
```

4. **Add first test file:**
```swift
// ZaiSubscriptionWidgetTests/ModelUsageItemTests.swift
import XCTest
@testable import ZaiSubscriptionWidget

final class ModelUsageItemTests: XCTestCase {
    // Tests here
}
```

---

*Testing analysis: 2026-03-21*
