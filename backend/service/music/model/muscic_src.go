package model

import (
	"github.com/nocturnal-chorus/chorus-media-player/service/music/model/internal"
)

type MusicSrc struct {
	Id      uint32 `gorm:"primary_key"`
	Url     string `gorm:"column:url"`
	MusicId uint32 `gorm:"column:music_id"`
}

func (MusicSrc) TableName() string {
	return internal.TableMusicSrc
}
