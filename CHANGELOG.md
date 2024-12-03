# 3.0.0

## Major Updates

- Enhanced root detection system with multiple detection layers
- Added comprehensive Frida detection and blocking
- Implemented runtime integrity verification
- Added permission handling system for location access

## Security Enhancements

- Advanced root detection mechanisms:
  - Process monitoring for Frida-related services
  - Library injection detection
  - System property verification
  - Runtime integrity checks
- Enhanced package scanning for root management apps
- Improved root-hiding detection mechanisms

## Permission Management

- Added runtime location permission handling
- Implemented graceful permission denial handling
- Added location permission requirements documentation
- Enhanced error reporting and handling

## Documentation

- Updated README with comprehensive usage instructions
- Added detailed SECURITY.md documentation
- Enhanced code examples and implementation guidelines
- Added platform-specific setup instructions

## Bug Fixes

- Fixed isDebuggerAttached implementation
- Improved error handling in security checks
- Enhanced stability in detection mechanisms
- Fixed gradle build issues

## Breaking Changes

- Now requires location permissions for enhanced security checks
- Requires permission_handler package for runtime permissions
- Updated minimum Android SDK version requirements