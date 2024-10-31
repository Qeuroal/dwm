#!/bin/bash

# 打patch
ls patch | grep "diff" | xargs -I {} cat ./patch/{} | patch
# 打after patch
ls patch/after | grep "diff" | xargs -I {} cat ./patch/{} | patch

# {{{> substitute
if [[ -e "./config.h" ]]; then
    sed -i 's/static const char \*fonts\[\]          = { "monospace:size=10" }/static const char *fonts[]          = { "JetbrainsMonoNL Nerd Font:size=14" }/g' ./config.h
    sed -i 's/static const char dmenufont\[\]       = "monospace:size=10"/static const char dmenufont[]       = "JetbrainsMonoNL Nerd Font:size=14"/g' ./config.h
    sed -i 's/static const char \*termcmd\[\]  = { "st", NULL }/ static const char *termcmd[]  = { "alacritty", NULL }/g' ./config.h
    sed -i 's/static const unsigned int gappih    = 20/static const unsigned int gappih    = 6/g' ./config.h
    sed -i 's/static const unsigned int gappiv    = 10/static const unsigned int gappiv    = 6/g' ./config.h
    sed -i 's/static const unsigned int gappoh    = 10/static const unsigned int gappoh    = 3/g' ./config.h
    sed -i 's/static const unsigned int gappov    = 30/static const unsigned int gappov    = 3/g' ./config.h
    sed -i 's/MODKEY|ShiftMask,             XK_j,      focusstackhid/Mod4Mask|ShiftMask,             XK_j,      focusstackhid/g' ./config.h
    sed -i 's/MODKEY|ShiftMask,             XK_k,      focusstackhid/Mod4Mask|ShiftMask,             XK_k,      focusstackhid/g' ./config.h
    sed -i 's/MODKEY,                       XK_s,      show/Mod4Mask|ShiftMask,                       XK_s,      show/g' ./config.h
    sed -i 's/MODKEY|ShiftMask,             XK_s,      showall/Mod4Mask|ShiftMask,             XK_s,      showall/g' ./config.h
    sed -i 's/MODKEY,                       XK_h,      hide/Mod4Mask|ShiftMask,                       XK_h,      hide/g' ./config.h
    sed -i 's/static const char \*scratchpadcmd\[\] = { "st", "-t", scratchpadname, "-g", "120x34", NULL }/static const char *scratchpadcmd[] = { "alacritty", "-t", scratchpadname, NULL }/g' ./config.h
else
    echo "not exist config.h"
fi

# dwm.c
#
if [[ -e "./dwm.c" ]]; then
    sed -i 's/setlayout(&((Arg) { .v = &layouts\[2\] }));/setlayout(\&\(\(Arg\) { .v = last_layout }\)\);/g' ./dwm.c
else
    echo "not exist dwm.c"
fi
# <}}}


