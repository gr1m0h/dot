# Multi-stage Dockerfile for testing dotfiles installation
# Stage 1: Ubuntu-based testing (closer to GitHub Actions environment)
FROM ubuntu:22.04 as ubuntu-test

# Install essential packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    sudo \
    zsh \
    build-essential \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8

# Create a non-root user (similar to a fresh macOS user)
RUN useradd -m -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Copy install script
COPY --chown=testuser:testuser install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh

# Set environment variables
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Stage 2: Alpine-based lightweight testing
FROM alpine:latest as alpine-test

# Install essential packages
RUN apk add --no-cache \
    curl \
    git \
    sudo \
    zsh \
    build-base \
    bash

# Create a non-root user
RUN adduser -D -s /bin/zsh testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user  
USER testuser
WORKDIR /home/testuser

# Copy install script
COPY --chown=testuser:testuser install.sh /tmp/install.sh
RUN chmod +x /tmp/install.sh