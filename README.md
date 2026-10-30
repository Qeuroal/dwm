# dwm 本机依赖与迁移清单

核对日期：2026-10-30。系统为 Arch Linux。

本清单根据本机 `pacman -Q`、命令所属软件包、字体实际匹配结果，以及项目中的 `Makefile`、`config.mk`、自定义补丁、启动和状态栏脚本整理。已安装不等于服务已经启动；也不能仅凭包记录判断软件最初是否专门为了 dwm 安装。

## 1. 编译 dwm

以下软件包均已安装。

| 软件包 | 本机版本 | 用途 |
| --- | --- | --- |
| `base-devel` | `1-2` | Arch 编译工具集合；迁移时可用于补齐常用构建工具 |
| `gcc` | `16.2.1+r23+gd564253eb6c8-1` | 提供 C 编译器，当前 `config.mk` 使用 `cc` |
| `make` | `4.4.1-3` | 执行编译、安装及依赖目标 |
| `patch` | `2.8.1-1` | 应用 `patch/` 中的 dwm 补丁 |
| `git` | `2.56.0-1` | 管理代码，构建脚本也调用它 |
| `libx11` | `1.8.14-1` | X11 窗口操作 |
| `libxft` | `2.3.9-1` | 状态栏文字和字体渲染 |
| `libxinerama` | `1.1.6-1` | 多显示器支持，当前构建启用 `XINERAMA` |
| `libxrender` | `0.9.13-1` | X Render 扩展，供透明等补丁使用 |
| `freetype2` | `2.15.0-1` | 字体渲染和头文件 |
| `fontconfig` | `2:2.18.3-2` | 字体查找、匹配与缓存 |

## 2. 当前桌面实际调用的程序

以下软件包均已安装。部分是间接依赖，不一定出现在 `pacman -Qqe` 的显式安装列表中。

| 软件包 | 本机版本 | 程序及用途 | 项目入口 |
| --- | --- | --- | --- |
| `xorg-server` | `21.1.25-2` | X11 图形会话基础 | dwm 运行环境 |
| `xorg-xinit` | `1.4.4-1` | `startx` / `xinit` 启动 X 会话 | `~/.xinitrc` |
| `dmenu` | `5.4-1` | `dmenu_run` 应用启动菜单 | 自定义 dwm 快捷键 |
| `ghostty` | `1.4.0-1` | 默认终端、scratchpad 终端 | 自定义 dwm 快捷键 |
| `picom` | `13-2` | 圆角、阴影、透明和淡入淡出 | `kit/autostart.sh`、`kit/profiles/picom.conf` |
| `feh` | `3.13.1-1` | 随机设置桌面壁纸 | `kit/wallpaper/wp-change.sh` |
| `xorg-xsetroot` | `1.1.4-1` | `xsetroot -name` 更新 dwm 状态栏 | `kit/status/dwm-status-refresh.sh` |
| `acpi` | `1.8-2` | 读取电池电量 | 状态栏电池显示 |
| `bc` | `1.08.2-1` | 计算网络速率 | 状态栏脚本 |
| `iproute2` | `7.3.0-1` | `ip` 查询网络接口 | 状态栏脚本 |
| `alsa-utils` | `1.2.16-1` | `amixer` 调音量、切换静音；另提供 `alsamixer` | `kit/audio/`、状态栏 ALSA 模块 |
| `brightnessctl` | `0.5.1-3` | 调节背光亮度 | `kit/brightness/` |
| `libnotify` | `0.8.9-1` | `notify-send` 发送音量、亮度通知 | 音量和亮度脚本 |
| `dunst` | `1.13.2-3` | 显示通知弹窗和进度条 | `kit/profiles/dunst/dunstrc` |
| `network-manager-applet` | `1.36.0-2` | `nm-applet` 网络托盘图标 | `kit/autostart.sh` |
| `networkmanager` | `1.58.1-2` | 网络管理服务与 `nmcli` | 网络托盘及可选状态栏模块 |
| `xfce4-power-manager` | `4.20.1-1` | 电源管理程序 | `kit/autostart.sh` |
| `xorg-xinput` | `1.6.4-2` | `xinput` 配置触控板点击和自然滚动 | `kit/input/` |
| `xf86-input-libinput` | `1.5.0-1` | Xorg 输入驱动，提供脚本使用的 libinput 属性 | 触控板运行环境 |
| `libinput` | `1.32.0-1` | 输入设备处理库 | 输入驱动依赖 |
| `xorg-xrdb` | `1.2.3-1` | `xrdb` 加载 Xresources | `dotfiles/.xprofile` |
| `dbus` | `1.16.2-2` | 会话通信，提供 `dbus-update-activation-environment` | `.xprofile`、通知等桌面组件 |
| `adwaita-icon-theme` | `51.0-1` | dunst 配置指定的 Adwaita 图标主题 | `kit/profiles/dunst/dunstrc` |

补充说明：

- 音量链路是：快捷键 → `kit/audio/` → `amixer` → `notify-send` → `dunst`。`alsa-utils` 是 ALSA 命令行工具集合，不是通知程序，也不是音频服务器。
- 当前状态栏只加载 `dwmbar-functions/dwm_alsa.sh`。电池、日期、网速等还有写在主脚本中的函数。
- 即使 `status_config` 关闭网速显示，主脚本目前仍会执行网络速率计算，因此 `iproute2` 和 `bc` 仍有调用。
- `dunst` 没有显式写在 `kit/autostart.sh` 中；不能只检查这个文件就认定通知依赖缺失。

## 3. 本机音频环境

以下软件包已安装，提供这台机器的 PipeWire 音频环境；它们不是编译 dwm 所必需的。

| 软件包 | 本机版本 | 用途 |
| --- | --- | --- |
| `pipewire` | `1:1.6.10-1` | 多媒体服务基础 |
| `pipewire-audio` | `1:1.6.10-1` | PipeWire 音频支持 |
| `pipewire-alsa` | `1:1.6.10-1` | ALSA 应用与 PipeWire 的适配 |
| `pipewire-pulse` | `1:1.6.10-1` | PulseAudio 协议兼容服务 |
| `wireplumber` | `0.5.18-1` | PipeWire 会话和设备策略管理 |
| `libpulse` | `17.0+r134+g77d25a1e6-1` | PulseAudio 客户端库，提供本机的 `pactl` |

## 4. 字体和输入法

### 字体

| 软件包或手动文件 | 状态与用途 |
| --- | --- |
| `ttf-jetbrains-mono-nerd` | 已安装 `3.5.1-2`；dwm 和 dmenu 指定 `JetbrainsMonoNL Nerd Font`，状态栏图标也依赖 Nerd Font 字形 |
| `noto-fonts` | 已安装 `1:2026.10.01-1` |
| `noto-fonts-cjk` | 已安装 `20240730-1`，提供中日韩字体 |
| `noto-fonts-emoji` | 已安装 `1:2.057-1`，提供 emoji 字体 |
| `ttf-lxgw-wenkai` | 已安装 `1.530-1`，属于本机配套字体，当前 dwm 没有直接指定它 |
| `~/.local/share/fonts/win_font/NotoSansSC-VF.ttf` | 手动字体；本机 `fc-match 'Noto Sans SC'` 实际匹配此文件，dwm 和 dunst 使用该字体名称 |
| `~/.local/share/fonts/win_font/msyh.ttc` | 手动字体；本机 `fc-match 'Microsoft YaHei'` 实际匹配此文件，GTK 3/4 配置使用该字体名称 |

另一台电脑即使装了 `noto-fonts-cjk`，也应检查配置中的字体名称是否能正确匹配。安装字体后可执行 `fc-cache -f` 刷新缓存。

### 输入法

以下包均已安装：`fcitx5`、`fcitx5-rime`、`fcitx5-gtk`、`fcitx5-qt`、`fcitx5-configtool`。

`dotfiles/.xprofile` 设置了 `XMODIFIERS`、`QT_IM_MODULE`、`GTK_IM_MODULE`。输入法和 Rime 的详细配置由单独的 flypy 项目维护；本项目的 `make deps` 不负责安装这些包或配置 Rime。

## 5. 已安装的桌面配套工具

这些工具与桌面使用、显示器配置或排查有关，不都由当前启动脚本自动调用。

| 软件包 | 本机版本 | 用途 |
| --- | --- | --- |
| `arandr` | `0.1.11-6` | 图形化配置显示器布局 |
| `xorg-xrandr` | `1.5.4-1` | `xrandr` 应用显示器布局、恢复多屏 |
| `xorg-xprop` | `1.2.8-1` | `xprop` 查询窗口类、类型和状态，排查 dwm 规则 |
| `xorg-xev` | `1.2.7-1` | 查询按键、鼠标和窗口事件 |
| `maim` | `5.8.2-1` | 截图 |
| `xdotool` | `4.20260303.1-1` | X11 键鼠和窗口操作工具 |
| `xclip` | `0.13-6` | X11 剪贴板工具 |
| `slock` | `1.7-1` | 锁屏工具，当前启动脚本没有自动调用 |
| `ksnip` | `1.10.1-6` | 图形化截图和标注工具 |
| `thunar` | `4.20.10-1` | 图形化文件管理器 |
| `xdg-desktop-portal` | `1.22.1-2` | 桌面门户服务 |
| `xdg-desktop-portal-gtk` | `1.15.3-2` | GTK 桌面门户后端；项目有对应文件选择窗口的浮动规则 |
| `gtk3` | `1:3.24.52-2` | GTK 3 应用运行库，项目维护对应字体配置 |
| `gtk4` | `1:4.24.1-1` | GTK 4 应用运行库，项目维护对应字体配置 |
| `xorg-xmodmap` | `1.0.12-1` | `xmodmap`，可选键位脚本使用 |
| `xorg-setxkbmap` | `1.3.5-1` | `setxkbmap`，可选 Colemak 配置及键盘状态模块使用 |

脚本还依赖系统基础工具：`bash`、`coreutils`、`gawk`、`sed`、`grep`、`findutils`、`procps-ng`。本机均已安装。`util-linux` 提供 `flock`，`systemd` 提供 `systemctl`、`udevadm`，用于恢复或休眠脚本。

## 6. 未安装或未启用的可选依赖

- `mailsync`：`kit/autostart.sh` 会启动 `run-mailsync.sh`，但本次检查在 PATH 中没有找到 `mailsync`。这是外部个人命令，需要另行提供；不用邮件同步时可关闭相应自启动项。
- `screenkey`：`kit/tools/sck-tog.sh` 引用它，本机未安装，且不是当前自启动项。
- `xorg-xset` / `xset`：旧键位脚本调用 `xset r rate`；本机未安装该包，也没有找到 `xset`。当前自启动没有启用 Colemak 脚本。
- `pamixer`、`cmus`、`transmission-cli`、`calcurse`、`xorg-xbacklight`、`networkmanager-openvpn`：本机未安装，对应状态栏模块目前也未加载。
- `acpitool`：本机未安装。主状态栏脚本保留的充电时间函数会调用它，但当前电池显示没有调用这个函数。
- `curl`、`jq`：本机已安装；天气、外网 IP 等扩展功能可能使用，当前启用的 ALSA 状态模块不依赖它们。
- `kit/tools/install-brew-packages.sh` 是另一套 Homebrew 开发工具安装脚本，没有被 `make deps` 或 dwm 自启动调用，不作为这份 Arch 桌面核心依赖清单的依据。

## 7. 这台电脑专用的内容

- 亮度脚本固定使用 `brightnessctl -d intel_backlight`。换机器先执行 `brightnessctl --list`，核对实际背光设备名。
- 多屏恢复脚本使用 `eDP-1`、`DP-2`、`DP-5` 等接口名，并加载 `~/.screenlayout/dual.sh`；这些名称和布局需要按新机器重新设置。
- 本机安装了 `linux-t2`、`tiny-dfr`、`apple-t2-audio-config`、`t2fanrd`、`apple-bcm-firmware-fetcher`。这些是当前 Apple T2 机器的内核、Touch Bar、音频、风扇或无线相关配套，不是通用 dwm 依赖，不应直接照搬到普通电脑。

## 8. 在另一台 Arch 电脑安装和核对

项目已经提供核心安装目标，在项目根目录执行：

```bash
make deps
```

这个目标安装编译工具、X11、终端、菜单、picom、壁纸、音量、亮度、通知、网络托盘、电源管理及 Nerd Font；不会启动服务、创建所有配置链接或编译安装 dwm。

本机还具备、但 `make deps` 没有逐项列出的配套包，可按需要补齐：

```bash
sudo pacman -S --needed \
  fontconfig freetype2 xorg-xrdb dbus networkmanager \
  libinput xf86-input-libinput adwaita-icon-theme \
  noto-fonts noto-fonts-cjk noto-fonts-emoji
```

若要沿用本机的音频环境和输入法，再分别安装：

```bash
sudo pacman -S --needed pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber
sudo pacman -S --needed fcitx5 fcitx5-rime fcitx5-gtk fcitx5-qt fcitx5-configtool
```

### 圆角和通知

- 当前 picom 配置使用 `rules` 语法，需要支持统一规则系统的 picom；本机安装版本为 v13。
- 启动命令为 `picom --config ~/.dwm/kit/profiles/picom.conf -b`。
- 当前圆角规则只匹配普通、受管理、非全屏且 `border_width > 0` 的窗口。单窗口或单片布局去掉边框时，没有圆角是当前规则的结果。
- 通知样式配置位于 `kit/profiles/dunst/dunstrc`；只装 `libnotify` 只能提供通知发送工具，还需要通知服务显示弹窗。

### 配置文件和软链接

本机目前的配置关系如下；迁移时要在新机器重新建立，项目的绝对路径不能直接沿用。

| 入口 | 目标 |
| --- | --- |
| `~/.dwm/autostart.sh` | 当前项目的 `kit/autostart.sh` |
| `~/.dwm/kit` | 当前项目的 `kit/` |
| `~/.dwm/status_config` | 当前项目的 `kit/profiles/status_config` |
| `~/.config/dunst` | 当前项目的 `kit/profiles/dunst` |
| `~/.config/gtk-3.0` | 当前项目的 `kit/profiles/gtk-3.0` |
| `~/.config/gtk-4.0` | 当前项目的 `kit/profiles/gtk-4.0` |
| `~/.xprofile` | 构建脚本会链接到当前项目的 `dotfiles/.xprofile` |
| `~/.dwm/pictures` | 本机链接到 `~/Pictures/best`；新机器自行准备图片目录 |

`kit/build.sh` 负责建立大部分链接，但开头包含 `git restore .` 和 `git clean -fd`。应先保存代码修改和需要保留的未跟踪文件，再运行该构建流程。

### 快速检查命令

```bash
picom --version
pgrep -a picom
ls -lL ~/.dwm/autostart.sh ~/.dwm/kit/profiles/picom.conf ~/.config/dunst/dunstrc
command -v dmenu_run ghostty feh amixer brightnessctl notify-send dunst nm-applet xsetroot
fc-match 'JetbrainsMonoNL Nerd Font'
fc-match 'Noto Sans SC'
fc-match 'Microsoft YaHei'
```

本文件中的版本号用于记录本机检查结果，不要求在新电脑上锁定到同一包版本。
