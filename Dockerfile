FROM ubuntu:22.04


ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
ENV RUST_VERSION=1.75.0


# Install a basic environment needed for our build tools
RUN apt -yq update && \
    apt -yqq install --no-install-recommends curl ca-certificates \
        mc git tree sudo\
        libunwind8\
        build-essential pkg-config libssl-dev llvm-dev liblmdb-dev clang cmake rsync

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


# Create the Matiki user
RUN useradd -m Matiki

# Add Matiki to the sudo group
RUN usermod -aG sudo Matiki

# Allow Matiki to run sudo without a password
RUN echo 'Matiki ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the Matiki user
USER Matiki


# Set environment variables for Node.js and nvm
ENV HOME=/home/Matiki
ENV NVM_DIR=$HOME/.nvm
ENV NVM_VERSION=v0.39.1
ENV NODE_VERSION=18.1.0

# Install Node.js using nvm
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"
RUN sudo mkdir -p $NVM_DIR
RUN sudo chown -R Matiki:Matiki $NVM_DIR
RUN curl --fail -sSf https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install $NODE_VERSION
RUN . "$NVM_DIR/nvm.sh" && nvm use v$NODE_VERSION
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v$NODE_VERSION
# Install dfx
RUN sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

COPY --chown=Matiki:Matiki . /canister
WORKDIR /canister
RUN sudo chown -R Matiki:Matiki /canister
RUN chmod -R 755 /canister

RUN sudo chown -R Matiki:Matiki /opt/cargo


# Copy the entrypoint script into the Docker image
COPY entrypoint.sh /canister

# Use the entrypoint script as the entrypoint
ENTRYPOINT ["/canister/entrypoint.sh"]
# SHELL ["/bin/bash", "-c"]
