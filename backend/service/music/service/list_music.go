package service

import (
	"context"
	"github.com/nocturnal-chorus/chorus-media-player/proto/music"
)

func (MusicService) ListMusic(ctx context.Context, req *music.ListMusicRequest) (*music.ListMusicResponse, error) {
	return &music.ListMusicResponse{}, nil
}
