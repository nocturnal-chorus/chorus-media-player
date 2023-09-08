package log

import (
	"context"
	"log/slog"
	"os"
)

// https://pkg.go.dev/log/slog@master

var (
	log *slog.Logger
)

func init() {
	log = slog.New(slog.NewJSONHandler(os.Stdout, nil))
}

func Info(ctx context.Context, msg string) {
	log.Info(msg)
}
