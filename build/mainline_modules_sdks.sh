#!/bin/bash -ex
#
# Copyright (C) 2021 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

function main() {
  if [ ! -e "build/make/core/Makefile" ]; then
    echo "$0 must be run from the top of the tree"
    exit 1
  fi

  # Assign to a variable and eval that, since bash ignores any error status from
  # the command substitution if it's directly on the eval line.
  vars="$(TARGET_PRODUCT='' build/soong/soong_ui.bash --dumpvars-mode \
    --vars="BUILD_NUMBER DIST_DIR OUT_DIR")"
  eval "${vars}"

  # Building with --soong-only and module products requires build_number.txt for
  # some targets.
  echo -n "${BUILD_NUMBER}" > "${OUT_DIR}"/soong/build_number.txt

  # Delegate the SDK generation to the python script. Use the python version
  # provided by the build to ensure consistency across build environments.
  export DIST_DIR OUT_DIR
  prebuilts/build-tools/linux-x86/bin/py3-cmd packages/modules/common/build/mainline_modules_sdks.py "$@"
}

main "${@}"
