package extension

import (
	"fmt"
	"github.com/nocturnal-chorus/chorus-media-player/core/utils"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var (
	db *gorm.DB
)

func init() {
	var (
		dsn = utils.GetDateBaseDSN() // 例 user:pass@tcp(127.0.0.1:3306)/dbname?charset=utf8mb4&parseTime=True&loc=Local
		err error
	)

	db, err = gorm.Open(mysql.Open(dsn), &gorm.Config{}) // TODO config
	if err != nil {
		panic(fmt.Sprintf("Failed to connect database, error [%v]", err.Error()))
	}
	db = db.Set("gorm:table_options", "ENGINE=InnoDB CHARSET=utf8mb4 auto_increment=1")
	mysql, err := db.DB()
	if err != nil {
		panic(err)
	}
	mysql.SetMaxOpenConns(100) // 设置数据库连接池最大连接数
	mysql.SetMaxIdleConns(20)  // 连接池最大允许的空闲连接数，如果没有 sql 任务需要执行的连接数大于20，超过的连接会被连接池关闭。
}

func GetDB() *gorm.DB {
	return db
}
