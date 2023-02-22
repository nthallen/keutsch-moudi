#! /bin/bash

function print_usage {
cat 1>&2 <<'EOF'
# Usage:
#   ./monarch-moudi-install [ -E moudi:nthallen/keutsch-moudi.git ] [-n] [-h] [-S]
#
# -E <basename>:<URL>
#    Also install the instrument source code. <basename> is the
#    basename of the instrument's HomeDir. <URL> is unique portion
#    of the GitHub URL for the experiment's monarch codebase
# -S Install /etc/profile.d/ssh-agent.sh
# -n do not make any changes (test mode)
# -h print this help message
#
# clones the monarch git repository into
#   /usr/local/src/monarch/git
EOF
exit 1
}

# This script is intended to work on:
#   Ubuntu Linux
#   Cygwin
#   MacOS [eventually, but without installing Monarch for now]

function nl_error {
  echo "monarch-exp-install.sh: ERROR: $*" >&2
  exit 1
}

PATH=/usr/local/bin:/usr/bin:$PATH
startup_dir=$PWD
scriptname=monarch_install
matscriptfile=$scriptname.m
OS=`uname -s`
case "$OS" in
  CYGWIN_NT*) machine=Cygwin; sudo=;;
  Linux) machine=Linux; sudo=sudo;;
  Darwin) machine=Mac; sudo=sudo;;
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

exp_option='moudi:nthallen/keutsch-moudi.git'
exp_base=''
exp_url=''
testmode=no
installagent=no

while getopts "E:Shn" o; do
  case "$o" in
    S) installagent=yes;;
    n) testmode=yes;;
    h) print_usage;;
    E) exp_option=$OPTARG;;
  esac
done

if [ -n "$exp_option" ]; then
  exp_base=${exp_option%%:*}
  exp_lrl=${exp_option##*:}
  exp_url=git@github.com:$exp_lrl
  [ "$exp_base:$exp_lrl" = "$exp_option" ] ||
    nl_error "-E arg invalid: '$exp_base':'$exp_lrl'"
fi

myuser=`id -un`
if [ $machine = Cygwin ]; then
   # Verify that the flight group flight exists and user is a member
  id -Gn | grep -q '\bflight\b' || {
    echo "monarch_install: user '$myuser' does not appear to be a member"
    echo "of group 'flight'. If you have not run cygwin-monarch-moudi-install.ps1,"
    echo "do so now. Otherwise try restarting the system and then rerun"
    echo "cygwin-monarch-moudi-install.ps1."
    echo
    echo -n "Hit Enter to terminate:"
    read j
    exit 1
  }

  # Setup Shared Permissions
  if [ $testmode = yes ]; then
    echo "Skipping shared permission setup"
  else
    echo "Setting up shared permissions"
    chgrp -R flight /usr/local
    find /usr/local -type d | xargs chmod g+ws
  fi
  rundir=/var/run/monarch
  if [ ! -d $rundir ]; then
    echo "Creating $rundir"
    mkdir -p $rundir
    chgrp flight $rundir
    chmod g+ws $rundir
  fi
else
  # other operating systems (where we have sudo, among other things)
  nl_error "setup for non-Cygwin is not yet complete"
  # Check if flight user exists and add if necessary
  if grep -q "^flight:" /etc/passwd; then
    echo "monarch_install.sh: flight user already exists"
  else
    $sudo addgroup flight
    $sudo adduser --disabled-password --gecos "flight user" --no-create-home --ingroup flight flight
    echo "monarch_setup.sh: flight user created"
  fi
  $sudo adduser $myuser flight
fi

if [ $installagent = yes ]; then
  if [ $machine = Cygwin ]; then
    tmpdir='='`cygpath $USERPROFILE`/AppData/Local/Temp
  else
    tmpdir=''
  fi
  tmpfile=`mktemp --tmpdir$tmpdir ssh_agent.sh.XXXXXXXXX`
  cat >$tmpfile <<'EOF'
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
  if [ $testmode = yes ]; then
    echo "Skipping ssh-agent setup. tmpfile=$tmpfile"
  elif [ -n "$SSH_AGENT_PID" ]; then
    echo "ssh-agent already appears to be setup"
  else
    echo "setting up ssh-agent"
    $sudo mv $tmpfile /etc/profile.d/ssh_agent.sh
    $sudo chmod a+r /etc/profile.d/ssh_agent.sh
  fi
  rm -f $tmpfile
fi

# setup SSH Key
key_is_new=yes
function find_ssh_key {
  pubkey=''
  for key in ~/.ssh/id_*.pub; do
    [ -f $key ] && pubkey=$key
  done
}

find_ssh_key
if [ -z "$pubkey" ]; then
  while [ -z "$pubkey" ]; do
    cat <<'EOF'

You must create an SSH Key to facilitate interactions with GitHub
and between systems associated with your instruments.

We will run the command 'ssh-keygen' to do this. It will prompt you
for a file location, and you should accept the default.

You must also provide a passphrase in order to maintain the security
of your systems, as this key will provide access to your accounts
on multiple systems.

ssh-keygen:
EOF
    ssh-keygen
    find_ssh_key
  done
else
  key_is_new=no
fi

# Startup the ssh-agent if it isn't already running
[ -r /etc/profile.d/ssh_agent.sh ] && . /etc/profile.d/ssh_agent.sh
# and if it was, but we didn't have a key, let's add one:
ssh-add -l >/dev/null || ssh-add

if [ $key_is_new = no ]; then
  key_is_new=yes
  echo -n "Do you need to add your local SSH Key to your GitHub account? [Y/n]"
  read resp
  case "$resp" in
    [nN]*) key_is_new=no;;
  esac
fi

if [ $key_is_new = yes ]; then
  cat <<'EOF'

Now you need to add this key to your GitHub account in order to clone
source code for Monarch and/or your instrument. To do this, open a
web browser and login to or create your account at https://github.com

Then click on the user icon in the upper right corner of the screen
and select "Settings" from bottom of the dropdown list. Then select
"SSH and GPG Keys" from the list on the left and then the big green
"New SSH key" button.

In the "Title" field, provide a short description of the machine you
are installing from so you'll be able to remember where this key
came from. The "Key type" should remain as "Authentication Key".

Finally, copy and paste all the text below between two horizonatl
lines into the "Key" field and select "Add SSH key"

EOF
  echo "--------copy-below-here----------"
  cat $pubkey
  echo "--------copy-above-here----------"
  echo
  echo -n "When you have completed this step, hit Enter:"
  read resp
fi

echo
echo "Continuing:"
echo

if [ -d /usr/local/src/monarch/git ]; then
  echo
  echo "Skipping Monarch clone (already cloned)"
  echo
elif [ $testmode = yes ]; then
  echo
  echo "Skipping Monarch clone (testmode)"
  echo
else
  $sudo mkdir -p /usr/local/src/monarch
  [ -d /usr/local/src/monarch ] || nl_error "Unable to create /usr/local/src/monarch"
  $sudo chgrp flight /usr/local/src/monarch
  chmod g+ws /usr/local/src/monarch
  cd /usr/local/src/monarch
  git clone git@github.com:nthallen/monarch.git git ||
    nl_error "git returned an error"
  [ -d git ] || nl_error "Clone failed: Did you install your SSH key correctly?"
fi

if [ -d /usr/local/share/monarch/setup ]; then
  echo
  echo "Skipping Monarch Install (already installed)"
  echo "  See manual for update procedure"
  echo
else
  echo
  echo "Configuring and Building Monarch"
  echo
  cd /usr/local/src/monarch/git
  build_ok=no
  ./build.sh && $sudo ./build.sh install && build_ok=yes
  [ $build_ok = yes -a $machine != Cygwin ] &&
    /usr/local/share/monarch/setup/monarch_setup.sh

  echo
  echo "Monarch installation is complete"
  echo
fi

if [ -n "$exp_base" -a -n "$exp_url" ]; then
  echo "Assessing installation for instrument $exp_base from $exp_url"
  if [ -d /usr/local/share/monarch/setup ]; then
    # Monarch is installed, so we'll go with full installation
    arp_das_parent=/usr/local/src
    exp_home=/home/$exp_base
    [ -d $exp_home ] || /usr/local/sbin/mkexpdir $exp_base
    [ -d $exp_home ] || nl_error "Unable to create $exp_home"
    cd $exp_home
    exp_src=$exp_home/src
    if [ -d src ]; then
      echo "Skipping clone of instrument code"
      echo "   See manual for update procedure"
      echo
    else
      echo "Cloning instrument code into $exp_src"
      git clone $exp_url src
      [ -d src ] || nl_error "git clone $exp_url failed"
      cd src/TM
      appgen
      [ -f Makefile ] || nl_error "appgen apparently failed"
      echo "Instrument source code now ready for distribution in $exp_src"
    fi
  else
    arp_das_parent=$startup_dir
    cd $startup_dir
    exp_src=$startup_dir/$exp_base
    if [ -d $exp_base ]; then
      echo "Skipping clone of instrument code into $exp_src"
      echo "   Directory already exists"
      echo "   See manual for update procedure"
      echo
    else
      git clone $exp_url $exp_base
      [ -d $exp_base ] || nl_error "git clone of $exp_url failed"
    fi
  fi
  [ -d $exp_src ] || nl_error "Internal: expected exp_src at $exp_src"
  exp_eng_path=$exp_src/eng
  [ -d $exp_eng_path ] ||
    nl_error "Unable to locate 'eng' under $exp_src"
  exp_eng_wrap_path=`wrap_path $exp_eng_path`

  arp_das_matlab_path=$arp_das_parent/arp-das-matlab
  [ -d $arp_das_parent ] ||
    nl_error "Internal: thought '$arp_das_parent' was a directory"
  cd $arp_das_parent
  [ -d $arp_das_matlab_path ] ||
    git clone git@github.com:nthallen/arp-das-matlab.git
  arp_das_matlab_wrap_path=`wrap_path $arp_das_matlab_path`
  arp_das_matlab_ne_wrap_path=`wrap_path $arp_das_matlab_path/ne`
  arp_das_matlab_dfs_wrap_path=`wrap_path $arp_das_matlab_path/dfs`

  cat >$matscriptfile <<EOF
fprintf(1,'Running $scriptname to setup Matlab PATH for MOUDI\n');
addpath('$arp_das_matlab_wrap_path');
addpath('$arp_das_matlab_ne_wrap_path');
addpath('$arp_das_matlab_dfs_wrap_path');
addpath('$exp_eng_wrap_path');
savepath;
EOF

  if [ -f $exp_src/setup/getrun.cfg ]; then
    [ -d ~/.monarch ] || mkdir ~/.monarch
    while read Exp dirname startupname fdesc; do
      [ -f "$exp_eng_path/$startupname.m" ] ||
        nl_error "Startup script $startupname.m for $Exp not found"
      cat >~/.monarch/getrun.$Exp.config <<EOF
getrun_data_funcfile=$exp_eng_path/$dirname.m
getrun_startup=$startupname
EOF
      cat >>$matscriptfile <<EOF
fprintf(1,'Identify the directory for $fdesc\n');
update_ne_runsdir('$dirname', '$exp_eng_wrap_path');
EOF
    done < $exp_src/setup/getrun.cfg
  fi

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

fi
