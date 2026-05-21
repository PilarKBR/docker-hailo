FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 AS base_cuda

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Step 1: install Python 3.10 and set it as default python3 BEFORE installing pip
RUN apt-get update && \
    apt-get install -y python3.10 python3.10-dev python3.10-distutils && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 10 && \
    update-alternatives --set python3 /usr/bin/python3.10

# Step 2: now install pip (will use the default python3 = 3.10)
RUN apt-get install -y \
      python3-pip \
      python3.10-venv \
      python3-tk \
      graphviz \
      libgraphviz-dev \
      libgl1-mesa-glx \
      python-is-python3 \
      build-essential \
      sudo \
      curl \
      git \
      nano && \
    rm -rf /var/lib/apt/lists/*

# Verify python3 is now 3.10
RUN python3 --version

RUN python3 -m pip install --upgrade pip setuptools wheel

WORKDIR /workspace

ARG user=hailo
ARG group=hailo
ARG uid=1000
ARG gid=1000

RUN groupadd --gid $gid $group && \
    adduser --uid $uid --gid $gid --shell /bin/bash --disabled-password --gecos "" $user && \
    chmod u+w /etc/sudoers && echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && chmod -w /etc/sudoers && \
    chown -R $user:$group /workspace

# Install Hailo wheels
COPY hailort-4.23.0-cp310-cp310-linux_x86_64.whl /tmp/hailort.whl
RUN python3 -m pip install /tmp/hailort.whl && rm /tmp/hailort.whl

COPY hailo_dataflow_compiler-3.33.1-py3-none-linux_x86_64.whl /tmp/hailo_dfc.whl
RUN python3 -m pip install /tmp/hailo_dfc.whl && rm /tmp/hailo_dfc.whl
