# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  golang
  colorize
  ng
  colored-man-pages
  cp
  history-substring-search
)

[[ -f ~/.config/lx-zsh/plugins.zsh ]] && source ~/.config/lx-zsh/plugins.zsh

plugins+=(zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' format '%F{blue}zshsense%f %B%F{blue}%d%f%b%F{cyan}>%f'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=8
zstyle ':completion:*' prompt '%F{blue}zshsense%f %B%F{blue}%e%f%b%F{cyan}>%f'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep
bindkey -v

if type exa &> /dev/null; then
  alias ls='exa'
  alias l.='exa -a'
  alias l='exa -a'
  alias ll='exa -la --git'
  alias tree='exa --tree --level=5'
  alias tree.='exa -a --tree --level=8 --git-ignore'
fi

alias grep='grep --color=auto'
alias gist='git status -s'

# History substring search
HISTORY_SUBSTRING_SEARCH_FUZZY=1
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

ZLE_RPROMPT_INDENT=0

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="${PATH}:/home/sewera/.cargo/bin/navi"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--height=16 --layout=reverse"

eval "$(navi widget zsh)"
