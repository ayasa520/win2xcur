## 将 Windows 的鼠标主题转换为 Linux 适用的版本
脚本大量搬运自 https://github.com/vinceliuice/Colloid-icon-theme

将 ani 连同 inf 文件放在 `src/wincursors`, 执行 `convert.sh`, 转换完成后执行 `install.sh`

TODO: 

- <delete>去除对 win2xcur 的依赖, 直接由 ani 文件获取图片和每帧停留时间等信息.</delete> (太麻烦了, 脚本方便, 虽然依赖的东西有点多)



依赖:

- xorg-xcursorgen
- xcur2png