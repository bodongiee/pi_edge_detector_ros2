# ====== Base (Ubuntu 22.04 + ROS2 Humble) ======
FROM --platform=$TARGETPLATFORM ros:humble-ros-base

# 로케일/기본 설정
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    locales tzdata sudo curl wget \
    # ROS 빌드에 필요한 툴
    python3-colcon-common-extensions \
    python3-pip build-essential git \
    # 카메라/V4L2 유틸
    v4l-utils \
    # udev 접근
    udev \
 && rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 워크스페이스
WORKDIR /ws
# 호스트의 src를 이미지에 복사 (CI 빌드 시)
# 개발 중에는 bind mount를 권장하므로 이 줄은 CI 전용으로 유지
COPY ./src ./src

# ROS 환경
SHELL ["/bin/bash", "-lc"]
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc

# 의존성(필요 시 예: pip 패키지나 rosdep)
# RUN pip3 install <your-python-deps>

# colcon 빌드 (CI에서만 유효, 개발 컨테이너에서는 실행 시 빌드 권장)
RUN source /opt/ros/humble/setup.bash && \
    colcon build --merge-install || true

# 엔트리포인트: ROS/워크스페이스 환경 자동 로드
RUN echo 'source /opt/ros/humble/setup.bash' >> /root/.bashrc && \
    echo 'test -f /ws/install/setup.bash && source /ws/install/setup.bash || true' >> /root/.bashrc

CMD ["bash"]

