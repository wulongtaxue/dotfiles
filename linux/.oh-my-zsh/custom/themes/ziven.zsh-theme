function prompt_char {
	if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

. ~/.git-prompt.sh
PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~) %{$fg_bold[red]%}$(__git_ps1 "<%s>")%_%{$fg_bold[yellow]%}$(prompt_char)%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="<"
ZSH_THEME_GIT_PROMPT_SUFFIX="> "


#ziven add for rebind enter key[TO avoid twice <enter> key to execute command]
bindkey -M menuselect '^M' .accept-line
