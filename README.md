# TWRP Device Tree for Xiaomi 17 (Pudding)

Device tree for building Team Win Recovery Project (TWRP) for the Xiaomi 17 (Pudding).

**Maintainer:** antocorvo3000

## Device Information

| Property     | Value           |
| ------------ | --------------- |
| Device       | Xiaomi 17       |
| Codename     | Pudding         |
| Manufacturer | Xiaomi          |
| Platform     | Qualcomm Snapdragon (sm8750_thales family) |
| Architecture | arm64           |

## Status

### Working

* Boots successfully
* Touchscreen
* Data decryption — stable
* ADB / Fastbootd

## Notes

The decrypt path in `system/vold/Decrypt.cpp` includes a fix for an AES-256-GCM
authentication-tag handling bug in the synthetic-password unwrap path
(`Decrypt_User_Synth_Pass`): the original code split ciphertext/tag incorrectly,
used an uninitialized tag buffer, and never checked the OpenSSL EVP return
codes. See `patches/0001-vold-fix-synthetic-password-gcm.patch`.

## Building

The recovery is built from source with the TWRP-Test `twrp-16.0` manifest; only the
device-specific files in `recovery/root` come from the released v32 image
(`twrp-3.7.1_16-pudding-antocorvo3000-v32-erofsfstab-stockavb.img`). The result is a
header v4, ramdisk-only `recovery.img` of 100 MiB for the `recovery_a`/`recovery_b`
partitions; the kernel comes from `boot`.

```bash
repo init -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0 --depth=1
# local manifests: pinned projects and this tree, see
# https://github.com/xiaomi17-pudding-dev/local_manifests_pudding (twrp/)
repo sync -c --no-tags -j$(nproc)
# synthetic password decryption fix (see Notes)
patch -p1 -d system/vold < device/xiaomi/sm8750_thales/patches/0001-vold-fix-synthetic-password-gcm.patch
export ALLOW_MISSING_DEPENDENCIES=true
source build/envsetup.sh
lunch twrp_sm8750_thales-bp2a-eng
m recoveryimage
# out/target/product/sm8750_thales/recovery.img
```

The UI starts below the status bar area of the stock overlay (`TW_Y_OFFSET`/`TW_H_OFFSET`),
so the camera cutout and the rounded corners cover no text or buttons.

## Credits

* Team Win Recovery Project (TWRP)
* Android Open Source Project (AOSP)
* The Android aftermarket development community
