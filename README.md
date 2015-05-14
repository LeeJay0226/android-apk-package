How to Use
0. 配置好java jdk环境
1. 进入android-apk-package目录
2. 将需要打包的apk放入当前目录下，取名为xxx_official_xxx_debug.apk或xxx_official_xxx_release.apk必须包含official关键字，用于后面被其他渠道号替换
3. 编辑tools目录下的channels.txt文件 将需要打包的渠道名写入，用#注释的行不会被打包
4. 将keystore文件放入tools的debug和release目录中，并修改run.sh 中的相应storepass、keyAlias值
5. 运行脚本run.sh 参数为1个（apk的全称xxx_official_xxx_debug.apk或xxx_official_xxx_release.apk）
6. 脚本运行结束后，产生的渠道包存放在output的debug或release目录中