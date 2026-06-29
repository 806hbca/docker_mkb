FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=noetic
ARG ROS_PACKAGE=ros-noetic-ros-base
ARG USER_NAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

ENV TZ=Europe/Moscow \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    ROS_DISTRO=${ROS_DISTRO} \
    ROS_PYTHON_VERSION=3 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        gnupg2 \
        iproute2 \
        lsb-release \
        nano \
        python3.8 \
        python3.8-dev \
        python3-pip \
        python3-venv \
        sudo \
        tzdata \
        vim \
        wget \
    && ln -sf /usr/bin/python3.8 /usr/local/bin/python \
    && ln -sf /usr/bin/python3.8 /usr/local/bin/python3 \
    && python3 -m pip install --no-cache-dir --upgrade \
        pip==24.2 \
        setuptools==70.3.0 \
        wheel==0.44.0 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
        | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros/ubuntu focal main" \
        > /etc/apt/sources.list.d/ros1.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ${ROS_PACKAGE} \
        gazebo11 \
        libgazebo11-dev \
        python3-catkin-tools \
        python3-rosdep \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-wstool \
        ros-noetic-cv-bridge \
        ros-noetic-gazebo-plugins \
        ros-noetic-gazebo-ros \
        ros-noetic-gazebo-ros-pkgs \
        ros-noetic-image-transport \
        ros-noetic-tf2-ros \
        ros-noetic-vision-msgs \
    && rosdep init \
    && rosdep update --rosdistro ${ROS_DISTRO} \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

RUN groupadd --gid ${USER_GID} ${USER_NAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} --create-home --shell /bin/bash ${USER_NAME} \
    && echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER_NAME} \
    && chmod 0440 /etc/sudoers.d/${USER_NAME} \
    && mkdir -p /workspace \
    && chown -R ${USER_NAME}:${USER_NAME} /workspace /home/${USER_NAME}

COPY docker/ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod 0755 /ros_entrypoint.sh

USER ${USER_NAME}

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${USER_NAME}/.bashrc \
    && echo 'if [ -f /workspace/devel/setup.bash ]; then source /workspace/devel/setup.bash; fi' >> /home/${USER_NAME}/.bashrc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
