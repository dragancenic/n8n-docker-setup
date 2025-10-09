# Contributing to n8n Docker Setup

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in [GitHub Issues](https://github.com/your-username/n8n-docker-setup/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment (OS, Docker version, etc.)
   - Relevant logs or screenshots

### Suggesting Enhancements

For feature requests:

1. Check existing issues to avoid duplicates
2. Describe the feature and its benefits
3. Explain use cases
4. Provide examples if possible

### Pull Requests

We welcome pull requests! Here's the process:

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**:
   - Follow existing code style
   - Update documentation if needed
   - Test your changes thoroughly

4. **Commit your changes**:
   ```bash
   git commit -m "Add: brief description of changes"
   ```
   
   Use conventional commit messages:
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for updates to existing features
   - `Docs:` for documentation changes
   - `Refactor:` for code refactoring

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**:
   - Provide clear description of changes
   - Reference related issues
   - Explain why the change is needed

## Development Guidelines

### Documentation

- Keep documentation clear and concise
- Use proper markdown formatting
- Include code examples where relevant
- Update README.md if adding new features

### Scripts

- Add comments for complex logic
- Include error handling
- Test on Ubuntu 20.04 and 22.04
- Make scripts executable: `chmod +x script.sh`

### Docker Compose

- Use official images when possible
- Include version tags (not just `latest`)
- Add health checks for services
- Document environment variables

### Testing

Before submitting:

1. Test on clean Ubuntu installation
2. Verify all scripts work
3. Check documentation accuracy
4. Test backup/restore procedures

## Code of Conduct

- Be respectful and inclusive
- Help others learn and grow
- Focus on constructive feedback
- Keep discussions relevant

## Questions?

If you have questions:
- Open a discussion in GitHub Discussions
- Ask in n8n Community Forum
- Check existing documentation

## Recognition

Contributors will be recognized in the project README.

Thank you for contributing! 🎉