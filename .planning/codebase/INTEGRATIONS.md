# External Integrations

**Analysis Date:** 2026-03-21

## APIs & External Services

**Z.AI Monitoring API:**
- Base URL: `https://api.z.ai/api/monitor/usage`
- Purpose: Fetch subscription usage data for Z.AI Coding Plan
- SDK/Client: Native `URLSession` with async/await
- Auth: Bearer token (API key) in `Authorization` header
- Endpoints:
  - `/model-usage` - Model token statistics (input/output tokens per model)
  - `/tool-usage` - MCP tool call statistics
  - `/quota/limit` - Quota percentages (5-hour tokens, weekly tokens, monthly MCP)

**API Client Implementation:**
- Location: `ZaiSubscriptionWidget/Services/ZaiAPIService.swift`
- Pattern: Singleton actor (`ZaiAPIService.shared`)
- Timeout: 30s request, 60s resource
- Headers: `Authorization: Bearer {apiKey}`, `Content-Type: application/json`, `Accept-Language: en-US,en`

## Data Storage

**Databases:**
- None - No database; all data fetched fresh from API

**File Storage:**
- Local filesystem only - No cloud or external file storage

**Caching:**
- None - Data fetched on-demand; no persistence between sessions

## Authentication & Identity

**Auth Provider:**
- Custom API key authentication
  - Implementation: User-provided API key stored securely in macOS Keychain
  - Service identifier: `ai.z.subscription-widget`
  - Key identifier: `zai-api-key`
  - Location: `ZaiSubscriptionWidget/Services/KeychainService.swift`

**Keychain Operations:**
- `saveAPIKey(_:)` - Store API key securely
- `loadAPIKey()` - Retrieve API key
- `deleteAPIKey()` - Remove API key

## Monitoring & Observability

**Error Tracking:**
- None - Errors displayed in UI only via `UsageViewModel.error`

**Logs:**
- Console only via Swift's default logging
- No structured logging or remote log aggregation

## CI/CD & Deployment

**Hosting:**
- GitHub Releases - DMG files distributed as release assets
- Repository: `anomalyco/zai-subscripton-info`

**CI Pipeline:**
- GitHub Actions (`.github/workflows/`)
  - `build.yml` - Builds on push to main and PRs; runs on `macos-latest`
  - `release.yml` - Builds and creates DMG on GitHub release; uploads to release assets

**Build Process:**
```bash
xcodebuild -project ZaiSubscriptionWidget.xcodeproj \
  -scheme ZaiSubscriptionWidget \
  -configuration Release \
  -derivedDataPath build \
  clean build
```

**DMG Creation:**
- Uses `hdiutil` to create compressed DMG with Applications symlink
- Output: `ZaiSubscriptionWidget-{version}.dmg`

## Environment Configuration

**Required env vars:**
- None - All configuration via user input at runtime

**Secrets location:**
- macOS Keychain - API key stored per-user on local machine
- No server-side secrets or environment variables

## Webhooks & Callbacks

**Incoming:**
- None - App only makes outbound API requests

**Outgoing:**
- Z.AI API endpoints only:
  - `GET /api/monitor/usage/model-usage?startTime=...&endTime=...`
  - `GET /api/monitor/usage/tool-usage?startTime=...&endTime=...`
  - `GET /api/monitor/usage/quota/limit`

## Network Security

**App Sandbox:**
- Enabled: Yes (`com.apple.security.app-sandbox`)
- Network client: Enabled (`com.apple.security.network.client`)
- Location: `ZaiSubscriptionWidget/Entitlements.entitlements`

**Transport Security:**
- HTTPS only for all API calls (enforced by base URL)
- No certificate pinning

---

*Integration audit: 2026-03-21*
