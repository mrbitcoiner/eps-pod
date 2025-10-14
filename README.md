# EPS Pod
---
## Electrum Personal Server inside a podman container
---
* Usage:
```bash
./control.sh help
```
* To create the wallet on bitcoin-cli
```
bitcoin-cli --named createwallet \
wallet_name=eps \
disable_private_keys=true \
blank=true \
passphrase="" \
avoid_reuse=false \
descriptors=false \
load_on_startup=true
```
