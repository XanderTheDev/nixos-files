{ username, inputs, config, pkgs, lib, ... }:

with inputs;
with lib;
with config.stylix.fonts; let
   colors = config.lib.stylix.colors.withHashtag;
in {

  # All config files and programs for zsh
  home.file = {
    ".zshrc".text = ''
	export TERM=foot

	if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    		macchina -o host -o distribution -o desktop-environment -o shell -o resolution -o uptime
	fi
	
	parse_git_branch () {
    		git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
	}

	function git_prompt () {
    	local OUT=
    	local GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

    	if [[ -n $GIT_ROOT ]]
    		then
        		OUT="  $(basename $GIT_ROOT)"
        		local GIT_BRANCH="$(parse_git_branch)"
        		if [[ "$GIT_BRANCH" == " ((no branch))" ]]
        		then
            			GIT_BRANCH="($(parse_git_branch))";
        		fi
        	OUT="$OUT $GIT_BRANCH"
    	fi
    	echo $OUT
	}	
	setopt PROMPT_SUBST
        
	PROMPT='%F{red}%f%b%K{red}%F{white}  %f%K{yellow}%F{red}%f%k%b%K{yellow}%F{white}%B%n@%m - %* - %D{%F} %f%k%F{yellow}%f
%F{red}%~ %f%F{white}$(git_prompt) %f%F{red}$ %f%b'

	alias cp='cp -i'
	alias mv='mv -i'
	alias ls='eza -G --icons -a --git-ignore'
	alias rm='trash'
	alias mkdir='mkdir -p'
	alias cat='$HOME/.config/cat'
        alias nerdfont-icon-picker='$HOME/.config/nerdfont-icon-picker'
	alias svim='sudo vim'
	alias nrb='sudo nixos-rebuild switch --flake'
        alias nvf-rebuild='nix profile upgrade nvf'
	alias thorium-browser='distrobox enter arch -- thorium-browser "$@"'
	
	alias ..='cd ..'
	alias ...='cd ../..'
	alias ....='cd ../../..'
	alias .....='cd ../../../..'
	
	cd ()
	{	
	if [ -n "$1" ]; then
		builtin cd "$@" && ls
	else
		builtin cd ~ && ls
	fi
	}
	
	source $HOME/.config/fzf_binds.zsh

	# Source fast-syntax-highlighting 
	source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

	# Source zsh-autosuggestions
	source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        if ! pgrep -u "$USER" ssh-agent > /dev/null; then
                eval "$(ssh-agent -s)"
        fi

        ssh-add ~/.ssh/id_rsa
    '';
    ".config/cat".text = ''
	#!/bin/bash

	read -p "Use bat? [Y/n] " x
	if [[ "$x" =~ ^([nN]|no|NO)$ ]]; then
  		cat "$@"
	else
  		bat "$@"
	fi
    '';
    ".config/cat".executable = true;
    ".config/fzf_binds.zsh".source = ../fzf/fzf_binds.zsh;
  };
}
