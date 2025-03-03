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
              alt-4 = "workspace 4";
              alt-5 = "workspace 5";
              alt-6 = "workspace 6";
              alt-7 = "workspace 7";
              alt-8 = "workspace 8";
              alt-9 = "workspace 9";
              alt-0 = "workspace 0";
              alt-shift-1 = "move-node-to-workspace 1";
              alt-shift-2 = "move-node-to-workspace 2";
              alt-shift-3 = "move-node-to-workspace 3";
              alt-shift-4 = "move-node-to-workspace 4";
              alt-shift-5 = "move-node-to-workspace 5";
              alt-shift-6 = "move-node-to-workspace 6";
              alt-shift-7 = "move-node-to-workspace 7";
              alt-shift-8 = "move-node-to-workspace 8";
              alt-shift-9 = "move-node-to-workspace 9";
              alt-shift-0 = "move-node-to-workspace 0";
              alt-tab = "workspace-back-and-forth";
              alt-shift-tab = "move-node-to-monitor --wrap-around next";
              alt-shift-semicolon = "mode service";
	      alt-enter = ''exec-and-forget osascript -e \'
                tell application "Alacritty"
                do script
                activate
              end tell\'
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
