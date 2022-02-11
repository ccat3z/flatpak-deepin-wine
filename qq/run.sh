#! /bin/bash

set -e

export WINE="deepin-wine5"
export WINEPREFIX="$HOME/.wine"
FILESYSTEM_ARCHIVE="/app/share/qq/fs.7z"
FILESYSTEM_ARCHIVE_SHA256="$(sha256sum "$FILESYSTEM_ARCHIVE" | cut -d' ' -f1)"

log () {
    echo "$@" >&2
}

extract_fs () {
    log "extract fs..."
    if [ -d "$WINEPREFIX" ]; then
        rm -rf "${WINEPREFIX:?}"/{,.[!.],..?}*
    else
	    mkdir -p "$WINEPREFIX"
    fi

	7z x "$FILESYSTEM_ARCHIVE" -o"$WINEPREFIX"
	mv "$WINEPREFIX/drive_c/users/@current_user@" "$WINEPREFIX/drive_c/users/$USER"
	sed -i "s#@current_user@#$USER#" "$WINEPREFIX"/*.reg
    ln -sf "$HOME" "$WINEPREFIX/dosdevices/y:"
}

fix_font () {
    simsun_font_path="$(fc-list -f "%{file}\n" | sort -u | grep simsun.ttc)"
    if [ -n "$simsun_font_path" ]; then
        cp "$simsun_font_path" "$WINEPREFIX/drive_c/windows/Fonts/simsun.ttc"
    fi
}

if [ ! -d "$WINEPREFIX" ] || [ "$(cat "$WINEPREFIX/.fs-checksum" 2> /dev/null)" != "$FILESYSTEM_ARCHIVE_SHA256" ]; then
    log "prepare wineprefix..."
    extract_fs
    echo "$FILESYSTEM_ARCHIVE_SHA256" > "$WINEPREFIX/.fs-checksum"
    fix_font
fi

log "run qq.exe..."
"$WINE" "c:/Program Files/Tencent/QQ/Bin/QQ.exe"