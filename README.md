# dwm

基于 X11 的动态窗口管理器，包含多布局、窗口规则、状态栏和桌面启动脚本。

## 安装

### 安装依赖

Arch Linux 下执行：

```sh
make deps
```

该目标安装编译工具、X11、终端、菜单、桌面组件、字体和音频后端。
`ttf-lxgw-wenkai-mono` 来自 archlinuxcn，需先启用该仓库。

只安装字体：

```sh
make fonts
```

主要依赖：

| 用途 | 软件包 |
| --- | --- |
| 编译 | gcc、make、patch、git、libx11、libxft、libxinerama、libxrender |
| X11 与启动 | xorg-server、xorg-xinit、dmenu、ghostty |
| 合成、壁纸和通知 | picom、feh、libnotify、dunst |
| 状态栏与硬件控制 | xorg-xsetroot、acpi、bc、iproute2、alsa-utils、brightnessctl、xorg-xinput、xorg-xrandr |
| 音量与蓝牙 | libpulse、bluez、bluez-utils，以及 PulseAudio 或 pipewire-pulse |
| 网络和电源管理 | network-manager-applet、xfce4-power-manager |

`make deps` 只安装软件包，不启用服务或安装 dwm。

### 应用补丁并编译

**先保存工作区改动及需要保留的未跟踪文件。**
`make rebuild` 会执行 `git restore .` 和 `git clean -fd`。

```sh
make rebuild
make
sudo make install
```

`make rebuild` 按 `patch/`、`patch/after/`、`patch/custom/` 的顺序应用补丁，并建立桌面配置链接。
安装路径在 [config.mk](config.mk) 中设置，默认是 `/usr/local`。

### 启动

在 `~/.xinitrc` 中加入：

```sh
exec dwm
```

然后通过 `startx` 启动 X11 会话。连接指定 X11 显示时，设置 `DISPLAY`。

## 配置

- [patch/custom/qrl_config_dwm.diff](patch/custom/qrl_config_dwm.diff)：字体、快捷键、布局及窗口规则。
- [kit/autostart.sh](kit/autostart.sh)：桌面自启动程序。
- [kit/profiles/status_config](kit/profiles/status_config)：状态栏显示项目。
- [kit/profiles/picom.conf](kit/profiles/picom.conf)：透明、阴影和圆角。
- [kit/profiles/dunst/dunstrc](kit/profiles/dunst/dunstrc)：通知样式。
- [kit/profiles/gtk-3.0/settings.ini](kit/profiles/gtk-3.0/settings.ini) 和 [GTK4 配置](kit/profiles/gtk-4.0/settings.ini)：GTK 字体。

dwm 使用编译期配置。修改生成的 `config.h` 后需重新编译；需要长期保留的定制应写入自定义补丁。

构建脚本建立以下链接：

| 入口 | 项目内目标 |
| --- | --- |
| `~/.dwm/autostart.sh` | `kit/autostart.sh` |
| `~/.dwm/kit` | `kit/` |
| `~/.dwm/status_config` | `kit/profiles/status_config` |
| `~/.config/dunst` | `kit/profiles/dunst/` |
| `~/.config/gtk-3.0` | `kit/profiles/gtk-3.0/` |
| `~/.config/gtk-4.0` | `kit/profiles/gtk-4.0/` |
| `~/.xprofile` | `dotfiles/.xprofile`（文件存在时） |

将壁纸放到 `~/.dwm/pictures/`。显示器布局脚本和亮度脚本中的输出接口、背光设备名需按硬件调整，可用 `xrandr` 和 `brightnessctl --list` 查询。

picom 配置使用 `rules` 语法，需要支持该语法的 picom。
圆角仅应用于有边框、受管理、非全屏的普通窗口；单窗口或单片布局去掉边框时没有圆角。
通知由 dunst 显示，libnotify 仅提供发送工具。

## 字体和输入法

| 字体 | 安装方式或用途 |
| --- | --- |
| JetBrainsMonoNL Nerd Font | `ttf-jetbrains-mono-nerd`，用于 dwm、dmenu 和状态栏图标 |
| LXGW WenKai Mono | `ttf-lxgw-wenkai-mono`，用于 Ghostty 中文回退 |
| Noto Sans SC | 自行安装同名字体，或调整 dwm、dunst 中的字体配置 |
| Microsoft YaHei | GTK 配置指定的字体；自行准备该字体，或替换为已安装的字体 |

安装后刷新缓存并确认名称匹配：

```sh
fc-cache -f
fc-match 'JetbrainsMonoNL Nerd Font'
fc-match 'LXGW WenKai Mono'
fc-match 'Noto Sans SC'
fc-match 'Microsoft YaHei'
```

输入法可使用 `fcitx5`、`fcitx5-rime`、`fcitx5-gtk`、`fcitx5-qt` 和 `fcitx5-configtool`，按需安装。
[dotfiles/.xprofile](dotfiles/.xprofile) 设置输入法环境变量；Rime 词库和方案单独配置。

## 音频和蓝牙

音量键和状态栏通过 `pactl` 控制默认输出，支持扬声器及蓝牙耳机。

`make deps` 默认安装 `pulseaudio` 和 `pulseaudio-bluetooth`；
如果已安装 `pipewire-pulse`，则保留该后端，不另装 PulseAudio。

按所用后端启用用户服务：

```sh
# PulseAudio
systemctl --user enable --now pulseaudio.socket

# 或 PipeWire
systemctl --user enable --now pipewire-pulse.socket wireplumber.service
```

使用蓝牙时还需启用系统服务：

```sh
sudo systemctl enable --now bluetooth.service
```

如果使用 PulseAudio，同时运行 WirePlumber（例如用于屏幕共享），部署以下配置，避免两者争抢蓝牙和 ALSA 声卡：

```sh
mkdir -p ~/.config/wireplumber/wireplumber.conf.d
cp kit/profiles/wireplumber/51-pulseaudio-bluetooth.conf ~/.config/wireplumber/wireplumber.conf.d/
systemctl --user restart wireplumber pulseaudio
```

**使用 pipewire-pulse 时不要部署这份配置；切换到它之前先移除该配置。**

查看输出设备、音量和静音状态：

```sh
pactl list short sinks
pactl get-default-sink
pactl get-sink-volume @DEFAULT_SINK@
pactl get-sink-mute @DEFAULT_SINK@
```

## 可选工具

- `arandr`：图形化配置显示器布局。
- `xorg-xprop`、`xorg-xev`：查询窗口属性和按键事件。
- `maim`、`ksnip`：截图及标注。
- `xclip`：剪贴板操作。
- `slock`：锁屏。
- `screenkey`：显示按键，供 `kit/tools/sck-tog.sh` 使用。

`mailsync` 是邮件同步脚本调用的外部命令；使用该功能时需另行提供，不使用时可关闭相应自启动项。
