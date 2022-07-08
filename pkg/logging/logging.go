package logging

import (
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func AddLoggingFlags(cmd *cobra.Command) {
	var (
		debugEnabled, verboseEnabled bool
	)

	cmd.PersistentFlags().BoolVar(
		&debugEnabled,
		"debug",
		false,
		"Debug level output",
	)
	cmd.PersistentFlags().BoolVarP(
		&verboseEnabled,
		"verbose",
		"v",
		false,
		"Verbose level output",
	)

	cobra.OnInitialize(func() {
		base()
		switch {
		case debugEnabled:
			debug()
		case verboseEnabled:
			verbose()
		}
	})
}

func base() {
	logger, _ := baseLogConfig().Build()
	zap.ReplaceGlobals(logger)
}

func debug() {
	logger, _ := debugLogConfig().Build()
	zap.ReplaceGlobals(logger)
}

func verbose() {
	logger, _ := verboseLogConfig().Build()
	zap.ReplaceGlobals(logger)
}

func baseLogConfig() zap.Config {
	cfg := zap.NewProductionConfig()
	cfg.Level = zap.NewAtomicLevelAt(zap.WarnLevel)
	cfg.Encoding = "console"
	cfg.EncoderConfig.EncodeTime = zapcore.RFC3339NanoTimeEncoder
	return cfg
}

func debugLogConfig() zap.Config {
	cfg := baseLogConfig()
	cfg.Level = zap.NewAtomicLevelAt(zap.DebugLevel)
	return cfg
}

func verboseLogConfig() zap.Config {
	cfg := baseLogConfig()
	cfg.Level = zap.NewAtomicLevelAt(zap.InfoLevel)
	return cfg
}
