{ pkgs }:

let
  inherit (pkgs) vimUtils fetchFromGitHub lib;
in
    pkgs.vimUtils.buildVimPlugin rec {
    # 1. Package Identification
    pname = "llm-nvim";
    # Using an unstable tag since the repo doesn't have official releases/tags
    version = "unstable-2024-11-03"; 

    # 2. Source Code Definition
    src = fetchFromGitHub {
      owner = "Kurama622";
      repo = "llm.nvim";
      
      # Use a specific, recent commit hash for guaranteed reproducibility
      rev = "0462479e85a16807b937104fbe30f9ad1f454253"; 

      # **PLACEHOLDER SHA256:** You must replace this.
      # Run 'nix-build <this_file>' and use the 'got:' hash that the error message provides.
      sha256 = "sha256-QccvzQucVib8Xv81k1dvxms9bAzr4WUaWNwPokbN2HQ=";
    };
    
    # 4. Dependencies (Optional)
    buildInputs = [ pkgs.vimPlugins.plenary-nvim ];

    doCheck = false;
  }
