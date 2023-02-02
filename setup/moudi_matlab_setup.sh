#! /bin/bash
# Usage:
#   ./moudi_matlab_setup.sh
#   ./moudi_matlab_setup.sh ssh
#
#
# Copy this script to a directory where you want the software
# to be installed.
#
# To obtain this script, you will probably have cloned
# the MOUDI instrument source code. Unless that code is
# in /home/moudi/src or ./moudi, this script will clone it
# again.
#
# One or two repositories will be cloned:
#    https://github.com/nthallen/arp-das-matlab.git
#    https://github.com/nthallen/keutsch-moudi.git
# If you plan on pushing updates to either repo and have
# setup your SSH key on GitHub, use the 2nd command with
# the ssh argument.
#
function nl_error {
  echo "moudi_matlab_setup: $*" >&2
  exit 1
}
scriptname=moudi_matlab_setup
ofile=$scriptname.m
OS=`uname -s`
use_cygpath=no
case "$OS" in
  CYGWIN_NT*) machine=Cygwin;;
  Linux) machine=Linux;;
  Darwin) machine=Mac;;
  *) nl_error "Unable to identify operating system: uname -s said '$OS'";;
esac

# wrap_path path
# Outputs the path in a format suitable for use within MATLAB on this platform.
function wrap_path {
  path=$1
  case "$machine" in
    Cygwin) cygpath -w $path;;
    *) echo $path;;
  esac
}

method='https://'
[ "$1" = "ssh" ] && method='ssh://git@'

[ -d arp-das-matlab ] ||
  git clone ${method}github.com/nthallen/arp-das-matlab.git
arp_das_matlab_wrap_path=`wrap_path $PWD/arp-das-matlab`
arp_das_matlab_ne_wrap_path=`wrap_path $PWD/arp-das-matlab/ne`
arp_das_matlab_dfs_wrap_path=`wrap_path $PWD/arp-das-matlab/dfs`
if [ -d /home/moudi/src ]; then
  moudi_eng_path=/home/moudi/src/eng
elif [ -d ./moudi/eng ]; then
  moudi_eng_path=$PWD/moudi/eng
else
  git clone ${method}github.com/nthallen/keutsch-moudi.git moudi
  moudi_eng_path=$PWD/moudi/eng
fi
moudi_eng_wrap_path=`wrap_path $moudi_eng_path`

mkdir ~/.monarch

cat >~/.monarch/getrun.Moudi.config <<EOF
getrun_data_funcfile=$moudi_eng_path/MOUDI_DATA_DIR.m
getrun_startup=MOUDI_startup
EOF

cat >~/.monarch/getrun.MPGS.config <<EOF
getrun_data_funcfile=$moudi_eng_path/MOUDI_PGS_DATA_DIR.m
getrun_startup=MPGS_startup
EOF

cat >$ofile <<EOF
fprintf(1,'Running $scriptname to setup Matlab PATH for MOUDI\n');
addpath('$arp_das_matlab_wrap_path');
addpath('$arp_das_matlab_ne_wrap_path');
addpath('$arp_das_matlab_dfs_wrap_path');
addpath('$moudi_eng_wrap_path');
savepath;
fprintf(1,'First: Identify the directory for MOUDI MATLAB data\n');
update_ne_runsdir('MOUDI_DATA_DIR', '$moudi_eng_wrap_path');
fprintf(1,'Next: Identify the directory for MOUDI MPGS MATLAB data\n');
update_ne_runsdir('MOUDI_PGS_DATA_DIR', '$moudi_eng_wrap_path');
delete $ofile
fprintf(1,'MOUDI Setup complete\n');
pause(2);
quit
EOF

# Now locate matlab and run it, specifying this directory and the
# name of the newly created set script
S=`which matlab 2>/dev/null`
if [ -n "$S" ]; then
  matlab=matlab
else
  for path in /Applications/MATLAB*; do
    [ -e $path/bin/matlab ] && matlab=$path/bin/matlab
  done
fi

SW_wrap_path=`wrap_path $PWD`
if [ -n "$matlab" ]; then
  echo "Starting $matlab to complete setup"
  eval $matlab -sd '$SW_wrap_path' -r $scriptname
else
  nl_error "Unable to locate Matlab executable"
fi
