package oss

import (
	"context"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"github.com/stretchr/testify/assert"
	"testing"
)

func getMinioClient() (*minio.Client, error) {
	var (
		endpoint        = "minio.nocturnal-chorus.com"
		accessKeyID     = ""
		secretAccessKey = ""
		useSSL          = true
	)

	// Initialize minio client object.
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKeyID, secretAccessKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		return nil, err
	}
	return minioClient, nil
}

func TestListMusicObjects(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())

	defer cancel()

	client, err := getMinioClient()
	assert.Nil(t, err)

	buckets, err := client.ListBuckets(ctx)
	if err != nil {
		t.Log(err)
		return
	}
	listCount := 0
	for _, bucket := range buckets {
		objectCh := client.ListObjects(ctx, bucket.Name, minio.ListObjectsOptions{
			Prefix: "",
		})
		for object := range objectCh {
			if object.Err != nil {
				assert.Nil(t, object.Err)
			}
			listCount++
			t.Log(object.Key)
		}
	}
	assert.True(t, listCount > 0)
}
