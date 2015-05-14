toolDir=./tools
apkPath=$1
#从左向右截取最后一个/后的字符串
app=${apkPath##*/}
#从右向左截取第一个.apk后的字符串
app=${app%.apk*}
echo $app

channelKey=channel
channelsFile=$toolDir/channels.txt
apktool=$toolDir/apktool.jar
manifestTool=$toolDir/ManifestTool.jar

#设置打包的类型为debug还是release
if [[ $app =~ "release" ]]; then
buildType=release
storepass=demo_release
keyAlias=release
else
buildType=debug
storepass=demo_debug
keyAlias=android
fi
keystoreSrc=$toolDir/$buildType/$buildType.keystore

echo buildType为${buildType}
echo storePassword为${storepass}
echo keystoreAlias为${keyAlias}
echo keystoreSrc为${keystoreSrc}

#如果文件夹不存在，创建文件夹
if [ ! -d "./output" ]; then
mkdir ./output
fi

if [ ! -d "./output/debug" ]; then
mkdir ./output/debug
fi

if [ ! -d "./output/temp" ]; then
mkdir ./output/temp
fi

if [ ! -d "./output/release" ]; then
mkdir ./output/release
fi

#对原apk进行反编译解包
echo 正在反编译原Apk
java -jar $apktool d -f $app.apk -o $app

#从channels.txt文件中逐行读取渠道号，并打包
while read -a channels
do

channel=${channels[@]}
if [[ ${channel:0:1} != "#" ]]; then
#将字符串中的official替换为channel的值
outputApk=./output/$buildType/${app/official/$channel}.apk
outputUnsignedApk=./output/temp/${app/official/$channel}.apk

echo 当前正在打包的渠道号为${channel}
#修改manifest中的渠道号
echo 正在修改manifest中的渠道号
java -jar $manifestTool $app/AndroidManifest.xml $app/AndroidManifest.xml $channelKey $channel

#对app重新打包
echo 正在对Apk重新打包
java -jar $apktool b $app $app.apk

#从dist目录拷贝到根目录
echo 正在移动Apk位置
cp $app/dist/$app.apk $outputUnsignedApk

#对apk进行签名
echo 正在对修改后的Apk进行签名
jarsigner -verbose -keystore $keystoreSrc -signedjar $outputApk $outputUnsignedApk -storepass $storepass $keyAlias

echo 已完成对渠道号为${channel}的打包;
fi

done < $channelsFile

#删除临时文件夹
echo 正在删除临时文件夹
rm -rf ./output/temp
rm -rf $app

echo 已经打完所有渠道包