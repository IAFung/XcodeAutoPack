#工程名
read -p "Please enter your projectName: " name
project_name=$name

while true; do
read -p "Do you wish to get Release? Y/N: " yn
case $yn in
[Yy]* ) development_mode=Release; break;;
[Nn]* ) development_mode=Debug; break;;
* ) echo "yes release  no debug";;
esac
done
##打包模式 Debug/Release
#development_mode=Release

#scheme名
scheme_name=$name


#plist文件所在路径
exportOptionsPlistPath=./DevelopmentExportOptionsPlist.plist

#导出.ipa文件所在路径
exportFilePath=~/Desktop/$project_name-ipa

while true; do
read -p " 是否包含workspace? 输入Y或N: " parameter
case $parameter in
[YyNn]* )  break;;
* ) echo "请输入YES or NO";;
esac
done

echo '***工程名为 : '${project_name}
echo '***打包模式为 : '${development_mode}
echo '***workspace : '${parameter}
sleep 1.0

echo '*** 正在 清理工程 ***'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit 
echo '*** 清理完成 ***'
echo '*** 正在 编译工程 For '${development_mode}
case $parameter in
[Yy]* )xcodebuild \
archive -workspace ${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath build/${project_name}.xcarchive -quiet  || exit;;
[Nn]* )xcodebuild \
archive -project ${project_name}.xcodeproj \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath build/${project_name}.xcarchive -quiet  || exit;;
esac

echo '*** 编译完成 ***'

echo '*** 正在 打包 ***'
xcodebuild -exportArchive -archivePath build/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportFilePath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

# 删除build包
if [[ -d build ]]; then
    rm -rf build -r
fi

if [ -e $exportFilePath/$scheme_name.ipa ]; then
    echo "*** .ipa文件已导出 ***"
    cd ${exportFilePath}
    echo "*** 开始上传.ipa文件 ***"
    #此处上传分发应用
#此处上传分发应用
curl -F "file=@$exportFilePath/$scheme_name.ipa" \
-F "uKey=272940f76e3572a5c197d25b295b5dac" \
-F "_api_key=f26c7743a02e8303290886591ed06283" \
https://www.pgyer.com/apiv1/app/upload

    echo "*** .ipa文件上传成功 ***"
else
    echo "*** 创建.ipa文件失败 ***"
fi
echo '*** 打包完成 ***'

