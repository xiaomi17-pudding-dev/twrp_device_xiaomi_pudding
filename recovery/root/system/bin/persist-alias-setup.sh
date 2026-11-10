#!/system/bin/sh

log_step() {
    log -t twrp-persist "pudding-fix22AAL-persist: $1"
}

for _i in 1 2 3 4 5 6 7 8 9 10; do
    if awk '$2=="/mnt/vendor/persist"{found=1} END{exit(found?0:1)}' /proc/mounts 2>/dev/null; then
        break
    fi
    sleep 1
done

if ! awk '$2=="/mnt/vendor/persist"{found=1} END{exit(found?0:1)}' /proc/mounts 2>/dev/null; then
    log_step "mount /mnt/vendor/persist non presente"
    exit 0
fi

if awk '$2=="/persist"{found=1} END{exit(found?0:1)}' /proc/mounts 2>/dev/null; then
    log_step "/persist gia montato come mountpoint reale; non tocco nulla"
    exit 0
fi

if [ -L /persist ]; then
    target="$(readlink /persist 2>/dev/null)"
    if [ "$target" = "/mnt/vendor/persist" ]; then
        log_step "symlink /persist gia corretto"
        exit 0
    fi
    rm -f /persist 2>/dev/null
fi

rmdir /persist 2>/dev/null || rm -rf /persist 2>/dev/null
ln -s /mnt/vendor/persist /persist
restorecon /persist 2>/dev/null || true
log_step "alias pronto ls=$(ls -ld /persist /mnt/vendor/persist 2>/dev/null | tr '\n' ';')"
