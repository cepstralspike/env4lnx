# ~/.profile: executed by the 
# command interpreter for login shells.
# This file is not read by bash(1) 
# if
# 
# ~/.bash_profile 
# or 
# ~/.bash_login 
#
# exist.
# 
# examples: /usr/share/doc/bash/examples/startup-files
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; 
# for setting the umask
# for ssh logins, install and configure the libpam-umask package.
# umask 022

if [[ $- == *i* ]]
then
    #
    # running interactive
    #
    echo ".profile: DISPLAY=$DISPLAY"
fi
if [ -n "$BASH_VERSION" ]; then
    #
    # include .bashrc if it exists
    #
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    else
        # set PATH so it includes user's private bin if it exists
        if [ -d "$HOME/bin" ] ; then
            PATH="$HOME/bin:$PATH"
        fi
    fi
fi

if [ "0" = "$UID" ]
then
    mesg n
fi
