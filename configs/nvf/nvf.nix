{ pkgs, lib, ... }:

{
	vim = {
                vimAlias = true;
		theme = {
			enable = true;
			name = "gruvbox";
			style = "dark";
		};
		languages = {
			enableTreesitter = true;
			nix.enable = true;
			markdown.enable = true;
		};
                lsp.enable = true;
		statusline.lualine.enable = true;
                telescope.enable = true;
                notes.neorg.enable = true;
		autocomplete.nvim-cmp.enable = true;
	};
}
