#!/bin/bash

set -eux

if [ $# -ne 1 ]; then
  echo "Expecting a directory as an argument"
  exit 1
fi

cd $JEDI_SRC

fv3jedi_dir="$JEDI_SRC/fv3-jedi"
model_dir="$1/model"

[[ ! -d $fv3jedi_dir ]] && ( echo "Source area $fv3jedi_dir does not exist, ABORT!"; exit 1)

# Create directories
# [[ -d $model_dir ]] && ( echo "Staging area $model_dir exists, ABORT!"; exit 1)
mkdir -p $model_dir
fieldsets=$model_dir/fieldsets
fv3files=$model_dir/fv3files
mkdir -p $fieldsets
mkdir -p $fv3files

# Copy files from fv3-jedi to the model area

# Copy fieldsets
cp $fv3jedi_dir/test/Data/fieldsets/dynamics.yaml $fieldsets/

# Copy static fv3files
cp $fv3jedi_dir/test/Data/fv3files/akbk64.nc4 $fv3files/
cp $fv3jedi_dir/test/Data/fv3files/field_table $fv3files/
cp $fv3jedi_dir/test/Data/fv3files/fmsmpp.nml $fv3files/
cp $fv3jedi_dir/test/Data/fv3files/input_gfs_c12.nml $fv3files/
cp $fv3jedi_dir/test/Data/fv3files/inputpert_4dvar.nml $fv3files/

# migrate restarts
cat > migrate.py << EOF
import r2d2

r2d2.Migrate(
    model_name='fv3jedi',
    type='an',
    source_dir="$fv3jedi_dir/test/Data/inputs/gfs_c12/bkg"
)
EOF
python migrate.py

tree -L 3 $model_dir

exit
