## 1.2.0

- **Fix Auto-Save Race Condition**: Robust restoration mechanism in `FormController` to correctly populate data even if UI builds asynchronously.
- **Refactor**: `GuardField` now listens directly to `FormController` for reactive updates.
- **Example App Enhancement**: Added advanced tests and improved stability.

## 1.1.0

- **New Validators**: Added `numeric`, `phone`, `range`, and `match` validators.
- **Custom Storage**: `SmartFormGuard` now accepts a custom `FormStorage` instance (e.g., Hive).
- **Example App**: Major overhaul with Basic, Wizard, and Custom Storage screens.

## 1.0.0

- Initial release.
- Core `SmartFormGuard` implementation.
- `GuardField` with email and password support.
- Auto-save and Basic Analytics.
