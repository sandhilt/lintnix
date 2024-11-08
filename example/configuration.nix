# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  unstable = import <nixos-unstable> {
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        # Packages
        "vscode"
      ];
  };
in
{
  disabledModules = [
    #   "category/path/to/file.nix"
  ];
  imports = [
    # Include the results of the hardware scan.
    # ./hardware-configuration.nix
    /etc/nixos/hardware-configuration.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    operation = "boot";
  };

  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.initrd.systemd.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    autoPrune = {
      flags = [ "--volumes" ];
      enable = true;
      dates = "daily";
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
    };
  };
  fileSystems = {
    "/".options = [
      "compress=zstd"
      "autodefrag"
    ];
    "/home".options = [
      "compress=zstd"
      "autodefrag"
    ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
      "autodefrag"
    ];
  };
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  zramSwap.enable = true;
  systemd.oomd.enable = true;
  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";
  services.ntp.enable = true;
  networking.timeServers = options.networking.timeServers.default ++ [ "pool.ntp.br" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";
  console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xrandrHeads = [
      {
        output = "HDMI-1";
        monitorConfig = "Option \"Above\" \"eDP-1\"";
      }
      {
        output = "eDP-1";
        primary = true;
      }
    ];
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  services.xserver.xkb.layout = "br";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libglvnd ];
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
        Experimental = true;
        DiscoverableTimeout = 0;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };
  # Enable sound.
  hardware.pulseaudio.enable = false;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };
  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "github-copilot-cli"
      "google-chrome"
      "slack"
      "spotify"
      "discord"
      "steam"
      "steam-original"
      #"nvidia-x11"
      #"nvidia-settings"
      "vscode"
    ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "tmux-256color";
    keyMode = "vi";
  };
  programs.appimage = {
    binfmt = true;
    enable = true;
  };

  programs.gamemode.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.mouse.naturalScrolling = true;

  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sandhilt = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
      "libvirtd"
      "video"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      killall
      wl-clipboard
      lshw
      nixfmt-rfc-style
      pgcli
      tcpdump
      graphviz
      mesa
      openjdk21
      authenticator
      bitwarden
      sof-firmware
      dialect
      tlrc
      ruby
      stow
      watchexec
      fswatch
      rsync
      lazygit
      rustup
      unstable.cargo-binstall
      starship
      act
      docker-buildx
      docker-compose
      gh
      github-copilot-cli
      vscode
      ventoy
      google-chrome
      nwjs
      zoxide
      eza
      wezterm
      aria
      bat
      du-dust
      xdotool
      diskonaut
      netcat-gnu
      dnsutils
      nmap
      ani-cli
      inetutils
      tshark
      conky
      cava
      yazi
      nodejs_22
      slack
      spotify
      discord
      vesktop
      fd
      fzf
      gnumake
      go
      tuba
      openshot-qt
      delve # Golang debug
      golangci-lint
      fastfetch
      sqlite
      jq
      yq-go
      httpie
      curl
      unzip
      p7zip
      ripgrep
      streamlink
      yt-dlp
      gimp
      inkscape
      gnome.gnome-boxes
      newsflash
      gnome-secrets
      libreoffice
      telegram-desktop
      foliate
      transmission_4-gtk
      python3
      lua51Packages.lua
      steam
      heroic-unwrapped
      mangohud
      bottles
      metadata-cleaner
      cartridges
      komikku
      collision
      gnome-obfuscate
      wl-clipboard
      bruno
      health
      chatterino2
      # gnome-frog
      gnome.dconf-editor
      gnome-decoder
      kooha
      ffmpeg
      imagemagick
      mpv
      mpvScripts.mpris
      gnome.gnome-tweaks
      python312Packages.pip
      speedtest-cli
      lightspark
    ];
  };

  programs.direnv.enable = true;
  nixpkgs.overlays = [
    # (import (builtins.fetchTarball {
    #   url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    # }))
    (self: super: { mpv = super.mpv.override { scripts = [ self.mpvScripts.mpris ]; }; })
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    package = unstable.neovim-unwrapped;
  };
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "pt-BR" ];
      preferences = {
        "toolkit.tabbox.switchByScrolling" = true;
      };
    };
  };
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    syntaxHighlighting.enable = true;
    vteIntegration = true;
    ohMyZsh = {
      enable = true;
      # theme = "agnoster";
      # plugins = ["git"  "aliases" "colored-man-pages" "rust" "vscode" "httpie" "tmux" "fd" "fzf" "sudo" "gh" "starship" "safe-paste" "zoxide" "volta" "direnv" "golang"];
    };
  };
  programs.starship = {
    enable = true;
    presets = [ "nerd-font-symbols" ];
  };
  services.gnome.gnome-settings-daemon.enable = true;
  environment.gnome.excludePackages = (with pkgs.gnome; [ epiphany ]);

  programs.npm = {
    enable = true;
  };

  services.xserver.desktopManager.gnome = {
    extraGSettingsOverridePackages = with pkgs; [ gnome3.gnome-settings-daemon ];
    extraGSettingsOverrides = ''
      [org/gnome/desktop/input-sources]
      mru-sources=[('xkb', 'us')]
      sources=[('xkb', 'br')]
      xkb-options=['terminate:ctrl_alt_bksp']

      [org/gnome/desktop/calendar]
      show-weekdate=true

      [org/gnome/desktop/peripherals/mouse]
      natural-scroll=true

      [org/gnome/desktop/peripherals/touchpad]
      tap-to-click=true
      two-finger-scrolling-enabled=true

      [org/gnome/desktop/privacy]
      old-files-age=uint32 2
      recent-files-max-age=1
      remove-old-temp-files=true
      remove-old-trash-files=true

      [org/gnome/desktop/wm/preferences]
      button-layout='close,minimize,maximize:appmenu'

      [org/gnome/mutter]
      center-new-windows=true
      dynamic-workspaces=true
      edge-tiling=true
      workspaces-only-on-primary=true

      [org/gnome/shell/extensions/nightthemeswitcher/gtk-variants]
      day='Adwaita'
      enabled=true
      night='Adwaita-dark

      [org.gnome.settings-daemon.plugins.media-keys.custom-keybindings.custom0]
      binding='<Super>t'
      command='wezterm'
      name='Open terminal'

      [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
      binding='<Control><Alt>t'
      command='wezterm'
      name='Terminal'

      [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
      binding='<Shift><Control>Escape'
      command='gnome-system-monitor'
      name='Monitor de Recursos'
    '';
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        # signingkey = "";
        name = "sandhilt";
        email = "6170125+sandhilt@users.noreply.github.com";
      };
      commit = {
        gpgsign = true;
      };
      init = {
        defaultBranch = "main";
      };
      submodule = {
        recurse = true;
      };
      merge = {
        tool = "nvimdiff";
      };
      mergetool = {
        keepBackup = false;
      };
      "mergetool \"nvimdiff\"" = {
        layout = "LOCAL,BASE,REMOTE / MERGED";
      };
    };
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #   wget
    sbctl
    curl
    gnome.adwaita-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
    gnomeExtensions.night-theme-switcher
    unstable.gnomeExtensions.gamemode-indicator-in-system-settings
    gnomeExtensions.bluetooth-battery
    gnome-extension-manager
    unstable.gnomeExtensions.quick-settings-tweaker
    wireguard-tools
    # libgtop
    lua54Packages.luarocks
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "DroidSansMono"
        "VictorMono"
      ];
    })
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.https-dns-proxy = {
    enable = true;
    provider = {
      kind = "cloudflare";
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22000
    21027
    51413
    6697
    7000
    7070
    8008
    8009
    8443
    8545
    8546
    873
    9900
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
    {
      from = 6665;
      to = 6669;
    }
    {
      from = 8000;
      to = 8002;
    }
  ];
  networking.firewall.allowedUDPPorts = [
    22000
    21027
    36963
    8008
    8009
    8443
    8545
    6537
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
    {
      from = 8000;
      to = 10000;
    }
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.nftables.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
