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

## .nvim.lua
Every project can have their own ``.nvim.lua`` file used to define LSP server configuration, debug configuration and usercommands usable by the project

**LSP**:
Enable an LSP configuration
``` lua
  vim.lsp.enable("clangd")
```

Configure an LSP configuration
``` lua
  vim.lsp.config(
    "clangd",
    {
      cmd = "clangd",
      args = {"-query-driver=arm-none-eabi-gcc"},
  })
```

**Debug**:
There is a plugin present mason-nvim-dap that provied default configurations per file extension.
In case a specific configuration is needed please follow:

``` lua
  local dap = require("dap")
  local dap_cortex_debug = require("dap-cortex-debug")

  -- configure debugging your executable
  config = {
          cwd = vim.fn.getcwd(),
          executable = vim.fn.getcwd() .. "/Makefile/FSBL/build/make-ai-example_FSBL.elf",
          gdbPath = "gdb-multiarch",
          gdbTarget = "localhost:50000",
          name = "Example debugging with STLinkGDBServer",
          request = "launch",
          rttConfig = false,
          runToEntryPoint = "main",
          serverpath = "/opt/st/stm32cubeclt_1.18.0/STLink-gdb-server/bin/ST-LINK_gdbserver",
          stlinkPath = "/opt/st/stm32cubeclt_1.18.0/STLink-gdb-server/bin/ST-LINK_gdbserver",
          stm32cubeprogrammer = "/opt/st/stm32cubeclt_1.18.0/STM32CubeProgrammer/",
          servertype = "stlink",
          showDevDebugOutput = true,
          swoConfig = {
                  enabled = false,
          },
          extensionPath = "/usr/bin",
          toolchainPrefix = "arm-none-eabi",
          type = "cortex_debug",
  }
  
  -- define an adapter, usually not needed
  adapter = {
          type = "executable",
          command = "node",
          args = { "/home/rafalj/.local/share/nvim/mason/packages/cortex-debug/extension/dist/debugadapter.js" },
  }

  dap.configurations.c = { config }
  dap.adapters.cortex_debug = adapter
```

> **NOTE**: In order to debug the configuration easily, please remember to use ``vim.print()``

**User commands**
There is a possiblity to add user commands to the directory using following syntax:
``` lua
  -- Create build folder and configure CMake
  vim.api.nvim_create_user_command('CMakeConfigure', function()
      vim.fn.system('mkdir -p build && cd build && cmake ..')
  end, {})

  -- Remove build folder
  vim.api.nvim_create_user_command('CMakeClean', function()
      vim.fn.system('rm -rf build')
  end, {})

  -- Run CMake build
  vim.api.nvim_create_user_command('CMakeBuild', function()
      vim.fn.system('cmake --build ./build -j')
  end, {})
```
