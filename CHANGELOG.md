# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-02-05

### Added

- Initial release
- `Yabeda::Httpx.instrument` method to add metrics to HTTPX sessions
- `httpx_requests_total` counter for tracking request counts
- `httpx_responses_total` counter for tracking responses by status
- `httpx_errors_total` counter for tracking request errors
- `httpx_request_duration` histogram for tracking request latency
- Support for HTTPX callbacks plugin (requires HTTPX >= 1.2.0)
