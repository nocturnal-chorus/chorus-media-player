package utils

import (
	extension "github.com/nocturnal-chorus/chorus-media-player/core/internal"
	"os"
)

func GetDateBaseDSN() string {
	return os.Getenv(extension.PlayerDbDsnKey)
}

func GetOssEndPoint() string {
	return os.Getenv(extension.OssEndPointKey)
}

func GetOssAK() string {
	return os.Getenv(extension.OssAKKey)
}

func GetOssSK() string {
	return os.Getenv(extension.OssSKKey)
}
