# setup the base image, in case you have your env created elsewhere
ARG BASE_IMAGE=debian:bookworm
FROM ${BASE_IMAGE}

# root section
# install packages
RUN apt-get update -y && apt-get upgrade -y

# install neovim
RUN apt-get install -y wget
RUN wget https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz -P /tmp/
RUN tar xzvf /tmp/nvim-linux-x86_64.tar.gz -C /tmp/
RUN rm /tmp/nvim-linux-x86_64.tar.gz
RUN cp -r /tmp/nvim-linux-x86_64/* /usr/local/

# install all dependencies for neovim
RUN apt-get install -y git
RUN apt-get install -y build-essential
RUN apt-get install -y unzip
RUN apt-get install -y python3
RUN apt-get install -y python3-venv
RUN apt-get install -y curl
RUN apt-get install -y ghostscript
RUN apt-get install -y ripgrep
RUN apt-get install -y fd-find
RUN apt-get install -y luarocks
RUN apt-get install -y openocd


# user section
# Set build arguments for UID and GID
ARG USER_UID=1000
ARG USER_GID=1000

# Handle group creation
RUN if getent group $USER_GID; then \
        echo "Group with GID $USER_GID already exists"; \
    else \
        groupadd --gid $USER_GID dev; \
    fi

# Handle user creation
RUN if getent passwd $USER_UID; then \
        echo "User with UID $USER_UID already exists, deleting..."; \
        userdel -r $(getent passwd $USER_UID | cut -d: -f1) || true; \
    fi && \
    useradd --uid $USER_UID --gid $USER_GID --create-home rafalj


ADD nvim-config/ /home/rafalj/.config/nvim
RUN chown rafalj /home/rafalj/.config

RUN usermod -aG plugdev rafalj

# Set working directory and switch to the new user
USER rafalj

RUN nvim --headless -c "Lazy! sync" -c qa
RUN nvim --headless -c "MasonToolsInstallSync" -c qa

RUN git config --global user.name "Rafal Jasinski"
RUN git config --global user.email rajs@softwaremind.com

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Create a script file sourced by both interactive and non-interactive bash shells
ENV BASH_ENV /home/rafalj/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > /home/rafalj/.nvmrc
RUN nvm install node
