package service

import (
	"context"
	"fmt"
	"github.com/nocturnal-chorus/chorus-media-player/core/component/oss"
	"github.com/nocturnal-chorus/chorus-media-player/core/utils"
	"github.com/nocturnal-chorus/chorus-media-player/proto/music"
	"github.com/spf13/cast"
	"math"
	"math/rand"
)

func (MusicService) GetMusic(ctx context.Context, req *music.GetMusicRequest) (*music.MusicDetail, error) {
	return &music.MusicDetail{
		Id:   cast.ToString(rand.Int63n(math.MaxInt32)),
		Name: req.GetName(),
		Url:  fmt.Sprintf("https://%s/%s/%s", utils.GetOssEndPoint(), oss.BUCKET_MUSIC, req.GetName()),
	}, nil
}
