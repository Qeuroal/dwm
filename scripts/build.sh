#!/bin/bash

# 打patch
if [ -d "patch" ]; then
    ls patch | grep "diff" | xargs -I {} cat ./patch/{} | patch
fi
# 打after patch
if [ -d "patch/after" ]; then
    ls patch/after | grep "diff" | xargs -I {} cat ./patch/after/{} | patch
fi

# make
make

# {{{> substitute
if [[ -e "./config.h" ]]; then
    sed -i 's/static const char \*fonts\[\]          = { "monospace:size=10" }/static const char *fonts[]          = { "JetbrainsMonoNL Nerd Font:size=14" }/g' ./config.h
    sed -i 's/static const char dmenufont\[\]       = "monospace:size=10"/static const char dmenufont[]       = "JetbrainsMonoNL Nerd Font:size=14"/g' ./config.h
    sed -i 's/static const char \*termcmd\[\]  = { "st", NULL }/ static const char *termcmd[]  = { "alacritty", NULL }/g' ./config.h
    sed -i 's/static const unsigned int gappih    = 20/static const unsigned int gappih    = 6/g' ./config.h
    sed -i 's/static const unsigned int gappiv    = 10/static const unsigned int gappiv    = 6/g' ./config.h
    sed -i 's/static const unsigned int gappoh    = 10/static const unsigned int gappoh    = 3/g' ./config.h
    sed -i 's/static const unsigned int gappov    = 30/static const unsigned int gappov    = 3/g' ./config.h
    sed -i 's/MODKEY|ShiftMask,             XK_j,      focusstackhid/MODKEY|ControlMask,             XK_j,      focusstackhid/g' ./config.h
    sed -i 's/MODKEY|ShiftMask,             XK_k,      focusstackhid/MODKEY|ControlMask,             XK_k,      focusstackhid/g' ./config.h
    sed -i 's/MODKEY,                       XK_s,      show/MODKEY|ControlMask,                       XK_s,      show/g' ./config.h
    sed -i 's/MODKEY|ShiftMask,             XK_s,      showall/MODKEY|ControlMask|ShiftMask,             XK_s,      showall/g' ./config.h
    sed -i 's/MODKEY,                       XK_h,      hide/MODKEY|ControlMask,                       XK_h,      hide/g' ./config.h
    sed -i 's/static const char \*scratchpadcmd\[\] = { "st", "-t", scratchpadname, "-g", "120x34", NULL }/static const char *scratchpadcmd[] = { "alacritty", "-t", scratchpadname, NULL }/g' ./config.h
    # modify MODKEY to Mod4Mask
    sed -i 's/#define MODKEY Mod1Mask/#define MODKEY Mod4Mask/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_u,      incrgaps,       {.i = +1 } },/\/\/ { MODKEY|Mod4Mask,              XK_u,      incrgaps,       {.i = +1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_u,      incrgaps,       {.i = -1 } },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_u,      incrgaps,       {.i = -1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_i,      incrigaps,      {.i = +1 } },/\/\/ { MODKEY|Mod4Mask,              XK_i,      incrigaps,      {.i = +1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_i,      incrigaps,      {.i = -1 } },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_i,      incrigaps,      {.i = -1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_o,      incrogaps,      {.i = +1 } },/\/\/ { MODKEY|Mod4Mask,              XK_o,      incrogaps,      {.i = +1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_o,      incrogaps,      {.i = -1 } },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_o,      incrogaps,      {.i = -1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_6,      incrihgaps,     {.i = +1 } },/\/\/ { MODKEY|Mod4Mask,              XK_6,      incrihgaps,     {.i = +1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_6,      incrihgaps,     {.i = -1 } },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_6,      incrihgaps,     {.i = -1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_7,      incrivgaps,     {.i = +1 } },/\/\/ { MODKEY|Mod4Mask,              XK_7,      incrivgaps,     {.i = +1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_7,      incrivgaps,     {.i = -1 } },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_7,      incrivgaps,     {.i = -1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_8,      incrohgaps,     {.i = +1 } },/\/\/ { MODKEY|Mod4Mask,              XK_8,      incrohgaps,     {.i = +1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_8,      incrohgaps,     {.i = -1 } },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_8,      incrohgaps,     {.i = -1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_9,      incrovgaps,     {.i = +1 } },/\/\/ { MODKEY|Mod4Mask,              XK_9,      incrovgaps,     {.i = +1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_9,      incrovgaps,     {.i = -1 } },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_9,      incrovgaps,     {.i = -1 } },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask,              XK_0,      togglegaps,     {0} },/\/\/ { MODKEY|Mod4Mask,              XK_0,      togglegaps,     {0} },/g' ./config.h
    sed -i 's/{ MODKEY|Mod4Mask|ShiftMask,    XK_0,      defaultgaps,    {0} },/\/\/ { MODKEY|Mod4Mask|ShiftMask,    XK_0,      defaultgaps,    {0} },/g' ./config.h
    # color
    sed -i 's/static const unsigned int borderpx  = 1/static const unsigned int borderpx  = 3/g' ./config.h
    sed -i '/static const char col_cyan\[\]/astatic const char col_border[]      = "#ff3030";' ./config.h
    sed -i 's/\[SchemeSel\]  = { col_gray4, col_cyan,  col_cyan  },/[SchemeSel]  = { col_gray4, col_cyan,  col_border },/g' ./config.h

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


