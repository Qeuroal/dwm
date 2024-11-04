#!/bin/bash

#{{{> .dwm
#
if [ ! -d ~/.dwm ]; then
    mkdir -p ~/.dwm
fi
cp ./scripts/autostart.sh ~/.dwm/autostart.sh
ln -sf `realpath ./scripts` ~/.dwm/
if [ ! -e ~/.dwm/status_config ]; then
    cp -f `realpath ./scripts/status_config` ~/.dwm/
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



