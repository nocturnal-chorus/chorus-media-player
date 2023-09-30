package oss

import (
	"context"
	"fmt"

	"github.com/minio/minio-go/v7"
	"github.com/nocturnal-chorus/chorus-media-player/core/utils"
)

const (
	OSSProviderTypeMinioKey = "minio"

	BUCKET_MUSIC  = "music"
	BUCKET_AVATAR = "avatar"
)

var (
	client IOSSClient
)

type IOSSClient interface {
	SetBucket(ctx context.Context, name string) error
	//SignUrl(ctx context.Context, key string, method HTTPMethod, contentType string, expires int64, option *SignUrlOption) (string, error)
	//DoesObjectExist(ctx context.Context, key string) (bool, error)
	GetObject(ctx context.Context, key, filePath string) error
	//PutObject(ctx context.Context, key, filePath string, options *PutObjectOptions) error
	//GetObjectMetadata(ctx context.Context, key string, option *GetObjectOptions) (*GetMetadataResult, error)
	//DeleteObject(ctx context.Context, key string) error
	//RenameObject(ctx context.Context, srcKey, destKey string) error
	//CopyObject(ctx context.Context, srcKey, destKey string) error
	//GetPostSignature(ctx context.Context, accessKeySecret, bucket, endpoint string, option *PostPolicyOption) (*PostSignatureResult, error)
}

func Client() IOSSClient {
	if client == nil {
		switch "minio" { // TODO
		case OSSProviderTypeMinioKey:
			return initMinioOss(utils.GetOssAK(), utils.GetOssSK())
		}
	}
	return client
}

// TODO delete 临时测试使用
var (
	minioClient *minio.Client
)

func MinioClient() *minio.Client {
	var err error
	if minioClient == nil {
		minioClient, err = InitMinioClient("2lAse4PBRscdknzAo2gS", "1L2bPBQVfnVIS3i4UcpfYTTFMYcIP1rgVPFviyUI")
		if err != nil {
			fmt.Println(err)
		}
	}
	return minioClient
}
