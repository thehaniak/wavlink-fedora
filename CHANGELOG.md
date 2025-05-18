# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Automatically find the EVDI driver's URL download link, which installs the latest RPM version.
- Added confirm prompt after finding the EVDI download URL.
- Added help/usage.

### Changed

- Changed default option to `system-check` instead of `install`.

### Deprecated

### Removed

- Removed support of architectures different than x86_64, which Silicon Motion SM76x driver does not officially support.

### Fixed

- Fixed user selecting "No" when installing the EVDI driver bug on dnf prompt.

### Security
