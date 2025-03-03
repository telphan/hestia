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
    sketchybar = {
        enable = true;

    	package = pkgs.sketchybar;
    };

    aerospace = {
      enable = true;

      settings = {
        accordion-padding = 4;
	on-window-detected = [
	  {
	    "if" = {
	    	app-id = "company.thebrowser.Browser";
	    };
	    run = "move-node-to-workspace 6";
	  }
          {
	    "if" = {
	    	app-id = "com.tinyspeck.slackmacgap";
	    };
	    run = "move-node-to-workspace 7";
	  }
	  {
	    "if" = {
	    	app-id = "com.linear";
	    };
	    run = "move-node-to-workspace 8";
	  }
          {
	    "if" = {
	    	app-id = "notion.id";
	    };
	    run = "move-node-to-workspace 9";
	  }
          {
	    "if" = {
	    	app-id = "us.zoom.xos";
	    };
	    run = "move-node-to-workspace 0";
	  }
	];
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        workspace-to-monitor-force-assignment = {
          "1" = ["main"];
          "2" = ["secondary" "main"];
        };
	gaps = {
          inner.horizontal = 4;
          inner.vertical = 4;
          outer.left = 4;
          outer.bottom = 4;
          outer.top = 4;
          outer.right = 4;
       };

         
        mode = {
          main = {
            binding = {
              cmd-alt-ctrl-y = "layout tiles horizontal vertical";
              cmd-alt-ctrl-t = "layout accordion horizontal vertical";
              cmd-alt-ctrl-h = "focus left";
              cmd-alt-ctrl-j = "focus down";
              cmd-alt-ctrl-k = "focus up";
              cmd-alt-ctrl-l = "focus right";
              cmd-alt-ctrl-shift-h = "move left";
              cmd-alt-ctrl-shift-j = "move down";
              cmd-alt-ctrl-shift-k = "move up";
              cmd-alt-ctrl-shift-l = "move right";
              cmd-alt-ctrl-minus = "resize smart -100";
              cmd-alt-ctrl-equal = "resize smart +100";
              cmd-alt-ctrl-1 = "workspace 1";
              cmd-alt-ctrl-2 = "workspace 2";
              cmd-alt-ctrl-3 = "workspace 3";
              cmd-alt-ctrl-4 = "workspace 4";
              cmd-alt-ctrl-5 = "workspace 5";
              cmd-alt-ctrl-6 = "workspace 6";
              cmd-alt-ctrl-7 = "workspace 7";
              cmd-alt-ctrl-8 = "workspace 8";
              cmd-alt-ctrl-9 = "workspace 9";
              cmd-alt-ctrl-0 = "workspace 0";
              cmd-alt-ctrl-shift-1 = "move-node-to-workspace 1";
              cmd-alt-ctrl-shift-2 = "move-node-to-workspace 2";
              cmd-alt-ctrl-shift-3 = "move-node-to-workspace 3";
              cmd-alt-ctrl-shift-4 = "move-node-to-workspace 4";
              cmd-alt-ctrl-shift-5 = "move-node-to-workspace 5";
              cmd-alt-ctrl-shift-6 = "move-node-to-workspace 6";
              cmd-alt-ctrl-shift-7 = "move-node-to-workspace 7";
              cmd-alt-ctrl-shift-8 = "move-node-to-workspace 8";
              cmd-alt-ctrl-shift-9 = "move-node-to-workspace 9";
              cmd-alt-ctrl-shift-0 = "move-node-to-workspace 0";
              cmd-alt-ctrl-tab = "workspace-back-and-forth";
              cmd-alt-ctrl-shift-tab = "move-node-to-monitor --wrap-around next";
              cmd-alt-ctrl-shift-semicolon = "mode service";
	      cmd-alt-ctrl-enter = ''exec-and-forget osascript -e '
                tell application "Alacritty"
                do script
                activate
              end tell'
              '';
	      alt-cmd-shift-r = "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --reload && aerospace reload-config";

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

	exec-on-workspace-change = [
          "/bin/zsh"
          "-c"
          "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_changed FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
        ];

	on-focus-changed = [
          "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger front_app_switched"
        ];
      };
    };

    jankyborders = {
      enable = true;
      style = "round";
      width = 3.0;
      hidpi = true;
      active_color = "0xffe2e2e3";
      inactive_color = "0xff414550";
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

    caskArgs = {
      appdir = "~/Applications";
    };

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
      "karabiner-elements"
      "alacritty"
      "1password"
      "docker"
      "spotify"
      "slack"

      "zoom"
      "rapidapi"
      "wkhtmltopdf"

      "dteoh-devdocs"

      # Fonts
      "sf-symbols"
      "font-sf-mono"
      "font-sf-pro"
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

      "switchaudio-osx"
      "nowplaying-cli"
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
	expose-group-apps = true;
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
        _HIHideMenuBar = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
