# Shared by install.sh and setup-gui.sh; also run directly by the GUI's
# in-app updater (bash helpers/gui-setup.sh) to recompile translations after
# a git pull.
#
# The GUI runs from the project checkout, not from a package, so its gettext
# catalogs live there too: po/<lang>.po is compiled to
# locale/<lang>/LC_MESSAGES/cs9711-manager.mo, which cs9711-manager.py looks
# for next to itself. Non-fatal by design: without msgfmt (gettext) the GUI
# simply stays in English.

# build_locale <project-dir> — returns 1 only if msgfmt is unavailable.
build_locale() {
    local dir="$1" lang
    command -v msgfmt >/dev/null 2>&1 || return 1
    [ -f "$dir/po/LINGUAS" ] || return 0
    for lang in $(grep -v '^#' "$dir/po/LINGUAS"); do
        [ -f "$dir/po/$lang.po" ] || continue
        mkdir -p "$dir/locale/$lang/LC_MESSAGES"
        msgfmt -o "$dir/locale/$lang/LC_MESSAGES/cs9711-manager.mo" "$dir/po/$lang.po" || true
    done
}

# install_desktop_entry <project-dir> — writes the per-user launcher from the
# cs9711-manager.desktop template (the one place its translated Name[xx] /
# Comment[xx] lines live), with Exec and Icon made absolute. The Icon is a
# file path on purpose: theme icon names don't resolve on every desktop.
install_desktop_entry() {
    local dir="$1"
    local dest="$HOME/.local/share/applications/cs9711-manager.desktop"
    mkdir -p "$HOME/.local/share/applications"
    sed -e '/^#/d' \
        -e "s|^Exec=.*|Exec=python3 $dir/cs9711-manager.py|" \
        -e "s|^Icon=.*|Icon=$dir/assets/cs9711-manager.svg|" \
        "$dir/cs9711-manager.desktop" > "$dest"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    build_locale "$(cd "$(dirname "$0")/.." && pwd)"
fi
