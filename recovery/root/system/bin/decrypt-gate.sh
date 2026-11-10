#!/system/bin/sh

log_step() {
    log -t twrp-decrypt-gate "pudding-fix22AAL: $1"
}

setprop twrp.pudding.fix22aal.decrypt_gate 1
log_step "delay start; waiting before prepdecrypt"

sleep 8

for _i in 1 2 3 4 5 6 7 8; do
    km="$(getprop init.svc.vendor.keymint)"
    sb="$(getprop init.svc.vendor.keymint-strongbox)"
    se="$(getprop init.svc.vendor.secure_element)"
    om="$(getprop init.svc.odm.se_omapi)"
    log_step "state keymint=$km strongbox=$sb secure_element=$se se_omapi=$om"
    if [ "$km" = "running" ] && [ "$sb" = "running" ] && [ "$se" = "running" ] && [ "$om" = "running" ]; then
        break
    fi
    sleep 2
done

setprop twrp.pudding.fix22aal.predecrypt_start 1
log_step "starting odm.prepdecrypt"
setprop ctl.start odm.prepdecrypt
