package utils

import (
	extension "github.com/nocturnal-chorus/chorus-media-player/core/internal"
	"os"
)

func GetDateBaseDSN() string {
	return os.Getenv(extension.PlayerDbDsnKey)
}
