[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -d /usr/share/fzf ]] && source /usr/share/fzf/completion.zsh && source /usr/share/fzf/key-bindings.zsh

# Tmux plugin configuration
ZSH_TMUX_FIXTERM=true
ZSH_TMUX_UNICODE=true

# zsh parameter completion for the dotnet CLI
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  reply=( "${(ps:\n:)completions}" )
}

compctl -K _dotnet_zsh_complete dotnet

