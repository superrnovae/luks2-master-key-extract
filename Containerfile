FROM registry.fedoraproject.org/fedora:latest as builder

ARG KERNEL_VERSION
ARG LIME_VERSION
ARG LIME_SHA256
# r83 -> d1d8e1c7dc464deeb53e5667b7e7a40915cc87404445a779057e18448ad565e0

WORKDIR /tmp

# Install koji and use to pull kernel packages based on KERNEL_VERSION
RUN dnf install -y koji && \
    mkdir /tmp/koji && \
    cd /tmp/koji && \
    koji download-build --arch=x86_64 kernel-${KERNEL_VERSION::-7} 

RUN cd /tmp/koji && \
    dnf install -y \
    gc gcc glibc-devel glibc-headers \
    ./kernel-core-${KERNEL_VERSION}.rpm ./kernel-devel-${KERNEL_VERSION}.rpm ./kernel-modules-${KERNEL_VERSION}.rpm && \
    dnf clean all -y
    
    
RUN curl -LS https://github.com/504ensicsLabs/LiME/tarball/master| \
    { t="$(mktemp)"; trap "rm -f '$t'" INT TERM EXIT; cat >| "$t"; sha256sum --quiet -c <<<"${LIME_SHA256} $t" \
    || exit 1; cat "$t"; } | tar xzf - && \
    mv "$t"*LiME* LiME-${LIME_VERSION}

RUN cd /tmp/LiME-${LIME_VERSION}/src; \
    make -j$(nproc)

FROM registry.fedoraproject.org/fedora:latest

ARG LIME_VERSION
ARG KERNEL_VERSION
WORKDIR /tmp

COPY --from=builder /tmp/koji/ /tmp/koji/

RUN cd /tmp/koji && \
    dnf install -y ./kernel-core-${KERNEL_VERSION}.rpm ./kernel-modules-${KERNEL_VERSION}.rpm && \
    rm -rf /tmp/koji

COPY --from=builder /tmp/LiME-${LIME_VERSION}/src/lime-${KERNEL_VERSION}.ko \
                    /usr/lib/modules/${KERNEL_VERSION}/extra/lime-${KERNEL_VERSION}.ko

