# Boards

The goal of this document is to descibe how to make a Board Support Packge from a STM32CubeMX code generated and to be able to build it with a CMake files


## Difference between STM32CubeIDE & CMake

the generic project made by the STM32CubeMX for the STM32CubeIDE or for the CMake have some difference.

### 1. Project Metadata (IDE-only or CMake-only)

**IDE**: .cproject, .project, .osx.project, IDE.ioc,  

**CMake**: CMakeLists.txt, CMakePresets.json, CMake.ioc, cmake/.  

→ These are toolchain/IDE specific can be merge into same folders.

### 2. Linker Scripts

**IDE**: STM32F401RETX_FLASH.ld, STM32F401RETX_RAM.ld.  
**CMake**: STM32F401XX_FLASH.ld.  

→ Both are GCC linker scripts, just generated with different names by CubeMX.  

They are unified to keep a FLASH/RAM pair.
  
Both projects can reference the same .ld.  

### 3. Startup Files

**IDE**: Core/Startup/startup_stm32f401xe.s.  

**CMake**: startup_stm32f401xe.s at project root.

→ Same file, just placed differently. Can be moved into a common Startup/ folder.  

### 4. System Files

syscalls.c and sysmem.c differ.  

→ CubeIDE generates its own versions, CMake template may differ slightly.  

You should diff the contents: usually differences are trivial (heap/stack size symbols).  

Pick one canonical version and share it.  



### 5. Linker Differences

```bash
diff ./IDE/STM32F401RETX_FLASH.ld ./CMake/STM32F401XX_FLASH.ld
```

Functionally, these two linker scripts are the same. Differences are only in:
- The device name in comments (STM32F401RETx vs STM32F401xx).  
- Minor formatting / comment style.  

### 6. syscalls.c Differences

```bash
diff ./IDE/Core/Src/syscalls.c ./CMake/Core/Src/syscalls.c 
```

Functionally, both syscalls.c are identical. Only comments and copyright years differ.

### 6. sysmem.c Differences

```bash
diff ./IDE/Core/Src/sysmem.c ./CMake/Core/Src/sysmem.c 
```

Functionally, both sysmem.c files are the same. The only changes are in comments and metadata, not in code logic.


## Architecture

The merge result between this 2 projects is 

```
.
├── .cproject
├── .project,
├── CMakeLists.txt
├── CMakePresets.json
├── Core
│   ├── Inc
│   │   ├── gpio.h
│   │   ├── main.h
│   │   ├── stm32f4xx_hal_conf.h
│   │   ├── stm32f4xx_it.h
│   │   └── usart.h
│   ├── Src
│   │   ├── gpio.c
│   │   ├── main.c
│   │   ├── stm32f4xx_hal_msp.c
│   │   ├── stm32f4xx_it.c
│   │   ├── syscalls.c
│   │   ├── sysmem.c
│   │   ├── system_stm32f4xx.c
│   │   └── usart.c
│   └── Startup
│       └── startup_stm32f401retx.s
├── Drivers
│   ├── CMSIS
│   └── STM32F4xx_HAL_Driver
│       ├── LICENSE.txt
│       └── Src
├── README.md
├── STM32F401.ioc
├── STM32F401RETX_FLASH.ld
└── STM32F401RETX_RAM.ld
```

### Folder Roles

**Drivers**: CMSIS and HAL drivers (ST-provided, usually unmodified)   

**Core**: Application-specific code, peripheral initialization, and system files. 

**Startup**: Unified location for startup assembly files.  

**Linker Scripts**: Unified FLASH/RAM linker scripts.  

**Project Metadata**: IDE or CMake specific configuration files.  

**BSP Philosophy**: Common baseline for IDE and CMake, shared system files, and initialization code.

## CMake Modification 

The only modification is to fit the folder structure.

* Original cmake/gcc-arm-none-eabi.cmake

```
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -T \"${CMAKE_SOURCE_DIR}/STM32F401XX_FLASH.ld\"")
```

* Updated cmake/gcc-arm-none-eabi.cmake
```
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -T \"${CMAKE_SOURCE_DIR}/STM32F401RETX_FLASH.ld\"")
```

* Original cmake/stm32cubemx/CMakeLists.txt

```
${CMAKE_SOURCE_DIR}/startup_stm32f401xe.s
```

* Updated cmake/stm32cubemx/CMakeLists.txt

```
${CMAKE_SOURCE_DIR}/Core/Startup/startup_stm32f401retx.s
```

## Build A Board Pack 

Using the CMSIS-Tools, The next step is to create a **Board Support Package (BSP)** based on the merged project.    

A BSP provides a reusable, hardware-specific foundation that can be shared across multiple projects and toolchains.

---

MyBoard_BSP/
├── STM32F401.ioc  
├── STM32F401RETX_FLASH.ld
├── STM32F401RETX_RAM.ld      
├── Drivers/
│   ├── CMSIS/
│   └── STM32F4xx_HAL_Driver/
│       ├── LICENSE.txt
│       └── Src/
├── Core/
│   ├── Inc/
│   │   ├── gpio.h
│   │   ├── main.h
│   │   ├── stm32f4xx_hal_conf.h
│   │   ├── stm32f4xx_it.h
│   │   └── usart.h
│   └── Src/
│       ├── gpio.c
│       ├── main.c
│       ├── stm32f4xx_hal_msp.c
│       ├── stm32f4xx_it.c
│       ├── syscalls.c
│       ├── sysmem.c
│       ├── system_stm32f4xx.c
│       └── usart.c
├── Startup/
│   └── startup_stm32f401retx.s
├── CMakeLists.txt
├── CMakePresets.json
├── .cproject
├── .project
└── README.md