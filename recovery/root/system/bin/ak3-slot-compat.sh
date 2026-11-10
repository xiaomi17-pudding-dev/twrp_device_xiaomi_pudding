#!/system/bin/sh
# pudding fix22AAR:
# Export active slot properties into /odm/etc so AK3 installer-side getprop
# shell functions can resolve ro.boot.slot / ro.boot.slot_suffix without
# touching the recovery-wide getprop binary or rootfs prop files.

log_step() {
    log -t twrp-ak3-slot "pudding-fix22AAR-ak3: $1"
}

get_slot_suffix_live() {
    local slot=""
    slot="$(/system/bin/getprop ro.boot.slot_suffix 2>/dev/null)"
    if [ -z "$slot" ]; then
        slot="$(grep -aoE 'androidboot\.slot_suffix=_[ab]' /proc/bootconfig 2>/dev/null | head -n1 | cut -d= -f2)"
    fi
    if [ -z "$slot" ]; then
        slot="$(grep -aoE 'androidboot\.slot_suffix=_[ab]' /proc/cmdline 2>/dev/null | head -n1 | cut -d= -f2)"
    fi
    if [ -z "$slot" ]; then
        local raw=""
        raw="$(/system/bin/getprop ro.boot.slot 2>/dev/null)"
        if [ -z "$raw" ]; then
            raw="$(grep -aoE 'androidboot\.slot=[ab]' /proc/bootconfig 2>/dev/null | head -n1 | cut -d= -f2)"
        fi
        if [ -z "$raw" ]; then
            raw="$(grep -aoE 'androidboot\.slot=[ab]' /proc/cmdline 2>/dev/null | head -n1 | cut -d= -f2)"
        fi
        [ -n "$raw" ] && slot="_$raw"
    fi
    [ "$slot" = "normal" ] && slot=""
    printf '%s' "$slot"
}

write_prop_file() {
    local dst="$1"
    local tmp="$2"
    local slot_suffix="$3"
    local slot="$4"

    mkdir -p "$(dirname "$dst")" 2>/dev/null || true

    if [ -f "$dst" ]; then
        grep -v '^ro\.boot\.slot_suffix=' "$dst" 2>/dev/null | grep -v '^ro\.boot\.slot=' > "$tmp" || cp -f "$dst" "$tmp"
    else
        : > "$tmp"
    fi

    echo "ro.boot.slot_suffix=$slot_suffix" >> "$tmp"
    echo "ro.boot.slot=$slot" >> "$tmp"

    cp -f "$tmp" "$dst"
}

slot_suffix="$(get_slot_suffix_live)"
if [ -z "$slot_suffix" ]; then
    log_step "slot non trovato"
    exit 0
fi

slot="${slot_suffix#_}"
tmp="/tmp/prop.fix22aar.$$"

write_prop_file /odm/etc/build.prop "$tmp" "$slot_suffix" "$slot"
write_prop_file /odm/etc/default.prop "$tmp" "$slot_suffix" "$slot"
write_prop_file /odm/build.prop "$tmp" "$slot_suffix" "$slot"

cat > /tmp/ak3-slot-compat.env <<EOF
ACTIVE_SLOT=$slot
ACTIVE_SLOT_SUFFIX=$slot_suffix
EOF

chmod 0644 /tmp/ak3-slot-compat.env 2>/dev/null || true
rm -f "$tmp"

log_step "exported slot_suffix=$slot_suffix slot=$slot to /odm/etc"
exit 0
