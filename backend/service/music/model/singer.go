package model

import (
	"github.com/nocturnal-chorus/chorus-media-player/service/music/model/internal"
)

type Singer struct {
	Id   uint32 `gorm:"primary_key"`
	Name string `gorm:"column:name;NOTNULL"`
}

func (Singer) TableName() string {
	return internal.TableSinger
}
