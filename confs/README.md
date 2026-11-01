
# 配置

- 滚轮反转: 90-natural-scrolling.conf -> `/etc/X11/xorg.conf.d/90-natural-scrolling.conf`
- 触摸板轻触点击: 30-touchpad.conf -> `/etc/X11/xorg.conf.d/30-touchpad.conf`

# 验证

xinput list
xinput list-props "触摸板设备名称" | grep -E 'Tapping Enabled|Natural Scrolling Enabled'


