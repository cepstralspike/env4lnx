#!/bin/bash
set +x
set +v
set +o functrace

set nocasematch
#
rnd32()
{
    xxd -l 4 -p /dev/urandom|tr '[:lower:]' '[:upper:']
}

rnd16()
{
    xxd -l 2 -p /dev/urandom|tr '[:lower:]' '[:upper:']
}

hh()
{
    if [ $# -gt 0 ]
    then
        history         | \
        egrep -e "$@"   | \
        tail -30
    else
        history         | \
        tail -30
    fi
}

hhh()
{
    if [ $# -gt 0 ]
    then
        history         | \
        egrep -e "$@"   | \
        tail -90
    else
        history         | \
        tail -90
    fi
}

hhhh()
{
    if [ $# -gt 0 ]
    then
        history         | \
        egrep -e "$@"
    else
        history
    fi
}

ci()
{
    git commit -m$(date +%Y%m%d.%H%M%S.%N) "$@"
}

eee()
{
    e1=/usr/lib/libreoffice/program/soffice.bin
    log=$HOME/00/log/libreoffice.$(/bin/date +%Y%m%d.%H%M%S.%N).txt
    $e1 --writer "$@" > $log 2>&1 &
}

vvv()
{
    gvim $* 2>/var/log/user/$(ds).gvim.startup.error.log
}

vvvr()
{
    gvim -R $*  2>/var/log/user/$(ds).gvim.startup.error.log
}

vv()
{
    vim $*
}

vvr()
{
    vim -R $*
}

lll()
{
    # list files and directories
    # with full path names
    ls --group-directories-first -lQtrh \
               --time-style=long-iso $*|\
             perl -pe 's{"}{'`pwd`'/}' |\
                        sed -e's/"//g'
}

ll()
{
    # list files and directories
    # with only the element (file/dir) name
    ls --group-directories-first -ltrh --time-style=long-iso $*
}

lld()
{
    # list directories
    # with only the dir name
    ls -ltrh --time-style=long-iso $* | grep '^d'
}

llddold()
{
    # list directories
    # with full path names
    whereiwuz=$(pwd)
    if [[ -d "$1" ]]
    then
        cd $1
    fi

    ls -lQtrh --time-style=long-iso    |\
                             grep '^d' |\
             perl -pe 's{"}{'`pwd`'/}' |\
                        sed -e's/"//g'

    whereiam=$(pwd)
    if [[ X$whereiam != X$whereiwuz ]]
    then
        cd $whereiwuz
    fi
}

lldd()
{
    # list directories
    # with full path names
    if [[ $# -gt 0 ]]
    then
        param="$1"
    else
        param=$(pwd)
    fi

    paramIsDirectory=0
    whereiwuz=$(pwd)
    if [[ -d "$param" ]]
    then
        paramIsDirectory=1
        targetDirectory=$param
    else
        targetDirectory=$(dirname $param)
    fi

    cd $targetDirectory

    if [[ X1 == X$paramIsDirectory ]]
    then
        ls -lQtrh --time-style=long-iso |\
                           grep    '^d' |\
              perl -pe 's{"}{'`pwd`'/}' |\
                         sed -e's/"//g'
    else
        d=${param##*/}
        ls -lQtrh --time-style=long-iso $d|\
                           grep    '^d'   |\
              perl -pe 's{"}{'`pwd`'/}'   |\
                         sed -e's/"//g'
    fi 

    whereiam=$(pwd)
    if [[ X$whereiam != X$whereiwuz ]]
    then
        cd $whereiwuz
    fi
}

llf()
{
    # list files
    # with only the file name
    ls -ltrh --time-style=long-iso $* | grep -v '^d'
}

llff()
{
    # list files
    # with full path names
    if [[ $# -gt 0 ]]
    then
        param="$1"
    else
        param=$(pwd)
    fi

    paramIsDirectory=0
    whereiwuz=$(pwd)
    if [[ -d "$param" ]]
    then
        paramIsDirectory=1
        targetDirectory=$param
    else
        targetDirectory=$(dirname $param)
    fi

    cd $targetDirectory

    if [[ X1 == X$paramIsDirectory ]]
    then
        ls -lQtrh --time-style=long-iso |\
                           grep -v '^d' |\
              perl -pe 's{"}{'`pwd`'/}' |\
                         sed -e's/"//g'
    else
        f=$(basename $param)
        ls -lQtrh --time-style=long-iso $f|\
                           grep -v '^d'   |\
              perl -pe 's{"}{'`pwd`'/}'   |\
                         sed -e's/"//g'
    fi 

    whereiam=$(pwd)
    if [[ X$whereiam != X$whereiwuz ]]
    then
        cd $whereiwuz
    fi
}

llh()
{
    # list hidden files
    # with only the file name
    ls -lAh  --time-style=long-iso $* |\
                         grep -v '^d' |\
           egrep -e ':[0-9][0-9] [.]'
}

llhh()
{
    # list hidden files
    # with full path names
    ls -lQAh  --time-style=long-iso $* |\
                          grep -v '^d' |\
                       egrep -e '"[.]' |\
             perl -pe 's{"}{'`pwd`'/}' |\
                        sed -e's/"//g'

}

llhd()
{
    # list hidden directories
    # with only the dir name
    ls -lAh  --time-style=long-iso $* |\
                            grep '^d' |\
           egrep -e ':[0-9][0-9] [.]'
}

llhdd()
{
    # list hidden directories
    # with full path names
    whereiwuz=$(pwd)
    if [[ -d "$1" ]]
    then
        cd $1
    fi

    ls -lQAh  --time-style=long-iso    |\
                             grep '^d' |\
                       egrep -e '"[.]' |\
             perl -pe 's{"}{'`pwd`'/}' |\
                        sed -e's/"//g'

    whereiam=$(pwd)
    if [[ X$whereiam != X$whereiwuz ]]
    then
        cd $whereiwuz
    fi
}

re_encode4grep()
{
    grep_encoding=$1
    shift
    if [ $# -gt 0 ]
    then
        #
        # tag0 looks like: 1468690736
        # tag1 looks like: 1468690736.343614313
        #
        tag1=$(/bin/date +%Y%m%d.%H%M%S.%N)
        tag0=$(echo $tag1 | sed -e 's/[.].*//')
        while [ $# -gt 0 ]
        do
            f1=$1
            shift

            if [ -d $f1 ]
            then
                continue
            fi

            if [ -f $f1 ]
            then
                f1_prime=/tmp/$tag0.$(basename $f1)
                f1_keep=/tmp/$tag1.$(basename $f1)
                f1_encoding=$(file --mime-encoding -b $f1)
                if [[ 'Xus-ascii' == X$f1_encoding ]]
                then
                    echo
                    echo "[+++++++ No need. $f1 encoding is us-ascii +++++++]"
                    echo
                    echo
                    continue
                fi
                if [[ 'Xutf-8' == X$f1_encoding ]]
                then
                    echo
                    echo "[+++++++ No need. $f1 encoding is utf-8 +++++++]"
                    echo
                    echo
                    continue
                fi
                if [[ Xbinary == X$f1_encoding ]]
                then
                    echo
                    echo "[******* No can do. $f1 encoding is binary *******]"
                    echo
                    echo
                    continue
                fi
                iconv --output=$f1_prime -f $f1_encoding -ct $grep_encoding $f1
                mv $f1 $f1_keep
                cat $f1_prime | perl -pe '{ s{\r\n}{\n} }' > $f1
                chmod --reference=$f1_keep $f1
                md5sum --binary $f1
                md5sum --binary $f1_keep
                md5sum --binary $f1_prime

                echo "[+++ Original stored in $f1_keep +++]"
                echo
                echo
            else
                echo "re_encode4grep() [******* CANNOT FIND $f1 *******]"
            fi
        done
    else
        echo "re_encode4grep() [******* NO ARGUMENT PROVIDED! *******]"
    fi
}

tou8()
{
    if [ $# -gt 0 ]
    then
        re_encode4grep utf8 "$@"
    else
        echo "tou8() [******* NO ARGUMENT PROVIDED! *******]"
    fi
}
alias 2u8=tou8

echo_histcmd()
{
    echo -n $HISTCMD
}

toascii()
{
    if [ $# -gt 0 ]
    then
        re_encode4grep ascii "$@"
    else
        echo "toascii() [******* NO ARGUMENT PROVIDED! *******]"
    fi
}
alias 7bit=toascii

ss()
{
    if [ $# -gt 0 ]
    then
        dumpDirectoryHistory.pl  |\
        egrep -e "$@"            |\
        tail -30
    else
        dumpDirectoryHistory.pl  |\
        tail -30
    fi
}

sss()
{
    if [ $# -gt 0 ]
    then
        dumpDirectoryHistory.pl  |\
        egrep -e "$@"            |\
        tail -90
    else
        dumpDirectoryHistory.pl  |\
        tail -90
    fi
}
ssss()
{
    if [ $# -gt 0 ]
    then
        dumpDirectoryHistory.pl  |\
        egrep -e "$@"            |\
        tail -8191
    else
        dumpDirectoryHistory.pl  |\
        tail -8191
    fi
}

prompt_command()
{
    if [[ $- == *i* ]]
    then
        #
        # This is an interactive session
        # this "$- == *i*" conditional
        # is needed so that sftp still
        # works
        #
        history -a
        echo
        if [[ ! -f $HOME/.dhist ]]
        then
            tag="$(date +%Y%m%d.%H%M%S.%N)X$(pwd)"
            echo $tag >> $HOME/.dhist
        fi
        #
        # extract directory without timestamp from .dhist
        #
        lastdir=$(tail -1 $HOME/.dhist|cut --delimiter=X --fields=1 --complement)
        if [[ X$(pwd) != X$lastdir ]]
        then
            tag="$(date +%Y%m%d.%H%M%S.%N)X$(pwd)"
            echo $tag >> $HOME/.dhist
        fi
        tput setaf 4
        tput bold
        echo "[ $(/bin/date +%Y%m%d.%H%M%S) ] $(/bin/hostname) ( $(rnd32) ) { $(/bin/pwd) }"
        tput sgr0
        #
        # Make host and user name appear on the title bar
        #
        upperhost=$(hostname|tr /a-z/ /A-Z/)
        upperuser=$(echo $USER|tr /a-z/ /A-Z/)
        printf "\033]0;[ $upperhost $upperuser $$ ]\007"
    fi
}

setPS1()
{
    if [[ $- == *i* ]]
    then
        #
        # This is an interactive session
        # this "$- == *i*" conditional
        # is needed so that sftp still
        # works
        #
        if [[ "0" == "$UID" ]]
        then
            x='# '
        else
            x=': '
        fi
        export PS1="$x"
    fi
}

dblcmd()
{
    cmd2run=/home/nomad/bin/doublecmd/doublecmd.sh
    if [[ -f $cmd2run && -x $cmd2run ]]
    then
        tstamp=$(/bin/date +%Y%m%d.%H%M%S.%N)
        log=$HOME/00/log/doublecmd/doublecmd.$tstamp.log
        $cmd2run > $log 2>&1 &
    fi
}

keeper()
{
    if [[ -f /usr/bin/keeperpasswordmanager ]]
    then
        tstamp=$(/bin/date +%Y%m%d.%H%M%S.%N)
        e1=/usr/bin/keeperpasswordmanager
        log=$HOME/00/log/keeper/keeperpasswordmanager.$tstamp.log
        $e1 > $log 2>&1 &
    else
        d0=$(pwd)
        cd /opt/keeper
        java -Xms256m -Xmx1g -d64 -jar KeeperDesktop.jar&
        cd "$d0"
    fi
}

ds()
{
    date +%Y%m%d.%H%M%S.%N
}

pp()
{
    echo "***********************************"
    echo $PATH | tr ':' "\n"
    echo "***********************************"
}

mc()
{
    $(which mc) -a
}

linword()
{
    openoffice.org -writer $*
}

pathfixup()
{
#
# Prevent duplicate entries in the path name
# because they indicate/encourage sloppy practice
#
PATHVAR=$1
perlStrg=$(cat<<-'EOPERL'
#! /usr/bin/perl
%b=();
@a=split(q(:),<>);
foreach(@a){
    s{\s+\z}{};
    if(! exists( $b{$_} ) ){
        print( qq($_) . q(:) );
        $b{$_}=0
    }
}
EOPERL
)
    perlProg="/tmp/xi.$$.$RANDOM.$$.ix.pl"
    echo "$perlStrg" > $perlProg
    chmod +x "$perlProg"
    #
    # Bash Reference Manual version 4.3
    # 3.5.3 Shell Parameter Expansion
    # "If the first character of parameter is an
    #  exclamation point (!), it introduces a level of
    #  variable indirection. Bash uses the value of the
    #  variable formed from the rest of parameter
    #  as the name of the variable;"
    #
    export $PATHVAR=$(echo ${!PATHVAR} | $perlProg | perl -pe 's/:\z//')
    rm $perlProg
}

py35()
{
    export PYTHON35HOME=/opt/py35
    pybin="/opt/py35/bin"
    pyexe="/opt/py35/bin/python3.5"
    idx=0
    declare -a ppth_item
    ppth_item[$((idx++))]=$HOME/bin
    ppth_item[$((idx++))]=$HOME/android-platform-tools
    pth_items[$((idx++))]=/opt/samba/sbin
    pth_items[$((idx++))]=/opt/samba/bin
    ppth_item[$((idx++))]=$GOROOT/bin
    ppth_item[$((idx++))]=$GOPATH/bin
    ppth_item[$((idx++))]=/opt/bin
    ppth_item[$((idx++))]=/opt/smartgit/bin
    ppth_item[$((idx++))]=/opt/py35/bin
    ppth_item[$((idx++))]=/opt/py35/lib/python3.5
    ppth_item[$((idx++))]=/opt/py35/lib64/python3.5
    ppth_item[$((idx++))]=/opt/py35/lib64/python3.5/lib-dynload
    for e in ${ppth_item[@]}
    do
        if [ -d "$e" ]
        then
            #
            # the ${PATH:+:} magic means...
            # if $PATH is empty dont append ':' after $prefix
            #
            pypth=$pypth${pypth:+:}$e
        fi
    done
    export PYTHON35PATH=$pypth
    pathfixup PYTHON35PATH
    if [[ X$(echo $PATH|tr ':' "\n"|grep $pybin) == X ]]
    then
        #
        # the ${PATH:+:} magic means...
        # if $PATH is empty dont append ':' after $pypth
        #
        export PATH="$PYTHON35PATH${PATH:+:}${PATH}"
    fi
}

supath()
{
    idx=0
    declare -a pth_items
    pth_items[$((idx++))]=$HOME/bin
    pth_items[$((idx++))]=/opt/samba/sbin
    pth_items[$((idx++))]=/opt/samba/bin
    pth_items[$((idx++))]=/opt/vim/bin
    pth_items[$((idx++))]=/opt/bin
    pth_items[$((idx++))]=/opt/smartgit/bin
    for e in ${pth_items[@]}
    do
        if [ -d "$e" ]
        then
            #
            # the ${PATH:+:} magic means...
            # if $PATH is empty dont append ':' after $prefix
            #
            prefix=$prefix${prefix:+:}$e
        fi
    done
    export PATH="$prefix${PATH:+:}${PATH}"
}

pkpath()
{
    idx=0
    declare -a pth_items

    pth_items[$((idx++))]=$HOME/bin

    pth_items[$((idx++))]=$SDKMANROOT/candidates/maven/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/kscript/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/kotlin/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/java/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/groovyserv/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/groovy/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/grails/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/gradle/current/bin
    pth_items[$((idx++))]=$SDKMANROOT/candidates/crash/current/bin

    if [[ X$JAVA_HOME != X ]]
    then
        pth_items[$((idx++))]=$JAVA_HOME/bin
    fi

    if [[ X$SCALA_HOME != X ]]
    then
        pth_items[$((idx++))]=$SCALA_HOME/bin
    fi


    pth_items[$((idx++))]=$HOME/android-platform-tools
    pth_items[$((idx++))]=$HOME/Android/Sdk/ndk-bundle
    pth_items[$((idx++))]=/opt/node-v8.9.4-linux-x64/bin
    pth_items[$((idx++))]=$GOROOT/bin
    pth_items[$((idx++))]=$GOPATH/bin
    pth_items[$((idx++))]=/opt/vim/bin
    pth_items[$((idx++))]=/opt/google/chrome
    pth_items[$((idx++))]=/opt/samba/sbin
    pth_items[$((idx++))]=/opt/samba/bin
    pth_items[$((idx++))]=/opt/flutter/bin
    pth_items[$((idx++))]=/opt/bin
    pth_items[$((idx++))]=/opt/google-cloud-sdk/bin
    pth_items[$((idx++))]=/opt/smartgit/bin
    pth_items[$((idx++))]=$PYTHON35HOME/bin
    pth_items[$((idx++))]=$PYTHON35HOME/lib/python3.5
    pth_items[$((idx++))]=$PYTHON35HOME/lib64/python3.5
    pth_items[$((idx++))]=$PYTHON35HOME/lib64/python3.5/lib-dynload
    pth_items[$((idx++))]=/opt/rakudo-star-2017.07/bin
    pth_items[$((idx++))]=/opt/rakudo-star-2017.07/share/perl6/site/bin

    for e in ${pth_items[@]}
    do
        #
        # Only append path entrys for
        # directories that exist on this 
        # host
        #
        if [ -d "$e" ]
        then
            #
            # the ${PATH:+:} magic means...
            # if $PATH is empty dont append ':' after $pypth
            #
            pypth=$pypth${pypth:+:}$e
        fi
    done
    export PYTHON35PATH=$pypth
    export PATH="$PYTHON35PATH${PATH:+:}${PATH}"
}

lshd(){
    sudo blkid
}
alias listhd=lshd
alias lsdisk=lshd
alias lsdsk=lshd

viewpdf(){
    logfile=$(printf '%s%06d%s%04d%s' "/var/log/user/$(ds)." "$$" "." "$UID" ".vuepdf.log")
    okular $* 2>$logfile &
}
alias pdfview=viewpdf
alias vpdf=viewpdf
alias vuepdf=viewpdf

instantiate_HISTFILE()
{
    #
    # each console window gets its own history file.
    # the elaborate merging operation that follows
    # makes sure
    #    1) no typed command gets lost regardless of window close order
    #    2) a command like "ls -la" shows up only once in the history no matter how often invoked (no duplicates)
    #    3) every command in the history file has a time stamp for the most recent time invoked
    #
    export HISTPREFIX=$HOME/history.d/bash_history
    export HISTSTAMP=$(date +%s.%N)
    export HISTWHEN=$(date +%Y%m%d.%H%M%S)
    export HISTFILE=$HISTPREFIX/history.XI${HISTSTAMP}IX.$$
    export HISTARCHIVE=${HISTPREFIX}_archive

    for i in $HISTPREFIX $HISTARCHIVE
    do
        if [[ ! -d $i ]]
        then
            mkdir -p $i
        fi
    done

    #
    # All History command merges will
    # be done just with python2.
    #
    /opt/bin/py2bld_bash_history.py          \
        --search_path $(dirname  $HISTFILE)  \
        --output_path $(dirname  $HISTFILE)  \
        --output_file $(basename $HISTFILE)

    export HISTSIZE=$((65535 << 2))
    export HISTFILESIZE=$(($HISTSIZE << 4))
    export HISTTIMEFORMAT=" [ %Y%m%d.%H%M%S ] "
    if [ ! -d $HISTARCHIVE ]
    then
        mkdir --parents $HISTARCHIVE
    fi
    for i in $( ls -1 $HISTPREFIX/history.XI*IX* | grep -v "$HISTFILE" )
    do
        BASH_PID=$(echo $i | perl -pe 's/\A.+IX[.](\d+)\Z/$1/')
        kill -s 0 $BASH_PID 2>/dev/null
        ERROR_CODE=$?
        #
        # WHAT FOLLOWS IS CLEANUP CODE THAT SWEEPS COMPLETED HISTORY
        # FILES INTO THE ARCHIVE
        #
        if [[ 0 -ne $ERROR_CODE ]]
        then
            #
            # I embed the process id of each bash
            # history file in the name of the file. 
            # 
            # If we get here, then the
            # Process that created this history
            # file is not running. So I can archive 
            # the file without yanking the rug out
            # from under a bash shell running on 
            # another console session
            #
            if [ -f $i ]
            then
                #
                # report error if move fails
                #
                mvresult="C38C43B8: "$(mv $i $HISTARCHIVE 2>&1)
                ERROR_CODE=$?
                if [[ 0 -ne $ERROR_CODE ]]
                then
                    if [[ ! -f "$HISTARCHIVE/$(basename $i)" ]]
                    then
                        #
                        # Move Failed
                        #
                        echo $mvresult
                    fi
                fi
            fi
        fi
    done
}

dcaptr()
{
    if [[ $# -gt 0 ]]
    then
        param="$1"
        if [[ -e "$param" ]]
        then
            trimmedparam=$(echo $param|sed -e 's-/$--')
            7z a -spf $(ds).${trimmedparam}.7z $param
        else
            echo "$param not found"
        fi
    else
        echo "capture what?"
    fi
}
alias capture=dcaptr
alias cap=dcaptr
undcaptr()
{
    archive2uncap=$1
    outdir=$(echo $archive2uncap | sed -E 's/(^([0-9]{8}[.][0-9]{6}[.][0-9]{9}))(..*[.]7z$)/\2/')
    if [[ X$archive2uncap != X$outdir ]]
    then
        if [[ ! -d $outdir ]]
        then
            mkdir $outdir
            ERROR_CODE=$?
        fi
        if [[ 0 -eq $ERROR_CODE ]]
        then
            cp $archive2uncap $outdir
            cd $outdir
            ERROR_CODE=$?
            if [[ 0 -eq $ERROR_CODE ]]
            then
                7z x -spf $archive2uncap
                rm $archive2uncap
            fi
        fi
        cd ..
        tree $outdir
    else
        echo "7z archive name must match '^([0-9]{8}[.][0-9]{6}[.][0-9]{9}))(..*[.]7z$)'"
    fi
}
alias uncap=undcaptr
alias uncapture=undcaptr

# Source global definitions
if [ -f /etc/bashrc ]
then
    . /etc/bashrc
elif [ -f /etc/bashrc.bashrc ]
then
    . /etc/bashrc.bashrc
fi

unset SDKMAN_VERSION
unset SDKMAN_LEGACY_API
unset SDKMAN_CURRENT_API
alias gc=cat
alias ttt=screen
alias uuu='sudo -i'
alias uu=sudo
if [[ FreeBSD == $(uname) ]]
then
   if [[ -n $(which gdate) ]]
   then
      alias date=gdate
      alias ls=gls
   else
      echo "======================================"
      echo "***** 'gdate' not found in PATH  *****"
      echo "***** YOU MIGHT NEED TO RUN:     *****"
      echo "*****                            *****"
      echo "***** sudo pkg install coreutils *****"
      echo "*****                            *****"
      echo "***** SO HISTORY IS RECORDED     *****"
      echo "======================================"
   fi
fi
export SDKMANROOT=$HOME/.sdkman
#export JAVA_HOME=/opt/jdk1.8
export CLASSPATH=/opt/idea/lib
export SCALA_HOME=/opt/scala
export GOROOT=/opt/go
export GOPATH=$HOME/00/go
export PROMPT_COMMAND=prompt_command
export SVN_EDITOR=vvv
export dbx=$HOME/Dropbox
export VIMBACKUPDIR=$HOME/.vimbk
export vimversion=vim81
export TEMP=/tmp
for d2check in $dbx $VIMBACKUPDIR
do
    if [ ! -d $d2check ]
    then
        mkdir -p $d2check
    fi
done

if [[ $- == *i* ]]
then
    echo " .bashrc: DISPLAY=$DISPLAY"
    xhost + > /dev/null 2>&1
    instantiate_HISTFILE
    setPS1
else
    : # This shell is not interactive
fi
#
if [ "0" != "$UID" ]
then
    if [ -d /home/nomad/perl5 ]
    then
        export PATH="/home/nomad/perl5/bin${PATH:+:}${PATH}"
        idx=0
        declare -a p5l_item
        p5l_item[$((idx++))]=/home/nomad/perl5/lib/perl5/x86_64-linux
        p5l_item[$((idx++))]=/home/nomad/perl5/lib/perl5
        p5l_item[$((idx++))]=/home/nomad/localperl/lib/site_perl/5.22.0/x86_64-linux
        p5l_item[$((idx++))]=/home/nomad/localperl/lib/site_perl/5.22.0
        p5l_item[$((idx++))]=/home/nomad/localperl/lib/5.22.0/x86_64-linux
        p5l_item[$((idx++))]=/home/nomad/localperl/lib/5.22.0
        for e in ${p5l_item[@]}
        do
            if [[ -d "$e" ]]
            then
                P5LPFX=$P5LPFX${P5LPFX:+:}$e
            fi
        done
        export PERL5LIB="$P5LPFX${PERL5LIB:+:${PERL5LIB}}"
        export PERL_LOCAL_LIB_ROOT="/home/nomad/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
        export PERL_MB_OPT="--install_base \"/home/nomad/perl5\""
        export PERL_MM_OPT="INSTALL_BASE=/home/nomad/perl5"
    fi

    if [[ X1 == X$($HOME/bin/py35vsnok.py) ]]
    then
        export PYTHON35HOME=/usr
    else
        export PYTHON35HOME=/opt/py35
    fi
    pkpath
else
    supath
fi


pathfixup PATH

touch $HOME/.dhist
shopt -s histappend
shopt -s cmdhist
shopt -s no_empty_cmd_completion
if [[ X$USER == Xnomad ]]
then
    export BASHLOGOUT=/home/share/nomad/env4lnx/lnx.bash_logout
    export bashlogout=$BASHLOGOUT

    export PROFILE=/home/share/nomad/env4lnx/lnx.profile
    export profile=$PROFILE
    
    export BASHRC=/home/share/nomad/env4lnx/lnx.bashrc
    export bashrc=$BASHRC
    
    export ANDROID_HOME=$HOME/Android/Sdk
    export android_home=$ANDROID_HOME

    export NDK=$ANDROID_HOME/ndk-bundle
    export ndk=$NDK

    export LOGDIR=/var/log/user
    export logdir=$LOGDIR
fi

export ctoc="/root/00/log/tox/$HOSTNAME.slash.toc.ezn.txt"

if [[ X$USER == Xnomad ]]
then
    #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
    export SDKMAN_DIR=/home/nomad/.sdkman
    SDKINIT=$SDKMANROOT/bin/sdkman-init.sh
    if [[ -s $SDKINIT ]]
    then
    . $SDKINIT
    fi
fi

export BEENTHEREDONETHAT=yup

