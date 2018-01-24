
# lloyd konneker
# Derived from Polidea's github repository cmake-nRF5x

# Changed: 
#  include a cmake script to patch for v14.2
#  modified some macros
#  update SD version numbers

# If you modify the targets created, you may need to regenerate the project
# i.e. "cmake -G "Eclipse CDT4 - Ninja  etc." or similar




cmake_minimum_required(VERSION 3.5.1)

# check if all the necessary toolchain SDK and tools paths have been provided.
if (NOT ARM_NONE_EABI_TOOLCHAIN_PATH)
    message(FATAL_ERROR "The path to the arm-none-eabi-gcc toolchain (ARM_NONE_EABI_TOOLCHAIN_PATH) must be set.")
endif ()

if (NOT NRF5_SDK_PATH)
    message(FATAL_ERROR "The path to the nRF5 SDK (NRF5_SDK_PATH) must be set.")
endif ()

if (NOT NRFJPROG)
    message(FATAL_ERROR "The path to the nrfjprog utility (NRFJPROG) must be set.")
endif ()

# check if the nRF target has been set
if (NRF_TARGET MATCHES "nrf51")

elseif (NRF_TARGET MATCHES "nrf52")

elseif (NOT NRF_TARGET)
    message(FATAL_ERROR "nRF target must be defined")
else ()
    message(FATAL_ERROR "Only nRF51 and rRF52 boards are supported right now")
endif ()



# TODO hardcoded for SD version (5) in two places


# Softdevice handler
# Required if SD compatible drivers used
macro(nRF5x_defineSDKSourcesSDH)
        list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/softdevice/common/nrf_sdh.c"
            )
endmacro()



# utils
# required for SD and SD compatible drivers
macro(nRF5x_defineSDKSourcesUtils)

    # "${NRF5_SDK_PATH}/components/libraries/util/sdk_errors.c"
    
    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/hardfault/hardfault_implementation.c"
            "${NRF5_SDK_PATH}/components/libraries/util/nrf_assert.c"
            "${NRF5_SDK_PATH}/components/libraries/util/app_error.c"
            "${NRF5_SDK_PATH}/components/libraries/util/app_error_weak.c"
            "${NRF5_SDK_PATH}/components/libraries/util/app_util_platform.c"
            "${NRF5_SDK_PATH}/components/libraries/util/app_util_platform.c"
            "${NRF5_SDK_PATH}/components/libraries/util/sdk_mapped_flags.c"
            )    
endmacro()



# API to BLE functions of SD
macro(nRF5x_defineSDKSourcesBLE)
     # Optional for capability: negotiate connection params
     # sdk_config.h>NRF_BLE_CONN_PARAMS_ENABLED
     # "${NRF5_SDK_PATH}/components/ble/common/ble_conn_params.c"

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/ble/common/ble_advdata.c"
            "${NRF5_SDK_PATH}/components/ble/common/ble_conn_state.c"
            "${NRF5_SDK_PATH}/components/ble/common/ble_srv_common.c"
            )   
endmacro()


# board support
# apparently conditionally compiled so no change to text size if no board is defined
macro(nRF5x_defineSDKSourcesBSP)
    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/boards/boards.c"
            )
endmacro()

# SD compatbile drivers
# common is required by all drivers
macro(nRF5x_defineSDKSourcesDrivers)
    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/drivers_nrf/common/nrf_drv_common.c"
            # "${NRF5_SDK_PATH}/components/drivers_nrf/clock/nrf_drv_clock.c"
            #"${NRF5_SDK_PATH}/components/drivers_nrf/uart/nrf_drv_uart.c"
            #"${NRF5_SDK_PATH}/components/drivers_nrf/rtc/nrf_drv_rtc.c"
            #"${NRF5_SDK_PATH}/components/drivers_nrf/gpiote/nrf_drv_gpiote.c"
            )
endmacro()



# Basic i.e. required for most builds
# e.g. when Softdevice and SD compatible drivers used
macro(nRF5x_defineSDKSourcesAll)
    nRF5x_defineSDKSourcesSDH()
    nRF5x_defineSDKSourcesDrivers()
    nRF5x_defineSDKSourcesUtils()
endmacro()



macro(nRF5x_setup)
    # fix on macOS: prevent cmake from adding implicit parameters to Xcode
    set(CMAKE_OSX_SYSROOT "/")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "")

    # language standard/version settings
    set(CMAKE_C_STANDARD 99)
    # 98, 11, or 14
    set(CMAKE_CXX_STANDARD 14)

    # configure cmake to use the arm-none-eabi-gcc
    set(CMAKE_C_COMPILER "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc")
    set(CMAKE_CXX_COMPILER "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-c++")
    set(CMAKE_ASM_COMPILER "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc")

    include_directories(
            "${NRF5_SDK_PATH}/components/softdevice/common"
    )
    

    # CPU specyfic settings
    if (NRF_TARGET MATCHES "nrf51")
        # nRF51 (nRF51-DK => PCA10028)

        set(NRF5_LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/gcc_nrf51.ld")
        set(CPU_FLAGS "-mcpu=cortex-m0 -mfloat-abi=soft")
        add_definitions(-DBOARD_PCA10028 -DNRF51 -DNRF51422)
        add_definitions(-DSOFTDEVICE_PRESENT -DS130 -DNRF_SD_BLE_API_VERSION=2 -DSWI_DISABLE0 -DBLE_STACK_SUPPORT_REQD)
        include_directories(
                "${NRF5_SDK_PATH}/components/softdevice/s130/headers"
                "${NRF5_SDK_PATH}/components/softdevice/s130/headers/nrf51"
        )
        list(APPEND SDK_SOURCE_FILES
                "${NRF5_SDK_PATH}/components/toolchain/system_nrf51.c"
                "${NRF5_SDK_PATH}/components/toolchain/gcc/gcc_startup_nrf51.S"
                )
        set(SOFTDEVICE_PATH "${NRF5_SDK_PATH}/components/softdevice/s130/hex/s130_nrf51_2.0.1_softdevice.hex")
    elseif (NRF_TARGET MATCHES "nrf52")
        # nRF52 (nRF52-DK => PCA10040)

        set(NRF5_LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/gcc_nrf52.ld")
        set(CPU_FLAGS "-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")
        add_definitions(-DNRF52 -DNRF52832 -DNRF52_PAN_64 -DNRF52_PAN_12 -DNRF52_PAN_58 -DNRF52_PAN_54 -DNRF52_PAN_31 -DNRF52_PAN_51 -DNRF52_PAN_36 -DNRF52_PAN_15 -DNRF52_PAN_20 -DNRF52_PAN_55 -DBOARD_PCA10040)
        add_definitions(-DSOFTDEVICE_PRESENT -DS132 -DBLE_STACK_SUPPORT_REQD -DNRF_SD_BLE_API_VERSION=5)
        include_directories(
                "${NRF5_SDK_PATH}/components/softdevice/s132/headers"
                "${NRF5_SDK_PATH}/components/softdevice/s132/headers/nrf52"
        )
        list(APPEND SDK_SOURCE_FILES
                "${NRF5_SDK_PATH}/components/toolchain/system_nrf52.c"
                "${NRF5_SDK_PATH}/components/toolchain/gcc/gcc_startup_nrf52.S"
                )
        set(SOFTDEVICE_PATH "${NRF5_SDK_PATH}/components/softdevice/s132/hex/s132_nrf52_5.0.0_softdevice.hex")
    endif ()

    set(COMMON_FLAGS "-MP -MD -mthumb -mabi=aapcs -Wall -Werror -O3 -g3 -ffunction-sections -fdata-sections -fno-strict-aliasing -fno-builtin --short-enums ${CPU_FLAGS}")

    # compiler/assambler/linker flags
    set(CMAKE_C_FLAGS "${COMMON_FLAGS}")
    set(CMAKE_CXX_FLAGS "${COMMON_FLAGS}")
    set(CMAKE_ASM_FLAGS "-MP -MD -std=c99 -x assembler-with-cpp")
    set(CMAKE_EXE_LINKER_FLAGS "-mthumb -mabi=aapcs -std=gnu++98 -std=c99 -L ${NRF5_SDK_PATH}/components/toolchain/gcc -T${NRF5_LINKER_SCRIPT} ${CPU_FLAGS} -Wl,--gc-sections --specs=nano.specs -lc -lnosys -lm")
    # note: we must override the default cmake linker flags so that CMAKE_C_FLAGS are not added implicitly
    # lkk: added LINK_LIBRARIES
    set(CMAKE_C_LINK_EXECUTABLE "${CMAKE_C_COMPILER} <LINK_FLAGS> <OBJECTS> -o <TARGET>")
    set(CMAKE_CXX_LINK_EXECUTABLE "${CMAKE_C_COMPILER} <LINK_FLAGS> <OBJECTS> -lstdc++ -o <TARGET> <LINK_LIBRARIES>")

    include_directories(".")
    
    # SDK version specific headers and sources
    include("CMake_nRF5x_v14_2")

    # basic board definitions and drivers
    include_directories(
            "${NRF5_SDK_PATH}/components/boards"
            "${NRF5_SDK_PATH}/components/device"
            "${NRF5_SDK_PATH}/components/libraries/util"
            "${NRF5_SDK_PATH}/components/drivers_nrf/hal"
            "${NRF5_SDK_PATH}/components/drivers_nrf/common"
            "${NRF5_SDK_PATH}/components/drivers_nrf/delay"
            "${NRF5_SDK_PATH}/components/drivers_nrf/uart"
            "${NRF5_SDK_PATH}/components/drivers_nrf/clock"
            "${NRF5_SDK_PATH}/components/drivers_nrf/rtc"
            "${NRF5_SDK_PATH}/components/drivers_nrf/gpiote"
    )

    # toolchain specyfic
    include_directories(
            "${NRF5_SDK_PATH}/components/toolchain/"
            "${NRF5_SDK_PATH}/components/toolchain/gcc"
            "${NRF5_SDK_PATH}/components/toolchain/cmsis/include"
    )

    # log
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/log"
            "${NRF5_SDK_PATH}/components/libraries/log/src"
            "${NRF5_SDK_PATH}/components/libraries/timer"
    )

    # Segger RTT
    include_directories(
            "${NRF5_SDK_PATH}/external/segger_rtt/"
    )

    
    # Common Bluetooth Low Energy files
    include_directories(
            "${NRF5_SDK_PATH}/components/ble"
            "${NRF5_SDK_PATH}/components/ble/common"
    )


    nRF5x_defineSDKSourcesAll()

    # adds target for erasing and flashing the board with a softdevice
    add_custom_target(FLASH_SOFTDEVICE ALL
            COMMAND ${NRFJPROG} --program ${SOFTDEVICE_PATH} -f ${NRF_TARGET} --sectorerase
            COMMAND sleep 0.5s
            COMMAND ${NRFJPROG} --reset -f ${NRF_TARGET}
            COMMENT "flashing SoftDevice"
            )

    add_custom_target(FLASH_ERASE ALL
            COMMAND ${NRFJPROG} --eraseall -f ${NRF_TARGET}
            COMMENT "erasing flashing"
            )
endmacro(nRF5x_setup)



# adds a target for comiling and flashing an executable
macro(nRF5x_addExecutable EXECUTABLE_NAME SOURCE_FILES)
    # executable
    add_executable(${EXECUTABLE_NAME} ${SDK_SOURCE_FILES} ${SOURCE_FILES})
    nRF5x_modifyExeTarget(${EXECUTABLE_NAME})
endmacro()  


macro(nRF5x_modifyExeTarget EXECUTABLE_NAME)
    set_target_properties(${EXECUTABLE_NAME} PROPERTIES SUFFIX ".out")
    set_target_properties(${EXECUTABLE_NAME} PROPERTIES LINK_FLAGS "-Wl,-Map=${EXECUTABLE_NAME}.map")

    # additional POST BUILD setps to create the .bin and .hex files
    add_custom_command(TARGET ${EXECUTABLE_NAME}
            POST_BUILD
            COMMAND ${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-size ${EXECUTABLE_NAME}.out
            COMMAND ${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-objcopy -O binary ${EXECUTABLE_NAME}.out "${EXECUTABLE_NAME}.bin"
            COMMAND ${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-objcopy -O ihex ${EXECUTABLE_NAME}.out "${EXECUTABLE_NAME}.hex"
            COMMENT "post build steps for ${EXECUTABLE_NAME}")

    # custom target for flashing the board
    add_custom_target("FLASH_${EXECUTABLE_NAME}" ALL
            COMMAND ${NRFJPROG} --program ${EXECUTABLE_NAME}.hex -f ${NRF_TARGET} --sectorerase
            COMMAND sleep 0.5s
            COMMAND ${NRFJPROG} --reset -f ${NRF_TARGET}
            DEPENDS ${EXECUTABLE_NAME}
            COMMENT "flashing ${EXECUTABLE_NAME}.hex"
            )
endmacro()



# Macros for sets of sources by capability
# E.g. RTT is optional

# adds NRF_LOG
# sdk_config.h>NRF_LOG_ENABLED

macro(nRF5x_addNRF_LOG)
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/log/src/"
    )
    
    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_backend_serial.c"
            "${NRF5_SDK_PATH}/components/libraries/log/src/nrf_log_frontend.c"
            )

endmacro(nRF5x_addNRF_LOG)


# adds Segger RTT
# sdk_config.h>NRF_LOG_BACKEND_RTT_ENABLED
macro(nRF5x_addRTT)
    include_directories(
            "${NRF5_SDK_PATH}/external/segger_rtt"
    )
    
    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/external/segger_rtt/RTT_Syscalls_GCC.c"
            "${NRF5_SDK_PATH}/external/segger_rtt/SEGGER_RTT.c"
            "${NRF5_SDK_PATH}/external/segger_rtt/SEGGER_RTT_printf.c"
            )

endmacro(nRF5x_addRTT)


# adds app-level scheduler library
macro(nRF5x_addAppScheduler)
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/scheduler"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/scheduler/app_scheduler.c"
            "${NRF5_SDK_PATH}/components/softdevice/common/softdevice_handler/softdevice_handler_appsh.c"
            )

endmacro(nRF5x_addAppScheduler)

# adds app-level FIFO libraries
macro(nRF5x_addAppFIFO)
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/fifo"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/fifo/app_fifo.c"
            )

endmacro(nRF5x_addAppFIFO)

# adds app-level Timer libraries
macro(nRF5x_addAppTimer)
    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/timer/app_timer.c"
            )
endmacro(nRF5x_addAppTimer)

# adds app-level UART libraries
macro(nRF5x_addAppUART)
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/uart"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/uart/app_uart_fifo.c"
            )

endmacro(nRF5x_addAppUART)

# adds app-level Button library
macro(nRF5x_addAppButton)
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/button"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/button/app_button.c"
            )

endmacro(nRF5x_addAppButton)

# adds BSP (board support package) library
macro(nRF5x_addBSP WITH_BLE_BTN WITH_ANT_BTN WITH_NFC)
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/bsp"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/bsp/bsp.c"
            )

    if (${WITH_BLE_BTN})
        list(APPEND SDK_SOURCE_FILES
                "${NRF5_SDK_PATH}/components/libraries/bsp/bsp_btn_ble.c"
                )
    endif ()

    if (${WITH_ANT_BTN})
        list(APPEND SDK_SOURCE_FILES
                "${NRF5_SDK_PATH}/components/libraries/bsp/bsp_btn_ant.c"
                )
    endif ()

    if (${WITH_NFC})
        list(APPEND SDK_SOURCE_FILES
                "${NRF5_SDK_PATH}/components/libraries/bsp/bsp_nfc.c"
                )
    endif ()

endmacro(nRF5x_addBSP)

# adds Bluetooth Low Energy GATT support library
macro(nRF5x_addBLEGATT)
    include_directories(
            "${NRF5_SDK_PATH}/components/ble/nrf_ble_gatt"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/ble/nrf_ble_gatt/nrf_ble_gatt.c"
            )

endmacro(nRF5x_addBLEGATT)

# adds Bluetooth Low Energy advertising support library
macro(nRF5x_addBLEAdvertising)
    include_directories(
            "${NRF5_SDK_PATH}/components/ble/ble_advertising"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/ble/ble_advertising/ble_advertising.c"
            )

endmacro(nRF5x_addBLEAdvertising)

# adds Bluetooth Low Energy advertising support library
macro(nRF5x_addBLEPeerManager)
    include_directories(
            "${NRF5_SDK_PATH}/components/ble/peer_manager"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/ble/peer_manager/gatt_cache_manager.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/gatts_cache_manager.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/id_manager.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_data.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_data_storage.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_database.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_id.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/peer_manager.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/pm_buffer.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/pm_mutex.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/security_dispatcher.c"
            "${NRF5_SDK_PATH}/components/ble/peer_manager/security_manager.c"
            )

endmacro(nRF5x_addBLEPeerManager)

# adds app-level FDS (flash data storage) library
macro(nRF5x_addAppFDS)
    include_directories(
            "${NRF5_SDK_PATH}/components/libraries/fds"
            "${NRF5_SDK_PATH}/components/libraries/fstorage"
            "${NRF5_SDK_PATH}/components/libraries/experimental_section_vars"
    )

    list(APPEND SDK_SOURCE_FILES
            "${NRF5_SDK_PATH}/components/libraries/fds/fds.c"
            "${NRF5_SDK_PATH}/components/libraries/fstorage/fstorage.c"
            )

endmacro(nRF5x_addAppFDS)
