#!/bin/bash

pwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

bundle_dir=${1:-$pwd}
clearall=${2:-"NO"}

export JEDI_SRC=${bundle_dir}
export JEDI_BIN=${bundle_dir}/build/bin
export EWOK_TMP=${bundle_dir}/ewok_tmp

if [[ $clearall =~ [yYtY] ]]; then

  unset JEDI_BIN
  unset JEDI_SRC
  unset EWOK_TMP

fi
