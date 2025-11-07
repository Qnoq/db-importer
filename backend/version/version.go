package version

// Version follows Semantic Versioning (SemVer) specification
//
// Version format: MAJOR.MINOR.PATCH
// - MAJOR: Incompatible API changes (breaking changes)
// - MINOR: New functionality in a backward-compatible manner
// - PATCH: Backward-compatible bug fixes
//
// Examples:
// - 1.0.0 → 1.0.1: Bug fix
// - 1.0.1 → 1.1.0: New feature added
// - 1.1.0 → 2.0.0: Breaking change
//
// See: https://semver.org/
const AppVersion = "1.0.0"

// GetVersion returns the current application version
func GetVersion() string {
	return AppVersion
}
