{ pkgs, lib, ... }:
let
        llm-nvim = import ./modules/llm.nix { inherit pkgs; };
in {
        vim.startPlugins = [
                llm-nvim
                ];
        vim.extraPlugins = {
                llm-nvim = {
                        package = llm-nvim;
                        setup = ''
                                llm = require("llm")
                                local tools = require("llm.tools")
                                llm.setup({
                                        api_type = "openai",
                                        url = "https://your_web_ui_server_domain.com/api/chat/completions",
                                        fetch_key = "your_api_key",
                                        model = "gemma3:latest",
                                })

                                vim.keymap.set("n", "<leader>ac", ":LLMSessionToggle<cr>")
                        '';
                };
        };
	vim = {
                vimAlias = true;
		theme = {
			enable = true;
			name = "gruvbox";
			style = "dark";
		};
                lsp = {
                        enable = true;
                        servers = {
                                # Nix LSP
                                nixd = {
                                        enable = true;
                                        filetypes = [ "nix" ];
                                        cmd = [ "nixd" ];
                                        root_markers = [ "flake.nix" "configuration.nix" ];
                                };
                                # Rust LSP
                                rust_analyzer = {
                                        enable = true;
                                        filetypes = [ "rust" ];
                                        cmd = [ "rust-analyzer" ];
                                        root_markers = [ "Cargo.toml" ];
                                };
                                # Python LSP
                                pyright = {
                                        enable = true;
                                        filetypes = [ "python" ];
                                        cmd = [ "pyright-langserver" "--stdio" ];
                                        root_markers = [ "pyproject.toml" "setup.py" "requirements.txt" ];
                                };
                                # Markdown LSP
                                marksman = {
                                        enable = true;
                                        filetypes = [ "markdown" ];
                                        cmd = [ "marksman" "server" ];
                                        root_markers = [ ".git" ];
                                };
                        };
                };
                treesitter = {
                        enable = true;
                        grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
                                nix
                                rust
                                python
                                markdown
                        ];
                        highlight.enable = true;
                        fold = true;
                };
		statusline.lualine.enable = true;
                telescope.enable = true;
                notes.neorg.enable = true;
		autocomplete.nvim-cmp.enable = true;
	};
}
