# Drift Analysis: simple_datetime

Generated: 2026-01-24
Method: `ec.exe -flatshort` vs `specs/*.md` + `research/*.md`

## Specification Sources

| Source | Files | Lines |
|--------|-------|-------|
| specs/*.md | 8 | 1380 |
| research/*.md | 1 | 487 |

## Classes Analyzed

| Class | Spec'd Features | Actual Features | Drift |
|-------|-----------------|-----------------|-------|
| SIMPLE_DATETIME | 125 | 82 | -43 |

## Feature-Level Drift

### Specified, Implemented ✓
- `current_date` ✓
- `current_datetime` ✓
- `current_time` ✓
- `current_utc` ✓
- `date_from_string` ✓
- `datetime_from_string` ✓
- `decode_date` ✓
- `decode_datetime` ✓
- `decode_iso8601` ✓
- `first_of_month` ✓
- ... and 27 more

### Specified, NOT Implemented ✗
- `at_end_of_day` ✗
- `at_midnight` ✗
- `at_noon` ✗
- `business_days_count` ✗
- `day_of_week` ✗
- `day_of_year` ✗
- `days_since` ✗
- `days_until` ✗
- `end_date` ✗
- `end_of_day` ✗
- ... and 78 more

### Implemented, NOT Specified
- `Io`
- `Operating_environment`
- `add_business_days`
- `age_between`
- `age_from`
- `author`
- `business_days_between`
- `conforms_to`
- `copy`
- `create_date`
- ... and 35 more

## Summary

| Category | Count |
|----------|-------|
| Spec'd, implemented | 37 |
| Spec'd, missing | 88 |
| Implemented, not spec'd | 45 |
| **Overall Drift** | **HIGH** |

## Conclusion

**simple_datetime** has high drift. Significant gaps between spec and implementation.
