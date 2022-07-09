package version

import (
	"fmt"
	"runtime/debug"

	"go.uber.org/zap"
)

var (
	Version   = "DEV"
	Revision  = "unset"
	BuildDate = ""
)

const (
	defaultVersion   = "DEV"
	defaultRevision  = "unset"
	defaultBuildDate = ""
)

func GetVersion() string {
	if Version != defaultVersion {
		return Version
	}

	// if go install
	if buildInfo, ok := debug.ReadBuildInfo(); ok && buildInfo.Main.Version != "" {
		zap.L().Debug(fmt.Sprintf("get buildInfo.Main %v", buildInfo.Main))
		return buildInfo.Main.Version
	}

	return defaultVersion
}

func GetRevision() string {
	if Revision != defaultRevision {
		return Revision
	}

	// if go install
	if rev, ok := getBuildSettings("vcs.revision"); ok {
		return rev
	}

	return defaultRevision
}

func GetBuildDate() string {
	if BuildDate != defaultBuildDate {
		return BuildDate
	}

	// if go install
	if date, ok := getBuildSettings("vcs.time"); ok {
		return date
	}

	return defaultBuildDate
}

func getBuildSettings(key string) (string, bool) {
	buildInfo, ok := debug.ReadBuildInfo()
	if !ok {
		return "", false
	}
	zap.L().Debug(fmt.Sprintf("get buildInfo.Settings %v", buildInfo.Settings))
	for _, v := range buildInfo.Settings {
		if v.Key == key {
			return v.Value, true
		}
	}
	return "", false
}
