https://zmk.dev/docs/development/local-toolchain/setup/container

```bash
docker volume create --driver local -o o=bind -o type=none -o device="$(pwd)" zmk-config
docker volume inspect zmk-config
```

dont need to create a zmk-module volume.
When you DON'T need zmk-modules:
- Building a standard zmk-config (your case)
- Using built-in ZMK shields and boards
- Custom keymaps in your config directory
- Your config has a module.yml (which yours does)

```bash
# start the devcontainer
devcontainer up --workspace-folder "$(cd ../zmk && pwd)"
# connect to the devcontainer
docker exec -w /workspaces/zmk -it \
  $(docker ps --format "{{.ID}}\t{{.Image}}" | grep zmk | awk '{print $1}') \
  /bin/bash
```

```bash
west init -l app/ # Initialization (takes a very long time)
west update       # Update modules
```

https://zmk.dev/docs/development/local-toolchain/build-flash#building-from-zmk-config-folder

```bash
# Settings reset
west build -s app -d build/settings_reset -b nice_nano_v2 -- \
  -DSHIELD="settings_reset" \
  -DZMK_CONFIG=/workspaces/zmk-config/config

# zmk/build/reset/zephyr/zmk.uf2

# Left half
west build -s app -d build/left -b nice_nano_v2 -S studio-rpc-usb-uart -- \
  -DSHIELD="corne_left nice_view_adapter nice_view" \
  -DZMK_CONFIG=/workspaces/zmk-config/config \
  -DZMK_EXTRA_MODULES=/workspaces/zmk-config

# zmk/build/left/zephyr/zmk.uf2

# Right half
west build -s app -d build/right -b nice_nano_v2 -- \
  -DSHIELD="corne_right nice_view_adapter nice_view" \
  -DZMK_CONFIG=/workspaces/zmk-config/config \
  -DZMK_EXTRA_MODULES=/workspaces/zmk-config

# zmk/build/right/zephyr/zmk.uf2
```
