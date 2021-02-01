##########################
# Key bindings
#########################

# Use Vi(m) style key bindings.
bindkey -v

########
# Prompt
########

# Try to be aware of the color spectrum of the terminal
[[ "$COLORTERM" == (24bit|truecolor) || "${terminfo[colors]}" -eq '16777216' ]] || zmodload zsh/nearcolor

autoload -Uz colors && colors

autoload -Uz promptsubst
autoload -Uz promptinit && promptinit

autoload -Uz vcs_info

# Define the theme
prompt_mytheme_setup() {

	local user
	if [[ $USER == "root" ]] then
		user="%F{9}%n"
	else
		user="%F{12}%n"
	fi

	if [[ ! -z $SSH_CLIENT ]] then
		user="%F{3}SSH -> $user"
	fi

	# Information about version control systems
	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:*' check-for-changes yes
	zstyle ':vcs_info:*' use-prompt-escapes yes
	zstyle ':vcs_info:*' formats "%s - (%r|%b)" "%u%c"

	local prefix="%(?..[%?%1v] )"
	local vcs="%(2v.%U%2v%u.)"

	PROMPT="%K{0}%F{9}$prefix%f%B$user@%M%f %F{7}%/%b%f%k
%B#%b %E"
	RPROMPT="%K{0}%F{9}$vcs%f%k"

	add-zsh-hook precmd prompt_mytheme_precmd
}

prompt_mytheme_precmd () {
  setopt noxtrace noksharrays localoptions
  local exitstatus=$?
  local git_dir git_ref

  psvar=()
  [[ $exitstatus -ge 128 ]] && psvar[1]=" $signals[$exitstatus-127]" || psvar[1]=""

  vcs_info
  [[ -n $vcs_info_msg_0_ ]] && psvar[2]="$vcs_info_msg_0_"
}

# Add the theme to promptsys
prompt_themes+=( mytheme )

# Load the theme
prompt mytheme


#########
# OPTIONS
#########

# Disable beeps.
setopt nobeep

# Entering the name of a directory (if it's not a command) will automatically
# cd to that directory.
setopt autocd

# Prevent overwriting existing files with '> filename', use '>| filename'
# (or >!) instead.
setopt noclobber

# Enable zsh's extended glob abilities.
setopt extendedglob

# Also display PID when suspending a process.
setopt longlistjobs


############
# Completion
############
#
## Initialize completion
autoload -Uz compinit && compinit

# Automatically list choices on an ambiguous completion.
setopt autolist


## show list of tab-completing options
zstyle ':completion:*:default' list-prompt '%p'

## cache completion for re-use (path must exist)
zstyle ':completion:*' use-cache yes; zstyle ':completion:*' cache-path

## _complete    -> completiong
## _expand      -> expand variables
## _prefix      -> ignore everything behind cursor
## _approximate -> fuzzy completion
## _ignore      -> ignore some matches (i.e. directories when doing cd)
zstyle ':completion:::::' completer  _expand _complete _prefix _ignored _approximate

## one wrong character every X characters is corrected
## X = 5 is a reasonable default
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 5 )) )'

## correct lowercase to uppercase
zstyle ':completion:*:(^approximate):*' matcher-list 'm:{a-z}={A-Z}' # Kleinschreibung automatisch zu Großschreibung korrigieren.

## keep magic prefixes like '~' when expanding
zstyle ':completion:*:expand:*' keep-prefix yes #halt praefix behalten, HOME nicht zu cip/home blablabla expandierekn

## compelte a/b/c<tab> zu abc/bcd/coo
zstyle ':completion:*' list-suffixes yes

## colors in completion menu ##
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# allow autocomplete-navigation with arrowkeys
zstyle ':completion:*' menu select #enable a menu which can be browsed with arrow keys

# tab completion after pressing tab once (default is twice)
setopt nolistambiguous

# allow in word completion
setopt completeinword

#########
# History
#########

# write command to historyfile imediatelly
setopt appendhistory
setopt incappendhistory

## max size and location of history-savefile
STSIZE=20000
SAVEHIST=20000

if [[ ! -a ~/logs ]] {
	mkdir ~/logs
}
HISTFILE=~/logs/zshhistory.log

## no duplicated commands
setopt histignoredups

## no emptylines
setopt histignorespace

# Fancy search for history. Install peco
if ! [ -x "$(command -v peco)" ]; then
    bindkey '^R' history-incremental-pattern-search-backward
else
    ## bind peco to ctrl-R as a better reverse search than the buitin if it is available
    reverse_search(){print -z "$(tac ${HISTFILE} | peco)"}
    zle -N rs_peco reverse_search
    bindkey "^R" rs_peco
    PECO=/usr/bin/
fi


######
# Misc
######

# UMASK
umask 077

## Color scheme for ls ##
LS_COLORS=$LS_COLORS:'di=0;35:'; export LS_COLORS


# Aliases
if [[ -f ~/.config/zsh/aliases ]]; then
	source ~/.config/zsh/aliases
fi

# Select editor
export EDITOR=nvim

# Make local scripts available
if [[ -d ~/scripts ]] {
	export PATH=$PATH:~/scripts
}

# Make local binaries available
if [[ -d ~/.local/bin ]] {
	export PATH=$PATH:~/.local/bin
}

# Colored manuals
man() {
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}
