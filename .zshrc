# My .zshrc

# History stuff
export HISTSIZE=5000
export SAVEHIST=5000
export HISTFILE=~/.zhistory
setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Searching history using existing words typed
function history-search-end {
integer ocursor=$CURSOR
if [[ $LASTWIDGET = history-beginning-search-*-end ]]; then
  CURSOR=$hbs_pos
else
  hbs_pos=$CURSOR
fi
if zle .${WIDGET%-end}; then
  zle .end-of-line
else
  CURSOR=$ocursor
  return 1
fi
}
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# Set some cool options
setopt autocd
setopt extendedglob
setopt correctall
eval `dircolors -b`

# List newest files
function lsnew () {
if [[ $1 = "" ]]; then
  lsnew_glob="*"
else
  lsnew_glob=$1
fi
ls --color=auto -tr -dl $~lsnew_glob(om[1,30])
}

# Fix key bindings
bindkey "\eOH" beginning-of-line
bindkey "\e[1~" beginning-of-line
bindkey "\e[7~" beginning-of-line
bindkey "\eOF" end-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[8~" end-of-line
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[A" history-beginning-search-backward-end
bindkey "\e[B" history-beginning-search-forward-end
bindkey "\e[5~" history-incremental-search-backward
bindkey "\e[6~" history-incremental-search-backward

# Completion
autoload -U compinit
compinit
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*' menu select
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*' squeeze-slashes false
zstyle ':completion:*:cd:*' ignore-parents parent pwd
rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

# Completion for PID
zstyle ':completion:*:processes-names' command 'ps -e -o comm='
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu select=1 _complete _ignored _approximate

# Update term title with directory name
chpwd() {
  [[ -t 1 ]] || return
  case $TERM in
    sun-cmd) print -Pn "\e]l%~\e\\"
    ;;
    *xterm*|*rxvt*|(dt|k|E)term) print -Pn "\e]2;%~\a"
    ;;
  esac
}

# Useful aliases
alias ls='ls --color=auto'
alias lsnew='noglob lsnew'
alias grep='grep --colour=auto'
alias l='ls -hAlF'
alias ll='ls -l'
alias la='ls -A'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias n='/bin/rm -v *~'

# Cool suffix aliases
alias -s c=p
alias -s cpp=p
alias -s java=p
alias -s avi=mplayer
alias -s mp3=mplayer

# Global aliases
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'

# Prompts
autoload -U promptinit
promptinit
prompt clint

# Display a startup message
echo ""
echo "\033[01;32mWelcome back, \033[01;36m$USER\033[01;35m"
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
#test -s /var/mail/$USER && echo "You have mail" || echo "No unread mail"
mailcount=`find ~/Mail/Gmail/INBOX/new -type f | wc -l`
test $mailcount -eq 0 && echo "\033[01;33mNo unread mail" || echo "\033[01;31mYou have mail"
echo "\033[01;37m"
fortune -a computers linux science gentoo-forums gentoo-dev perl tao kernelcookies
echo ""

# Set my $PATH and $PS1
export PATH=".:$PATH:/usr/sbin:/sbin"
export PS1="$PS1%B"
