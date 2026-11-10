#!/system/bin/sh
# pudding fix22AAL:
# decrypt already works; keep the noisy sidecars out of the initial PIN window
# and bring them up only after the UI has settled.

log_step() {
    log -t twrp-secelt "pudding-fix22AAL-followup: $1"
}

sleep 2
setprop twrp.pudding.fix22aal.followup 1
log_step "pre-sidecar states secure=$(getprop init.svc.vendor.secure_element) strongbox=$(getprop init.svc.vendor.keymint-strongbox) omapi=$(getprop init.svc.odm.se_omapi) mlipay=$(getprop init.svc.vendor.mlipay) idm=$(getprop init.svc.vendor.idmanger) mtd=$(getprop init.svc.vendor.mtdservice)"

setprop ctl.stop vendor.mtdservice
setprop ctl.stop vendor.mlipay
setprop ctl.stop vendor.idmanger
setprop ctl.stop vendor.qwesd
setprop ctl.stop vendor.minkdaemon
log_step "stopped secondary sidecars before the PIN window"

sleep 20
log_step "initial PIN/UI window elapsed; starting secondary sidecars"

setprop ctl.start vendor.minkdaemon
log_step "started vendor.minkdaemon"

sleep 3
setprop ctl.start vendor.qwesd
log_step "started vendor.qwesd"

sleep 8
log_step "post-qwes settle mink=$(getprop init.svc.vendor.minkdaemon) qwes=$(getprop init.svc.vendor.qwesd)"

setprop ctl.start vendor.idmanger
log_step "started vendor.idmanger"

sleep 2
setprop ctl.start vendor.mlipay
log_step "started vendor.mlipay"

sleep 6
setprop ctl.start vendor.mtdservice
log_step "started vendor.mtdservice"

sleep 4
log_step "final states secure=$(getprop init.svc.vendor.secure_element) strongbox=$(getprop init.svc.vendor.keymint-strongbox) omapi=$(getprop init.svc.odm.se_omapi) mink=$(getprop init.svc.vendor.minkdaemon) qwes=$(getprop init.svc.vendor.qwesd) mlipay=$(getprop init.svc.vendor.mlipay) idm=$(getprop init.svc.vendor.idmanger) mtd=$(getprop init.svc.vendor.mtdservice)"
