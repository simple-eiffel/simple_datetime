# S01-PROJECT-INVENTORY.md
## simple_datetime - Project Inventory

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_datetime
**Version:** 1.0

---

## 1. Project Overview

| Attribute | Value |
|-----------|-------|
| **Name** | simple_datetime |
| **Purpose** | High-level date/time operations with fluent API |
| **Facade Class** | SIMPLE_DATETIME |
| **Author** | Larry Rix |
| **License** | MIT License |

## 2. Source Files

| File | Purpose |
|------|---------|
| `src/simple_datetime.e` | Main facade class with factory methods |
| `src/simple_date.e` | Date manipulation class |
| `src/simple_time.e` | Time manipulation class |
| `src/simple_date_time.e` | Combined date+time class |
| `src/simple_duration.e` | Duration/time span class |
| `src/simple_age.e` | Age calculation class |
| `src/simple_date_range.e` | Date range/interval class |
| `src/simple_date_range_cursor.e` | Iterator for date ranges |
| `testing/lib_tests.e` | Test suite |
| `testing/test_app.e` | Test application |

## 3. Dependencies

### Internal (simple_* ecosystem)
- None (self-contained)

### External (ISE/Standard)
- **base** - STRING, ARRAYED_LIST, COMPARABLE
- **time** - DATE, TIME, DATE_TIME, DATE_TIME_DURATION

## 4. ECF Configuration

**Target:** simple_datetime
**Root Class:** SIMPLE_DATETIME

## 5. Design Philosophy

- **Fluent API** - Chainable methods for readability
- **Immutable-style** - Methods return new instances
- **Multiple Format Support** - ISO 8601, American, European, human-readable
- **Business Day Support** - Skip weekends, count working days
- **Human-Friendly Output** - "5 minutes ago", "in 2 days"

## 6. Design Influences

- Eiffel Loop (Finnian Reilly) - Localization patterns
- Pylon library - Composition, format variety
- ISO8601 library (Thomas Beale) - Validation patterns
- Luxon/date-fns (JavaScript) - Fluent API, immutability
- Pendulum (Python) - Timezone awareness, humanize output

## 7. Compliance

- **Void Safety:** Full
- **SCOOP Ready:** Yes
- **Design by Contract:** Comprehensive
