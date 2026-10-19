#!/bin/bash

git restore . && git clean -fd

#{{{> .dwm
#
if [ ! -d ~/.dwm ]; then
    mkdir -p ~/.dwm
fi
cp ./kit/autostart.sh ~/.dwm/autostart.sh
ln -sf `realpath ./kit` ~/.dwm/
ln -sfn "$(realpath ./kit/profiles/status_config)" ~/.dwm/status_config
#<}}}

#{{{> ~/.xprofile
if [[ -e ./dotfiles/.xprofile ]]; then
    [[ -e ~/.xprofile ]] && rm -f ~/.xprofile
    ln -sf $(realpath ./dotfiles/.xprofile) ~/.xprofile
fi
#<}}}

#{{{> .xinitrc
#
if [ ! -e ~/.xinitrc ] || [ `cat ~/.xinitrc | grep -c "exec dwm"` -eq 0 ]; then
    echo "exec dwm" >> ~/.xinitrc
fi
#<}}}

#{{{> patch
#
if [ -d "patch" ]; then
    ls patch | grep "diff" | xargs -I {} cat ./patch/{} | patch
fi
# after patch
if [ -d "patch/after" ]; then
    ls patch/after | grep "diff" | xargs -I {} cat ./patch/after/{} | patch
fi
# custom path
if [ -d "patch/custom" ]; then
    ls patch/custom | grep "diff" | xargs -I {} cat ./patch/custom/{} | patch
fi

#<}}}



