## 将 Windows 的鼠标主题转换为 Linux 适用的版本
脚本大量搬运自 https://github.com/vinceliuice/Colloid-icon-theme

config-example 是针对 https://www.bilibili.com/video/BV1bG4y1x7YY/ 写的配置, 将里面的文件放入 `src/config` 目录并将原 up 主提供的压缩文件解压到 `src/wincusors` 目录. 然后 `./convert.sh` 选 1 "使用已有的配置"

TODO: 

- 去除对 win2xcur 的依赖, 直接由 ani 文件获取图片和每帧停留时间等信息.