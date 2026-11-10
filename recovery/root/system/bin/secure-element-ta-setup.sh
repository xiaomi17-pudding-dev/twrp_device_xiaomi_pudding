#!/system/bin/sh
# pudding fix22ZR:
# FIX 1: chmod 0755 on OUT_ROOT and OUT_DIR after mkdir (inherited from fix22ZQ)
# FIX 2: copy SRC_DIR first, then firmware TAs override (inherited from fix22ZQ)
# FIX 3 (NEW — fix22ZR): persist partition is now mounted by the RC (not tmpfs)
#        No persist-related changes needed here; the RC fix22ZR mounts it on fs.
#        This script keeps the sleep-18 delay and TA staging logic unchanged.

SRC_DIR="/system/bin/twrp_secure_element_ta"
OUT_ROOT="/tmp/secure_element_fwroot"
OUT_DIR="$OUT_ROOT/image"
FW_MNT="/firmware"

log_step() {
    log -t twrp-secelt "pudding-fix22ZR: $1"
}

run_cmd() {
    "$@"
    rc=$?
    log_step "$* rc=$rc"
    return $rc
}

# Log persist mount status at startup (diagnostic)
persist_fstype=$(awk '$2=="/mnt/vendor/persist"{print $3}' /proc/mounts 2>/dev/null)
log_step "persist fstype at ta-setup start: ${persist_fstype:-(not mounted)}"

sleep 18
log_step "preparing secure-element staging dir"

# Re-check persist after sleep (should still be ext4 from RC mount)
persist_fstype=$(awk '$2=="/mnt/vendor/persist"{print $3}' /proc/mounts 2>/dev/null)
log_step "persist fstype after sleep-18: ${persist_fstype:-(not mounted)}"

if [ ! -d "$SRC_DIR" ]; then
    log_step "source dir missing: $SRC_DIR"
    exit 1
fi

if [ ! -d "$FW_MNT/image" ]; then
    log_step "firmware image dir missing: $FW_MNT/image"
    exit 1
fi

run_cmd rm -rf "$OUT_ROOT" || exit 1
run_cmd mkdir -p "$OUT_DIR" || exit 1

# FIX 1: chmod 0755 so that system user (vendor.secure_element) can traverse
chmod 0755 "$OUT_ROOT"
log_step "chmod OUT_ROOT rc=$?"
chmod 0755 "$OUT_DIR"
log_step "chmod OUT_DIR rc=$?"

# FIX 2: copy SRC_DIR stubs/cross-device TAs first (lower priority fallback)
cp -af "$SRC_DIR"/. "$OUT_DIR"/ 2>/dev/null
log_step "cp SRC_DIR rc=$?"

# Copy device-native firmware TAs last — they override SRC_DIR files
cp -af "$FW_MNT/image"/. "$OUT_DIR"/
log_step "cp firmware image rc=$?"

chmod 0644 "$OUT_DIR"/* 2>/dev/null
log_step "chmod files rc=$?"

for name in \
    st_eseservice.b00 \
    eseservice.b00 \
    gpqese.b00 \
    FD719D50-FFFB-11EB-9A03-0242AC130003.b00 \
    FD719D50-FFFB-11EB-9A03-0242AC130003.mdt \
    32552B22-89FE-42B4-8A45-A0C4E2DB0326.b00 \
    32552B22-89FE-42B4-8A45-A0C4E2DB0326.mdt \
    05B04A44-BF30-42DF-9E2F-B366B980ED19.b00 \
    05B04A44-BF30-42DF-9E2F-B366B980ED19.mdt
do
    if [ -f "$OUT_DIR/$name" ]; then
        log_step "staged ok: $name ($(wc -c < "$OUT_DIR/$name") bytes)"
    else
        log_step "staged MISSING: $name"
    fi
done

setprop twrp.pudding.fix22zr.ta_staged 1
setprop twrp.pudding.fix22zr.ready 1
log_step "secure-element staging dir ready"
