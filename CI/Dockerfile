FROM openjdk:11

WORKDIR /home/root

ENV ARM_TOOLCHAIN_VERSION=10.3-2021.10


# Install ultilities (unzip, python3, pip)
RUN apt-get update
RUN apt-get install unzip
RUN apt-get install python3 -y && apt-get install python3-pip -y 

# Install Git LFS for fully downloading GSDK
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get install git-lfs
RUN git-lfs install

# Download slc_cli tool
RUN wget https://www.silabs.com/documents/login/software/slc_cli_linux.zip

# Unpacking & installing slc_cli tools
RUN unzip slc_cli_linux
RUN rm -rf slc_cli_linux.zip
RUN pip install -r ./slc_cli/requirements.txt
RUN chmod a+x slc_cli/*

# Download GNU ARM Toolchain
RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/${ARM_TOOLCHAIN_VERSION}/gcc-arm-none-eabi-${ARM_TOOLCHAIN_VERSION}-x86_64-linux.tar.bz2

# Unpacking GNU ARM Toolchain
RUN mkdir ./gnu_arm
RUN tar xf gcc-arm-none-eabi-${ARM_TOOLCHAIN_VERSION}-x86_64-linux.tar.bz2 --strip-components=1 -C ./gnu_arm
RUN rm -rf gcc-arm-none-eabi-${ARM_TOOLCHAIN_VERSION}-x86_64-linux.tar.bz2
