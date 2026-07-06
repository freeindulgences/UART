#!/bin/bash

set -e
# set -x

# param - project directory
function compile {

    project=$1

    gcc_options=(-DSTM32F10X_MD -DUSE_FULL_ASSERT -DUSE_STDPERIPH_DRIVER -DHSE_VALUE="8000000" -I"${project}/src" -I"${project}/src/cmsis" -I"${project}/src/mcu_support_package/inc" -I"${project}/src/spl" -I"${project}/src/spl/inc" -std=c99 -O0 -g3 -Wall -c -fmessage-length=0 -mcpu=cortex-m3 -mthumb -fdata-sections -ffunction-sections -fdiagnostics-color   -Werror -Wall -Wpedantic -Wextra  -Wcast-align -Wcast-qual  -Wvla -Wshadow -Wsuggest-attribute=const -Wmissing-format-attribute -Wuninitialized -Winit-self  -Wdouble-promotion -Wno-unused-local-typedefs)

    asm_options=(-mcpu=cortex-m3 -mthumb -D__STARTUP_CLEAR_BSS -c)

    linker_options=(-fdiagnostics-color -lm -mcpu=cortex-m3 -mthumb --specs=nosys.specs --specs=nano.specs -Wl,--gc-sections -T "${project}/src/mcu_support_package/gcc/linker/STM32F10x.ld" -ffreestanding -Wl,--print-memory-usage)
    
    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/main/main.c
    
    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/spl/src/stm32f10x_adc.c    
    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/spl/src/stm32f10x_dma.c    
    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/spl/src/stm32f10x_gpio.c
    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/spl/src/stm32f10x_rcc.c
    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/spl/src/stm32f10x_tim.c
    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/spl/src/stm32f10x_usart.c

    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-gcc  ${gcc_options[@]} ${project}/src/mcu_support_package/system_stm32f10x.c

    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-g++  ${asm_options[@]} ${project}/src/mcu_support_package/gcc/startup_stm32f103xb.S

    ~/opt/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-g++ ${linker_options[@]} main.o stm32f10x_rcc.o stm32f10x_adc.o stm32f10x_dma.o stm32f10x_gpio.o stm32f10x_tim.o stm32f10x_usart.o system_stm32f10x.o startup_stm32f103xb.o

    rm -rf ./*.o ./*.out
    
}

# tell PVS Studio that this is an academic project to check it for free
how-to-use-pvs-studio-free -c 1 ./part_1 ./part_2  ./part_3


echo 
echo "Compiling part 1"
echo 
compile ${PWD}/part_1 
echo

echo "----------------------"
echo

echo "Compiling part 2"
echo
compile ${PWD}/part_2 
echo

echo "----------------------"
echo

echo "Compiling part 3"
echo
compile ${PWD}/part_3 
echo
