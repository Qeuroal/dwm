#!/bin/bash

git restore . && git clean -fd

project_dir=$(pwd)
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}

# 桌面脚本和配置
mkdir -p "$HOME/.dwm" "$config_dir"
ln -sfn "$project_dir/kit/autostart.sh" "$HOME/.dwm/autostart.sh"
ln -sfn "$project_dir/kit" "$HOME/.dwm/kit"
ln -sfn "$project_dir/kit/profiles/status_config" "$HOME/.dwm/status_config"

if [[ -f "$project_dir/dotfiles/.xprofile" ]]; then
    ln -sfn "$project_dir/dotfiles/.xprofile" "$HOME/.xprofile"
fi

for profile in dunst gtk-3.0 gtk-4.0; do
    ln -sfnT "$project_dir/kit/profiles/$profile" "$config_dir/$profile"
done

# X 会话入口
if ! grep -q 'exec dwm' "$HOME/.xinitrc" 2>/dev/null; then
    echo "exec dwm" >> "$HOME/.xinitrc"
fi

# 依次应用基础、后置和自定义补丁
for patch_dir in patch patch/after patch/custom; do
    for patch_file in "$patch_dir"/*.diff; do
        [[ -f "$patch_file" ]] || continue
        patch < "$patch_file"
    done
done
