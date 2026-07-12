Placeholder prebuilts copied from the generic scaffold were removed on purpose.

Before building a real recovery image, replace these with device-accurate
artifacts for the Xiaomi sm8750_thales family:

- Image
- dtb.img
- dlkm/msm_drm.ko

Recommended local sources:

- C:\tmp\DSURecoverySystem\_tmp_build\popsicle_stock_boot_original.img
- any imported vendor_boot extraction for the currently booting TWRP base
