#! /bin/bash
# Usage:
#   ./moudi_matlab_setup.sh
#   ./moudi_matlab_setup.sh [https|ssh] [debug]
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

if [ $machine = Cygwin -a ! -f /etc/profile.d/ssh_agent.sh ]; then
ssh_profile=/etc/profile.d/ssh_agent.sh
cat <<"EOF" > $ssh_profile
# This can be copied to /etc/profile.d/ssh_agent.sh to be run on
# the first invocation of the shell after reboot.
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     echo "Initialising new SSH agent..."
     rm -rf /tmp/ssh-*
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

[ -d ~/.ssh ] || mkdir ~/.ssh

if [ -f "${SSH_ENV}" ]; then
  . "${SSH_ENV}" > /dev/null
  if [ -z "${SSH_AGENT_PID}" ] || ! kill -0 ${SSH_AGENT_PID} 2>/dev/null; then
    start_agent
  fi
else
  start_agent
fi
EOF
chmod 0644 $ssh_profile
fi

keyfile=''
while [ -z "$keyfile" ]; do
  for kfile in ~/.ssh/id_*.pub; do
    [ -f $kfile ] && keyfile=$kfile
  done

  if [ -z "$keyfile" ]; then
    cat <<EOF
You do not have an SSH Key created on this machine.
You will need an SSH Key to access the GitHub repositories for
this instrument and to access the flight computer and/or GSE
computers. We will create one now.

You will be prompted for the location of the new key. Accept
the default location, which should be correct.

Then you will be prompted for a passphrase. Be sure to choose
a secure passphrase that you will remember. You will need to
enter this to unlock your SSH Key when initiating a connection
to a remote machine or when adding the key to the SSH agent.

EOF
    ssh-keygen
    echo
    echo "Now add your new SSH key to the ssh-agent:"
    echo
    if [ -n "$ssh_profile" -o -z "$SSH_AGENT_PID" ]; then
      . $ssh_profile
    else
      ssh-add
    fi
  elif [ -z "$SSH_AGENT_PID" ]; then
  fi
done

[ -n

if ask_yes_no "Do you need to add your local SSH Key to your GitHub account?"; then
  cat <<EOF
Do the following:
  1: Open a browser
  2: Login to your account at GitHub.com
  3: Click on your user icon in the upper right and select
     "Settings" from the dropdown list
  4: Select "SSH and GPG keys" from the list on the left
  5: Select the green "New SSH key" button
  6: Enter a description of this machine into the "Title" block
  7: Copy and paste the following text into the block labeled "Key"
  8: Select the green "Add SSH key" button

EOF
  cat $keyfile
  echo
  echo -n "Hit Enter when you have finished adding your key: "
  read j
fi

method='ssh://git@'

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
EOF

# delete $ofile
# fprintf(1,'MOUDI Setup complete\n');
# pause(2);
# quit

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
