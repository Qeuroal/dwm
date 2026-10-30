# dwm - dynamic window manager
# See LICENSE file for copyright and license details.

include config.mk

.PHONY: all clean dist \
	install uninstall \
	rebuild \
	fonts deps \
	gm gitmerge

SRC = drw.c dwm.c util.c
OBJ = ${SRC:.c=.o}

all: dwm

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk

config.h:
	cp config.def.h $@

dwm: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

clean:
	rm -f dwm ${OBJ} dwm-${VERSION}.tar.gz

dist: clean
	mkdir -p dwm-${VERSION}
	cp -R LICENSE Makefile README config.def.h config.mk\
		dwm.1 drw.h util.h ${SRC} dwm.png transient.c dwm-${VERSION}
	tar -cf dwm-${VERSION}.tar dwm-${VERSION}
	gzip dwm-${VERSION}.tar
	rm -rf dwm-${VERSION}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f dwm ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/dwm
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < dwm.1 > ${DESTDIR}${MANPREFIX}/man1/dwm.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/dwm.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwm\
		${DESTDIR}${MANPREFIX}/man1/dwm.1

rebuild:
	bash ./kit/build.sh

fonts:
	@test -f /etc/arch-release || { printf 'make fonts/deps supports Arch Linux only\n' >&2; exit 1; }
	sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-lxgw-wenkai-mono

deps: fonts
	sudo pacman -S --needed \
		gcc make patch git libx11 libxft libxinerama libxrender \
		xorg-server xorg-xinit dmenu ghostty \
		picom feh xorg-xsetroot xorg-xinput xorg-xrandr \
		acpi bc iproute2 alsa-utils libpulse bluez bluez-utils brightnessctl libnotify dunst \
		network-manager-applet xfce4-power-manager \
		pipewire pipewire-audio pipewire-pulse pipewire-alsa wireplumber

GITMERGE_INFO ?=
MERGE_MSG = merge dev$(if $(GITMERGE_INFO), ($(GITMERGE_INFO)))
MASTER_WT = $(shell git worktree list --porcelain | awk '/^worktree / {p=substr($$0,10)} /^branch refs\/heads\/master$$/ {print p; exit}')

gm gitmerge:
ifneq ($(MASTER_WT),)
	@git -C "$(MASTER_WT)" merge --no-ff -m "$(MERGE_MSG)" dev
	@git -C "$(MASTER_WT)" push
else
	@git switch master && git merge --no-ff -m "$(MERGE_MSG)" dev && git push && git switch dev
endif

