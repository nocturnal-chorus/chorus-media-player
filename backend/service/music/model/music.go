package model

import (
	"github.com/nocturnal-chorus/chorus-media-player/service/music/model/internal"
)

type Music struct {
	Id       uint32 `gorm:"primary_key"`
	Name     string `gorm:"column:name;NOTNULL"`
	SingerId uint32 `gorm:"column:singerId;NOTNULL"`
}

func (Music) TableName() string {
	return internal.TableMusic
}
