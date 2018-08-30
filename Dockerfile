FROM alpine:3.8

ENV OPENCV_VERSION=3.4.3 \
    OPENCV_CONTRIB_VERSION=3.4.3 \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib64
ENV OPENCV_ARCHIVE=https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz \
    OPENCV_CONTRIB_ARCHIVE=https://github.com/opencv/opencv_contrib/archive/${OPENCV_CONTRIB_VERSION}.tar.gz

RUN apk add --no-cache \
      ffmpeg \
 && apk add --no-cache --virtual .build-deps \
      binutils-gold cmake make gcc g++ git curl linux-headers ffmpeg-dev \
 && mkdir /tmp/opencv /tmp/opencv_contrib \
 && curl -sSL "${OPENCV_ARCHIVE}" | tar -xz --strip 1 -C /tmp/opencv \
 && curl -sSL "${OPENCV_CONTRIB_ARCHIVE}" | tar -xz --strip 1 -C /tmp/opencv_contrib \
 && mkdir /tmp/opencv/build \
 && cd /tmp/opencv/build \
 && cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib/modules \
          -D INSTALL_PYTHON_EXAMPLES=OFF \
          -D INSTALL_C_EXAMPLES=OFF \
          -D WITH_FFMPEG=ON \
          -D WITH_TBB=ON \
          .. \
 && make -j$(nproc) \
 && make install \
 && apk del --no-cache .build-deps \
 && rm -rf /tmp/opencv /tmp/opencv_contrib
