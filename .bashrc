# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
alias la='ls -A'
alias l='ls -hAlF'
alias n='/bin/rm -v *~'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'

# Set my PATH
export PATH=".:$PATH:/usr/sbin:/sbin"

# Customize my stuff
export HISTSIZE=5120
export HISTFILESIZE=5120
export HISTCONTROL=erasedups
export MBOX="$HOME/Mail/mbox"
# Display a startup message
echo ""
echo "Welcome back, $USER"
hour=`date +%H`
if [ $hour -lt 12 ]
then
    echo "Good morning!"
elif [ $hour -ge 12 -a $hour -le 18 ]
then
    echo "Good afternoon!"
else
    echo "Good evening!"
fi
echo ""
test -s /var/mail/$USER && echo "You have mail" || echo "No unread mail"
echo ""
fortune -a computers linux science gentoo-forums gentoo-dev perl tao kernelcookies
echo ""
PROMPT_COMMAND='DIR=`pwd|sed -e "s!$HOME!~!"`; if [ ${#DIR} -gt 20 ]; then CurDir=${DIR:0:12}...${DIR:${#DIR}-15}; else CurDir=$DIR; fi'
export PS1="\[\033[01;34m\]\$CurDir \[\033[01;32m\]:) \[\033[00m\]"
