FROM ubuntu:22.04

ENV NVM_DIR=/root/.nvm
ENV NVM_VERSION=v0.39.1
ENV NODE_VERSION=18.1.0

ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
ENV RUST_VERSION=1.75.0


# Install a basic environment needed for our build tools
RUN apt -yq update && \
    apt -yqq install --no-install-recommends curl ca-certificates \
        mc git tree\
        build-essential pkg-config libssl-dev llvm-dev liblmdb-dev clang cmake rsync

# Install Node.js using nvm
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"
RUN curl --fail -sSf https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh | bash
RUN . "${NVM_DIR}/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "${NVM_DIR}/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "${NVM_DIR}/nvm.sh" && nvm alias default v${NODE_VERSION}

# Install Rust and Cargo
ENV PATH=/opt/cargo/bin:${PATH}
RUN curl --fail https://sh.rustup.rs -sSf \
        | sh -s -- -y --default-toolchain ${RUST_VERSION}-x86_64-unknown-linux-gnu --no-modify-path && \
    rustup default ${RUST_VERSION}-x86_64-unknown-linux-gnu && \
    rustup target add wasm32-unknown-unknown &&\
    cargo install ic-wasm

ENV DFX_VERSION=0.19.0

# Install dfx
# Replace the problematic line with these lines
# RUN curl -LO https://github.com/dfinity/sdk/releases/download/$DFX_VERSION/dfx-$DFX_VERSION-x86_64-linux.tar.gz
# RUN tar -xvzf dfx-$DFX_VERSION-x86_64-linux.tar.gz -C /usr/local/bin/


# # Copy the script into the image
# COPY install.sh /install.sh
# # Make the script executable
# RUN chmod +x /install.sh
# # Run the script
# RUN /install.sh

ENV DFXVM_INIT_YES=true

# Add this line before you run the install.sh script
RUN apt-get update && apt-get install -y libunwind8

RUN sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

COPY . /canister
WORKDIR /canister


RUN useradd -m MAtiki
USER Matiki
RUN dfx start --background --clean --host 0.0.0.0:4943


# SHELL ["/bin/bash", "-c"]
