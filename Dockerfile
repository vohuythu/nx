FROM ubuntu:latest

# Cập nhật hệ thống và cài đặt các gói cần thiết
RUN apt update && apt install -y build-essential pkg-config libssl-dev git-all \
    autoconf automake libtool curl make g++ unzip expect

# Cài đặt Protobuf
RUN git clone --depth=1 --branch=v21.12 https://github.com/protocolbuffers/protobuf.git && \
    cd protobuf && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd .. && rm -rf protobuf

# Cài đặt Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    source $HOME/.cargo/env && \
    rustup target add riscv32i-unknown-none-elf

# Cài đặt Nexus CLI (Tự động nhập "Y" và Node ID)
RUN curl https://cli.nexus.xyz/ | sh && \
    expect -c '
    spawn ~/.nexus/nexus-cli
    expect "Do you want to proceed? (y/N)"
    send "y\r"
    expect "Select an option:"
    send "2\r"
    expect "Enter Node ID:"
    send "5595553\r"
    interact
    '

# Chạy Nexus Node
CMD ["~/.nexus/network-api/clients/cli/target/release/nexus-network"]
