FROM ubuntu:18.04
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y tzdata wget astyle gawk git gnupg cmake build-essential

# that's for arm-none-eabi compiler
RUN wget -q -O arm_gcc.tar.bz2 https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2?revision=d830f9dd-cd4f-406d-8672-cca9210dd220?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,8-2018-q4-major && mkdir ~/opt && tar xjf arm_gcc.tar.bz2 -C ~/opt/

# that's for PVS studio
RUN wget -q -O - https://files.viva64.com/etc/pubkey.txt | apt-key add - 
RUN wget -O /etc/apt/sources.list.d/viva64.list https://files.viva64.com/etc/viva64.list
RUN apt-get update -qq && apt-get install -qq pvs-studio
RUN git clone --branch 2.0 https://github.com/viva64/how-to-use-pvs-studio-free && \
    cd how-to-use-pvs-studio-free && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install