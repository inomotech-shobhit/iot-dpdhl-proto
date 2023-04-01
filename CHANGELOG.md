# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.2.0] - 2022-12-12

This release contains a major breaking change in the topic structure. Nonetheless, the release is marked as a minor
version bump as no major parties have finished implementing the protocol yet and the required changes in the are trivial
to execute.

### Added

- Documentation for TLS certificate handling.
- `VehicleACCurrentRealized` status message.
- meta: Automatically check for breaking changes in merge requests.
- meta: Use mdBook for generating the documentation.
- meta: Automatic release process.
- meta: Lint markdown files.

### Changed

- All topics now start with an assigned manufacturer id to allow better access control.

## [2.1.1] - 2022-11-25

### Fixed

- Unified namespaces to the format `sts.v2.x`. This goes against the Buf guidelines, because they recommend versioning
  the sub-packages separately. We don't require this kind of modularity, so the lint has been disabled.

## [2.1.0] - 2022-11-25

### Added

- Protocol documentation in the `docs/` directory.
- Charge and drive statistics messages from v1 with some backwards-compatible changes.

### Changed

- Renamed all packages in the form of `sts.*.v2` to `sts.v2.*` (EDIT: this was later partially reverted by another MR).
- Renamed `sts.v2.vehicle_status` to `sts.v2.vehicle`.
- A lot of smaller changes made by IAV in: <https://gitlab.com/streetscooter/tcu/proto-files/-/merge_requests/3>

## [2.0.0-rc.1] - 2022-10-07

### Added

- meta: Added a lot of useful scripts to the `tools/` directory.
- New packages `sts.v2`, `sts.control.v2`, and `sts.vehicle_status.v2` containing the initial draft of the new protocol version.

### Changed

- Moved the `c2c` package to `sts.v1`. This is a breaking change for the generated code, but doesn't affect the wire format.

## [1.5.1] - 2022-01-19

### Added

- This changelog and a versioning system. The initial version was chosen completely arbitrarily.

### Changed

- Rewrote preconditioning message text to be in English.

[Unreleased]: https://gitlab.com/streetscooter/tcu/proto-files/-/tree/main
[2.2.0]:      https://gitlab.com/streetscooter/tcu/proto-files/-/tree/v2.2.0
[2.1.1]:      https://gitlab.com/streetscooter/tcu/proto-files/-/tree/v2.1.1
[2.1.0]:      https://gitlab.com/streetscooter/tcu/proto-files/-/tree/v2.1.0
[2.0.0-rc.1]: https://gitlab.com/streetscooter/tcu/proto-files/-/tree/v2.0.0-rc.1
[1.5.1]:      https://gitlab.com/streetscooter/tcu/proto-files/-/tree/v1.5.1
