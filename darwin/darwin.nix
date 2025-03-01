{ pkgs, lib, ... }: 

{
  nix.enable = false;

  system.stateVersion = 4;

  environment = {
    darwinConfig = "$HOME/repos/hestia/darwin";
    systemPackages = with pkgs; [
      docker-compose
      cachix
    ];
    shells = [ pkgs.zsh ];
  };

  security = {
    pam = {
      services.sudo_local.touchIdAuth = true;
    };
  };

  services = {
    aerospace = {
      enable = true;

      settings = {
        accordion-padding = 0;
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        workspace-to-monitor-force-assignment = {
          "1" = ["main"];
          "2" = ["secondary" "main"];
        };
        mode = {
          main = {
            binding = {
              alt-y = "layout tiles horizontal vertical";
              alt-t = "layout accordion horizontal vertical";
              alt-h = "focus left";
              alt-j = "focus down";
              alt-k = "focus up";
              alt-l = "focus right";
              alt-shift-h = "move left";
              alt-shift-j = "move down";
              alt-shift-k = "move up";
              alt-shift-l = "move right";
              alt-ctrl-h = "join-with left";
              alt-ctrl-j = "join-with down";
              alt-ctrl-k = "join-with up";
              alt-ctrl-l = "join-with right";
              alt-minus = "resize smart -100";
              alt-equal = "resize smart +100";
              alt-1 = "workspace 1";
              alt-2 = "workspace 2";
              alt-3 = "workspace 3";
              alt-shift-1 = "move-node-to-workspace 1";
              alt-shift-2 = "move-node-to-workspace 2";
              alt-shift-3 = "move-node-to-workspace 3";
              alt-tab = "workspace-back-and-forth";
              alt-shift-tab = "move-node-to-monitor --wrap-around next";
              alt-shift-semicolon = "mode service";
            };
          };
          service = {
            binding = {
              esc = [ "reload-config" "mode main" ];
              r = [ "flatten-workspace-tree" "mode main" ];
              f = [ "layout floating tiling" "mode main" ];
              backspace = [ "close-all-windows-but-current" "mode main" ];
            };
          };
        };
      };
    };

    jankyborders = {
      enable = true;
      blur_radius = 5.0;
      hidpi = true;
      active_color = "0xAAB279A7";
      inactive_color = "0x33867A74";
    };
  };

  programs = {
    gnupg.agent.enable = true;
    zsh  = {
      enable = true;  # default shell on catalina
    };
  };

  fonts.packages = [
    pkgs.atkinson-hyperlegible
    pkgs.jetbrains-mono
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);


  homebrew = {
    enable = true;

    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';

    brewPrefix = "/opt/homebrew/bin";

    global = {
      brewfile =  true;
    };

    onActivation = {
      upgrade = true;
      cleanup = "zap";
      autoUpdate = true;
    };

    taps = [
      "homebrew/services"
    ];

    casks = [
      "alacritty"
      "1password"
      "docker"
      "spotify"
      "slack"

      "zoom"
      "rapidapi"
      "wkhtmltopdf"

      "dteoh-devdocs"
    ];

    brews = [
      "nodejs"
      "erlang"
      "openjdk"
      "java"
      "elixir"
      "coreutils"
      "asdf"
      "macos-term-size"
      "node"
      "xz"
      "yarn"
    ];

    masApps = {
    };
  };

  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        showhidden = true;
        mineffect = "genie";
        launchanim = true;
        show-process-indicators = true;
        tilesize = 48;
        static-only = true;
        mru-spaces = false;
        show-recents = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        CreateDesktop = false; # disable desktop icons
	ShowPathbar = true;

      };
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
        Dragging = true;
      };
      # Apple firewall config:
      alf = {
        globalstate = 2;
        loggingenabled = 0;
        stealthenabled = 1;
      };
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark"; # set dark mode
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = false;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
