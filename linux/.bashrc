#java environment
#JAVA_HOME=/home/android/jdk1.6.0_29
#JAVA_HOME=/opt/java/jdk1.6.0_45
JAVA_HOME=/opt/jdk1.6.0_45
JRE_HOME=${JAVA_HOME}/jre
export ANDROID_JAVA_HOME=$JAVA_HOME
export CLASSPATH=.:${JAVA_HOME}/lib:$JRE_HOME/lib:$CLASSPATH
export JAVA_PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin
export JAVA_HOME;
export JRE_HOME;
export CLASSPATH;
#export ANDROID_ADB_PATH=/home/android/android-sdks/platform-tools
#export ANDROID_PRODUCT_OUT=/home/android/mount/4.0/WORKING_DIRECTORY/out/target/product/generic
#ANDROID_PRODUCT_OUT_BIN=/home/android/mount/4.0/WORKING_DIRECTORY/out/host/linux-x86/bin
HOME_BIN=~/bin/
ARM_EABI_BIN=${HOME_BIN}/arm-eabi-4.4.3/bin
export PATH=${ARM_EABI_BIN}:${PATH}:${JAVA_PATH}:${HOME_BIN}
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# # don't put duplicate lines in the history. See bash(1) for more options
# # ... or force ignoredups and ignorespace
# HISTCONTROL=ignoredups:ignorespace

# # append to the history file, don't overwrite it
# shopt -s histappend

# # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# HISTSIZE=1000
# HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# if [ "$color_prompt" = yes ]; then
    # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
    # PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
	PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
	;;
*)
	;;
esac


#ziven customize PS1
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#ziven customize terminal title
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}:${PWD/$HOME/~}\007" ; $PROMPT_COMMAND'
# echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b ~/.dircolors)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

#ziven add some aliases
alias sh54='ssh android@10.130.10.54 -p 222'
alias sh22='ssh android@10.130.10.22 -p 222'
alias sh199='ssh android@10.130.10.199 -p 222'
alias sh154='ssh android@10.130.8.154 -p 222'
alias sh170='ssh android@10.130.8.170 -p 222'
alias sh167='ssh android@10.130.8.167 -p 222'
alias sh200='ssh android@10.130.10.200 -p 222'
alias sh86='ssh android@10.130.10.86 -p 222'
alias cl='clear'
alias scp='scp -F ~/.ssh/config'
alias mscp='scp -F ~/.ssh/config -P 222'
alias pat='patch -p1 < '
alias logf='grep -HrnE "FATAL" -A 20 -B 5'
## get rid of command not found ##
alias cd..='cd ..'
## a quick way to get out of current directory ##
# alias -- -='cd -'
alias ..='cd ../' #up to parent
alias ...='cd ../../' #up to parent's parent
alias ....='cd ../../../' #up 3 dirs
alias .....='cd ../../../../' #up 4 dirs
alias ......='cd ../../../../../' #up 5 dirs
alias .......='cd ../../../../../../' #up 6 dirs
alias ........='cd ../../../../../../../' #up 7 dirs
alias .........='cd ../../../../../../../../' #up 8 dirs
alias ..........='cd ../../../../../../../../../' #up 9 dirs
alias ...........='cd ../../../../../../../../../../' #up 10 dirs
alias .1='cd ../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
alias .7='cd ../../../../../../../'
alias .8='cd ../../../../../../../../'
alias .9='cd ../../../../../../../../../' #up 9 dirs
alias .0='cd ../../../../../../../../../../' #up 10 dirs

alias h='history'
alias r.='source ~/.bashrc' #reload bashrc (because '.' is similar to 'source',so we use '.' to recommend 'source')

alias wl='wc -l'


#for mtp
alias android-mtp-connect="mtpfs -o allow_other /media/mtp"
alias android-mtp-disconnect="fusermount -u /media/mtp"
#for phones
alias dadb='adb -s 0123456789ABCDEF' #default device for adb

#some useful functions
mkcd(){
if [ "$1" ];then
	mkdir -p "$1"
	cd "$1"
fi
}
#==============================
#####functions for echo color begin
#red: echo red for errors.
#yellow: echo yellow for warnnings.
#green: echo green for success.
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
 
function red() {
    echo -e "$RED$*$NORMAL"
}
 
function green() {
    echo -e "$GREEN$*$NORMAL"
}
 
function yellow() {
    echo -e "$YELLOW$*$NORMAL"
}

#####functions for echo color end
#==============================
#some useful environment variables
# export CDPATH=".:$HOME/source:$HOME/backup:$HOME/temp"
#MIPS Toolchain
export PATH=/opt/mips-4.3/bin:$PATH:/home/android/tools/tools

#ziven add android-sdk path
ANDROID_SDK_HOME=/home/android/android/android-sdks
ANDROID_TOOLS=${ANDROID_SDK_HOME}/tools
ANDROID_PLATFORMTOOLS=${ANDROID_SDK_HOME}/platform-tools
#added by ziven 20130402 for android home
export ANDROID_HOME=/home/android/android-sdks
export PATH=${PATH}:${ANDROID_TOOLS}:${ANDROID_PLATFORMTOOLS}

# export PATH=${PATH}:/home/android/tools/tools/dex2jar:/home/android/tools/tools/jd-gui
# export PATH=${PATH}:/home/android/tools/droiddraw

#some variables defined by ziven for work-projects at 20121011
export MT6517=ssh://android@10.130.10.86:222/home/android/sw/mtk/MT6517/alps-v1.20
export MT6577=ssh://android@10.130.10.86:222/home/android/sw/mtk/MT6577/sw-1.00
export I700=ssh://android@10.130.10.86:222/home/android/sw/mtk/I700/sw-1.10
export W856=ssh://android@10.130.10.86:222/home/android/sw/mtk/MT6589/W856/sw-1.2
export w856=/home/android/source/W856

#some dirs I go frequently (add by ziven at 20121011)
export e700=/home/android/source/mt6517
#export PYTHONPATH=.
#ziven add path for android studio
export PATH=${PATH}:/home/android/android_studio/bin
#ziven add for apktool
# export PATH=${PATH}:/home/android/tools/tools/apktool
#ziven add for hackapk 20131016
# export PATH=${PATH}:/home/android/tools/tools/hackapk
export PATH=${PATH}:/home/android/tools/apkDecompile:/home/android/tools/apkDecompile/apktool/:/home/android/tools/apkDecompile/dex2jar/:/home/android/tools/apkDecompile/jd-gui

#ziven add for bash history at 20130620
#ignore duplicate history(means save uniquely)
#export HISTCONTROL=ignoredups
export HISTCONTROL=erasedups:ignoredups:ignorespace
#ignore these commands(seperated by colon)
export HISTIGNORE="[ ]*:&:bg:fg:exit"
#history file size(10^6 lines)
export HISTFILESIZE=1000000
#max history commands numbers(10^6)
export HISTSIZE=1000000
#append to instead of overwrite
shopt -s histappend
#append commands to history immediately after every command's done('cause when command's done,we prompt our PROMPT_COMMAND,so we addit here)
PROMPT_COMMAND="history -a ; $PROMPT_COMMAND"

#when complete,DONOT ignore the case
bind 'set completion-ignore-case off'

#set default editor
export EDITOR=/usr/bin/vim

#ziven add for git prompt
# source ~/.git-prompt.sh
# source ~/.git-completion.bash
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\033[01;35m\]$(__git_ps1 "<%s>")\[\033[00m\]\$ '


#ziven disable gedit 20130729
#alias gedit="vim"

#ziven add for z.sh(z) at 20130827
source ~/.bash/z.sh
