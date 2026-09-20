# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release preparation

## [1.0.0] - 2024-10-09

### Added
- Complete n8n Docker setup with PostgreSQL
- Traefik reverse proxy with automatic HTTPS
- Automated installation script (`setup.sh`)
- Update script (`update.sh`) for easy n8n updates
- Backup and restore scripts (`backup.sh`, `restore.sh`)
- Comprehensive documentation in `docs/` directory
  - Server preparation guide
  - DNS configuration guide
  - Installation guide
  - Update guide
  - Backup and restore guide
  - Troubleshooting guide
- FAQ documentation
- Quick start guide
- Contributing guidelines
- MIT License

### Features
- 🔒 Automatic HTTPS with Let's Encrypt
- 🗄️ PostgreSQL database for data persistence
- 🔄 Easy backup and restore functionality
- 🚀 One-command installation
- 📦 Docker-based deployment
- 🔧 Environment-based configuration
- 🌍 Timezone support
- 🔐 Basic authentication enabled by default
- 📊 Health checks for services

### Security
- Firewall configuration included in setup
- Secure cookie settings
- HTTPS enforcement
- Isolated Docker network
- Basic authentication by default

---

## Release Notes Template

Use this template for future releases:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features or capabilities

### Changed
- Changes to existing functionality

### Deprecated
- Features that will be removed in future releases

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security improvements or fixes
```

---

## Versioning

- **Major version (X.0.0)**: Breaking changes, major updates
- **Minor version (0.Y.0)**: New features, backwards compatible
- **Patch version (0.0.Z)**: Bug fixes, minor improvements

---

[Unreleased]: https://github.com/dragancenic/n8n-docker-setup/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/dragancenic/n8n-docker-setup/releases/tag/v1.0.0
