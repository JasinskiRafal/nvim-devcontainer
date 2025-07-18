# nvim-devcontainer
This repository contains a base setup for developing with neovim inside a devcontainer

> **NOTE**: All mentioned variables can be accessed with anchors

## Develop with base image
Service for developing with base image
``` yaml
  base-image:
    image: base-image:latest
    build:
      context: ./project
```
Add this to devcontainer service
``` yaml
  devcontainer:
    build:
      args:
        - BASE_IMAGE=base-image:latest
```

## Add usb to devcontainer
Add this to services that should have usb shared
``` yaml
  devcontainer:
    devices:
      - "/dev/bus/usb:/dev/bus/usb"
```

## Map project directory to workspace
Add these if you want to work on a specific project
``` yaml
  devcontainer:
    volumes:
      - ./project:/workspace
    working_dir:
      /workspace
```

``` yaml
  devcontainer:
    devices: &_devices
      - "/dev/bus/usb:/dev/bus/usb"

  service:
    devices: *_devices
```

## Debug with gdb-multiarch tui
Here are two example services to run the debug process
Debug server service:
``` yaml
  debug-server:
    image: *_image
    hostname: debug-server
    volumes: *_volumes
    working_dir: *_working_dir
    devices: *_devices
    environment: *_environment
    expose:
      - 61234
    command: /path/to/stm32toolchain/STLink-gdb-server/bin/ST-LINK_gdbserver -p 61234 -l 1 -d -s -cp /path/to/stm32toolchain/STM32CubeProgrammer/bin/ -m 1 -k
```

Debug client service:
target extended-remote should target the same hostname as the debug-server
``` yaml
  debug:
    image: *_image
    volumes: *_volumes
    working_dir: *_working_dir
    devices: *_devices
    environment: *_environment
    depends_on:
      - debug-server
    ports:
      - 61234:61234
    command: gdb-multiarch --ex "target extended-remote debug-server:61234" --command /workspace/debug-session /path/to/project/build/executable.elf
    stdin_open: true
    tty: true
```

> **NOTE**: Expose and pass the ports used by the gdb-server
