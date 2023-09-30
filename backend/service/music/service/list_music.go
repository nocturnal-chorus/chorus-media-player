package service

import (
	"context"
	"github.com/minio/minio-go/v7"
	"github.com/nocturnal-chorus/chorus-media-player/core/component/oss"
	"github.com/nocturnal-chorus/chorus-media-player/proto/music"
	"github.com/spf13/cast"
	"math"
	"math/rand"
)

// 未建库，临时查出 music 列表
func (MusicService) ListMusic(ctx context.Context, req *music.ListMusicRequest) (*music.ListMusicResponse, error) {
	var (
		client = oss.MinioClient()
		resp   = &music.ListMusicResponse{}
	)
	musicCh := client.ListObjects(ctx, oss.BUCKET_MUSIC, minio.ListObjectsOptions{})
	for mic := range musicCh {
		if mic.Err != nil {
			return nil, mic.Err
		}
		resp.Items = append(resp.Items, &music.MusicItem{
			Id:     cast.ToString(rand.Int63n(math.MaxInt32)),
			Name:   mic.Key,
			Singer: nil,
		})
		resp.Total++
	}
	return resp, nil
}
