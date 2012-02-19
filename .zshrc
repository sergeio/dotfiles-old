setopt ALL_EXPORT

# Set/unset  shell options
setopt   notify globdots pushdtohome cdablevars autolist
setopt   recexact longlistjobs
setopt   autoresume histignoredups pushdsilent
setopt   autopushd pushdminus extendedglob rcquotes mailwarning
unsetopt bgnice autoparamslash

unsetopt Correct 2>/dev/null

#Bash-like tab-completion
setopt bash_autolist

# History
export HISTCONTROL="erasedups:ignoreboth"
setopt INC_APPEND_HISTORY SHARE_HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY     # puts timestamps in the history
TZ="America/New_York"
stty stop ""
setopt histappend
HISTFILE=$HOME/.zhistory
HISTSIZE=50000
HISTFILESIZE=500000
SAVEHIST=10000
HOSTNAME="`hostname`"

PAGER='less'
EDITOR='vim'
bindkey -e
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    #   eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_$color='%{$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"

show(){
    # download and open image that matches args
    args=$*
    ((curl -q ${args// /%20}.jpg.to 2>/dev/null |
    sed -e 's/<img src="//' -e 's/" \/>//' |
    xargs wget -q -O $TMPDIR/${args// /_}.jpg &&
        open $TMPDIR/${args// /_}.jpg) &)
}

check_git_status() {
    local ST
    ST=$(git status 2> /dev/null)
    if [[ $? != 0 ]] then
        return
    fi
    echo $ST | grep '^nothing to commit' 1> /dev/null
    if [[ $? == 1 ]] then
        echo "$PR_RED+$PR_NO_COLOR"
    fi
}

parse_git_branch() {
    git branch --no-color 2> /dev/null \
    | sed -e '/^  /d' -e 's/* \(.*\)/\1/'
}

get_exit_code_color() {
    if [[ $? != 0 ]] then
        COLOR=$PROMPT_ERROR
    else
        COLOR=$PROMPT_COLOR
    fi
    echo $COLOR
}

setopt prompt_subst
PROMPT_COLOR=$PR_GREEN
PROMPT_ERROR=$PR_RED

# Fix C-w delimiter:
autoload -U select-word-style
select-word-style bash


# PS1/RPS1 need to be single-quoted so that variables
# are evaluated by prompt_subst, after every command

PS1='$(get_exit_code_color)%2c$PR_NO_COLOR%(!.#.$) '
RPS1='$(check_git_status) $(parse_git_branch)'

# Sets the tab and window titles to the current directory
precmd  () { print -Pn "\e]0;%1c\a" }
preexec () { print -Pn "\e]0;%1c\a" }

unsetopt ALL_EXPORT

autoload -U compinit
compinit
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey "^r" history-incremental-search-backward
bindkey '^I' complete-word # complete on tab, leave expansion to _expand
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored
# zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Completion Styles

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

## add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

zstyle ':completion:*:processes' command 'ps ax -o pid,s,nice,stime,args | sed "/ps/d"'
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' command 'ps axho command' 


# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm apache bin daemon games gdm halt ident junkbust lp mail mailnull \
        named news nfsnobody nobody nscd ntp operator pcap postgres radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs avahi-autoipd\
        avahi backup messagebus beagleindex debian-tor dhcp dnsmasq fetchmail\
        firebird gnats haldaemon hplip irc klog list man cupsys postfix\
        proxy syslog www-data mldonkey sys snort
# SSH Completion

source ~/.bash_aliases
source ~/code/bk/bk.zsh

PATH=/opt/local/bin:/usr/local/bin:~/bin:/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin:$PATH
export PATH

export WORKON_HOME=~/repos/envs
export VIRTUALENVWRAPPER_LOG_DIR="$WORKON_HOME"
export VIRTUALENVWRAPPER_HOOK_DIR="$WORKON_HOME"

source /opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/virtualenvwrapper.sh
# export PATH="/bin:/sbin:/usr/bin:/usr/sbin:$PATH"

# Start tmux automatically
[[ $TERM != "screen" ]] && tmux && exit
