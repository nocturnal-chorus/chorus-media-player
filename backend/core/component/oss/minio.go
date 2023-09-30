package oss

import (
	"context"
	"errors"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"github.com/nocturnal-chorus/chorus-media-player/core/utils"
	"strings"
)

// 后续禁止导出
type MinioOss struct {
	minioClient *minio.Client
	bucket      string
}

// 后续禁止导出
func InitMinioClient(accessKeyId, accessKeySecret string) (*minio.Client, error) {
	var (
		endpoint = utils.GetOssEndPoint()
	)
	if endpoint == "" || accessKeyId == "" || accessKeySecret == "" {
		return nil, errors.New("empty key")
	}
	secure := true
	if secure {
		endpoint = strings.Replace(endpoint, "https://", "", 1)
	} else {
		endpoint = strings.Replace(endpoint, "http://", "", 1)
	}
	client, err := minio.New(strings.Replace(endpoint, "%s.", "", -1), &minio.Options{
		Creds:  credentials.NewStaticV4(accessKeyId, accessKeySecret, ""),
		Secure: secure,
	})
	if err != nil {
		return nil, err
	}
	return client, nil
}

func initMinioOss(accessKeyId, accessKeySecret string) *MinioOss {
	client, err := InitMinioClient(accessKeyId, accessKeySecret)
	if err != nil {
		// TODO log error
		return nil
	}
	minio := &MinioOss{
		minioClient: client,
	}
	return minio
}

func (m MinioOss) SetBucket(ctx context.Context, name string) error {
	exists, err := m.minioClient.BucketExists(ctx, name)
	if err != nil {
		return err
	}
	if !exists {
		return errors.New("bucket not exists")
	}
	return nil
}

func (m MinioOss) ListObjects(ctx context.Context, prefix string) error {
	var (
		option = minio.ListObjectsOptions{
			Prefix: prefix,
		}
	)
	m.minioClient.ListObjects(ctx, m.bucket, option)
	return nil
}

func (m MinioOss) GetObject(ctx context.Context, key, filePath string) error {
	return nil
}
