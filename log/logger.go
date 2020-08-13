package log

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"

	"github.com/kmdkuk/go-cli-template/version"
	"github.com/spiegel-im-spiegel/logf"
)

var logger *logf.Logger

func init() {
	minLevel := logf.ERROR
	if version.Version == "DEV" {
		minLevel = logf.DEBUG
	}
	logger = logf.New(
		logf.WithWriter(os.Stdout),
		logf.WithMinLevel(minLevel),
	)
}

func Info(v ...interface{}) {
	logger.Print(format(v))
}

func Debug(v ...interface{}) {
	logger.Debug(format(v))
}

func Error(v ...interface{}) {
	logger.Error(format(v))
}

func format(v ...interface{}) string {
	_, file, line := caller()
	return fmt.Sprint(file, ":", line, v)
}

func caller() (string, string, int) {
	pc, file, line, _ := runtime.Caller(3)
	f := runtime.FuncForPC(pc)
	p, _ := os.Getwd()
	path, _ := filepath.Rel(p, file)
	return f.Name(), path, line
}
