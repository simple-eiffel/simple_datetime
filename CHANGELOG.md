# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-10-08

### Added

- `SIMPLE_MONOTONIC_CLOCK`: a high-resolution elapsed-time clock over the Windows performance counter (inline C, no separate C file). `ticks`, `ticks_per_second`, `nanoseconds`, `microseconds`, `milliseconds`, `elapsed_nanoseconds`, `elapsed_milliseconds`, and an overflow-safe `to_nanoseconds`. It never goes backwards and ignores wall-clock changes. Purely additive; no existing class changed. Needed by simple_json's benchmark logger, which had been timing with ISE DATE_TIME.

## [0.1.1] - 2026-09-01

### Fixed

- `SIMPLE_TIME.make_from_string`: a bare 24-hour `12:MM:SS` was parsed as 12 AM, so noon became midnight (every ISO 8601 round trip through the noon hour shifted by twelve hours). The 12-hour conversion now applies only when an explicit `AM`/`PM` marker is present; `12:30 AM` is still midnight and `12:30 PM` still noon. Found by simple_chat's store equivalence assault.

## [Unreleased]

### Changed
- Testing config updates, AutoTest fixes, .gitignore cleanup
- Migrate to simple_testing library
- Add simple_datetime library: comprehensive date/time handling
- first commit

## [1.0.0] - 2025-12-08

### Added
- Initial release
- Core functionality implemented
- Test suite with comprehensive coverage
- Documentation and examples

[Unreleased]: https://github.com/simple-eiffel/simple_datetime/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/simple-eiffel/simple_datetime/releases/tag/v1.0.0
