#!/bin/bash
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2019 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
echo "---> cmake-sonar.sh"

build_dir="${BUILD_DIR:-$WORKSPACE/target}"
cmake_opts="${CMAKE_OPTS:-}"
make_opts="${MAKE_OPTS:-}"

################
# Script start #
################

set -ex -o pipefail

cd /tmp || exit 1
wget -O /tmp/sonar-scan.zip \
    "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip"
unzip sonar-scan.zip
sudo mv sonar-scanner-* /opt/sonar-scanner

wget -O /tmp/bw.zip \
    "https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip"
unzip bw.zip
sudo mv build-wrapper-* /opt/build-wrapper

mkdir -p "$build_dir"
cd "$build_dir" || exit 1
# $cmake_opts needs to wordsplit to pass options.
# shellcheck disable=SC2086
eval cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" $cmake_opts ..

/opt/build-wrapper/build-wrapper-linux-x86-64 --out-dir "$WORKSPACE/bw-output" \
    make $make_opts

/opt/sonar-scanner/bin/sonar-scanner \
    -Dsonar.projectKey=${PROJECT_KEY} \
    -Dsonar.organization=${PROJECT_ORGANIZATION} \
    -Dsonar.sources=. \
    -Dsonar.cfamily.build-wrapper-output="$WORKSPACE/bw-output" \
    -Dsonar.host.url=${SONAR_HOST_URL} \
    -Dsonar.login=${API_TOKEN}
