# Contributing to ShopSync 🤝

Thank you for your interest in contributing to ShopSync! This document provides guidelines and instructions for contributing.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Workflow](#contributing-workflow)
- [Coding Standards](#coding-standards)
- [Submission Guidelines](#submission-guidelines)
- [Types of Contributions](#types-of-contributions)
- [Testing](#testing)
- [Documentation](#documentation)
- [Support](#support)

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Flutter SDK**: Version 3.35.0 or higher
- **Dart SDK**: Version 3.9.2 or higher
- **Android Studio** or **VS Code** with Flutter plugins
- **Git** for version control
- **Android device or emulator** for testing

### Development Setup

1. **Fork the repository and clone**

   To fork press the below button:

   [![Fork repository button](assets/readme/buttons/fork.png)](https://github.com/ASDev-Official/shopsync/fork)

   ```bash
   git clone https://github.com/YOUR_USERNAME/shopsync.git
   cd shopsync
   ```

2. **Set up the development environment**

   ```bash
   # Get Flutter dependencies
   flutter pub get

   # Verify your Flutter installation
   flutter doctor

   # Run the app in debug mode
   flutter run
   ```

3. **Set up your IDE**
   - Install Flutter and Dart plugins
   - Configure code formatting (dartfmt)
   - Enable lint rules as defined in `analysis_options.yaml`

## Contributing Workflow

1. **Create a new branch**

   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/issue-description
   ```

2. **Make your changes**

   - Follow our coding standards
   - Update documentation as needed

3. **Test your changes**

   ```bash
   # Check for linting issues
   flutter analyze

   # Format code
   flutter format .
   ```

4. **Commit your changes**

   ```bash
   git add .
   git commit -m "feat: add new QR scanning feature"
   ```

5. **Push and create a Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Coding Standards

### Dart/Flutter Guidelines

- **Follow official Dart style guide**: Use `dartfmt` for formatting
- **Naming conventions**:
  - `camelCase` for variables, methods, and parameters
  - `PascalCase` for classes, enums, and typedefs
  - `snake_case` for file names
- **File organization**:
  - Group imports: Flutter, third-party, then local
  - Use relative imports for local files
  - Keep files under 300 lines when possible

### Code Quality

- **Documentation**: Document all public APIs
- **Error handling**: Always handle potential errors gracefully
- **Performance**: Consider performance implications, especially for UI
- **Accessibility**: Ensure UI elements are accessible
- **Null safety**: Leverage Dart's null safety features

### Example Code Structure

```dart
// models/example_model.dart
import 'package:flutter/foundation.dart';

/// Represents an attendance record in the Attendance system.
///
/// This model contains all necessary information for tracking
/// a single attendance event.
class AttendanceRecord {
  /// Creates an [AttendanceRecord] with the given parameters.
  const AttendanceRecord({
    required this.id,
    required this.timestamp,
    required this.type,
    this.notes,
  });

  /// Unique identifier for this attendance record.
  final String id;

  /// When the attendance was recorded.
  final DateTime timestamp;

  /// Type of attendance (arrival/departure).
  final AttendanceType type;

  /// Optional notes for this record.
  final String? notes;

  @override
  String toString() => 'AttendanceRecord(id: $id, type: $type)';
}
```

## Submission Guidelines

### Pull Request Requirements

- **Clear title**: Use conventional commit format
- **Description**: Explain what, why, and how
- **Testing**: Include manual testing notes
- **Documentation**: Update relevant documentation
- **Screenshots**: For UI changes, include before/after screenshots
- **Breaking changes**: Clearly document any breaking changes

### Conventional Commits

Use conventional commit messages:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:

```
feat: add arrival time customization in settings
fix: resolve camera permission crash on Android 14
docs: update installation instructions in README
```

## Types of Contributions

### 🐛 Bug Reports

When reporting bugs:

- Use the bug report template
- Include steps to reproduce
- Provide device/OS information
- Include screenshots if applicable
- Check if the issue already exists

### ✨ Feature Requests

For new features:

- Use the feature request template
- Explain the use case and benefit
- Consider backward compatibility
- Discuss implementation approach

### 🔧 Code Contributions

We welcome contributions for:

- **Bug fixes**: Resolve existing issues
- **New features**: Enhance app functionality
- **Performance improvements**: Optimize existing code
- **UI/UX enhancements**: Improve user experience
- **Documentation**: Improve guides and comments
- **Tests**: Increase test coverage

### 🚫 What We Don't Accept

- **Breaking changes** without prior discussion
- **Large refactors** without approval
- **Platform-specific code** without cross-platform consideration
- **Dependencies** that significantly increase app size

## Testing

### Test Requirements

- **Manual testing**: Test on real devices
- **Performance testing**: For all operations

## Documentation

### Code Documentation

- Document all public classes and methods
- Include usage examples for complex APIs
- Explain non-obvious implementation decisions
- Keep comments up-to-date with code changes

### README Updates

Update the README when:

- Adding new features
- Changing installation steps
- Modifying system requirements
- Adding new dependencies

## Support

### Getting Help

- **Issues**: Use GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub discussions for questions
- **Documentation**: Check existing documentation first

### Response Times

- **Bug reports**: We aim to respond within 48 hours
- **Feature requests**: Response within 1 week
- **Pull requests**: Review within 1 week

## Recognition

Contributors will be recognized in:

- **CONTRIBUTORS.md**: List of all contributors
- **Release notes**: Major contributions highlighted
- **GitHub**: Contributor badge and statistics

Thank you for contributing to ShopSync! Your efforts help make attendance tracking better for everyone. 🚀
