package main

import (
	"github.com/nocturnal-chorus/chorus-media-player/core/server"
	"github.com/nocturnal-chorus/chorus-media-player/proto/music"
	"github.com/nocturnal-chorus/chorus-media-player/service/music/service"
	"google.golang.org/grpc/reflection"
)

func main() {
	s, lis := server.NewServer(8091)
	music.RegisterMusicServiceServer(s, &service.MusicService{})
	// 支持 postman 调用
	reflection.Register(s)
	s.Serve(lis)
}
