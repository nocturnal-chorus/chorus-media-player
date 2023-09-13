package main

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/nocturnal-chorus/chorus-media-player/core/log"
	"github.com/nocturnal-chorus/chorus-media-player/openapi/consumer/controller"
	"github.com/nocturnal-chorus/chorus-media-player/openapi/consumer/middleware"
	"github.com/nocturnal-chorus/chorus-media-player/proto"
	"gopkg.in/tylerb/graceful.v1"
)

func main() {
	var (
		r   = gin.Default()
		mux = newServeMux()
	)

	r.Use(middleware.Cors())
	r.GET("/ping", controller.Ping)
	r.Any("/v0/*rest", func(c *gin.Context) {
		mux.ServeHTTP(c.Writer, c.Request)
	})

	graceful.Run(fmt.Sprintf(":%s", "4376"), 5*time.Second, r)
}

func newServeMux() http.Handler {
	ctx := context.Background()
	log.Info(ctx, "Register services")
	serveMux, err := proto.NewGateway(ctx)
	if err != nil {
		panic(err)
	}
	log.Info(ctx, "Register services end")
	return serveMux
}
