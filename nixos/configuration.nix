{ config, pkgs, ... }:

{
  # We require 5.14+ for VMware Fusion on M1.
  boot.kernelPackages = pkgs.linuxPackages_5_15;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # VMware guest additionals
      ../modules/vmware-guest.nix
      <home-manager/nixos>
      ../users/chengchengmu/nixos.nix
    ];

  # We expect to run the VM on hidpi machines.
  # hardware.video.hidpi.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define your hostname.
  networking.hostName = "vm";

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens160.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # setup windowing environment
  services.xserver = {
    enable = true;
    layout = "us";
    dpi = 220;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "scale";
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xlibs.xset}/bin/xset r rate 200 40
        ${pkgs.xorg.xrandr}/bin/xrandr -s '2880x1800'
      '';
    };

    windowManager = {
      i3.enable = true;
    };
  };

  # Configure keymap in X11
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    gnumake
    killall
    xclip

    gtkmm3
    # VMware on M1 doesn't support automatic resizing yet and on
    # my big monitor it doesn't detect the resolution either so we just
    # manualy create the resolution and switch to it with this script.
    # This script could be better but its hopefully temporary so just force it.
    (writeShellScriptBin "xrandr-6k" ''
      xrandr --newmode "6016x3384_60.00"  1768.50  6016 6544 7216 8416  3384 3387 3392 3503 -hsync +vsync
      xrandr --addmode Virtual-1 6016x3384_60.00
      xrandr -s 6016x3384_60.00
    '')
    (writeShellScriptBin "xrandr-mbp" ''
      xrandr -s 2880x1800
    '')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnpLzTSVF2rfPHGzGHb8x3w/2tQU9RBN+DaNFmtp7n4F1U06q4nWlkS4j4V76QkLAgGHk32bLjdLI2UeJyrSkv8UnmIv2WNMYCLBom2n5k1+YtL+ssc/7O3ZsVZEiDhwnAFllQHK8PXF+Tf1n+HFyXN2VYY3/34wdEYwuqHloGBtge66oFTnpZxyx/o3++AKK35R2yylQOKb90+b0rgoIn5aBEmcPrK70fF54CNZ3vk/Y6Q/lJkSxmXdbnqUK3nyaUGR/gOmWo2H/MutkKcJenA0uPBrcMLv+p1tZViu5eSiaCj9B0hNayHjvM1tyYM0hKEjS6gZPL1GOx8R2hBsqvcdCVg0SbLlS4LFR4HgCLQ7MqGY83e4f1AYcFF6GIOwGecgUqiIJg6EjDy9AICknGP16KQYn9Tqw9RqP9fPvzpLGLs5fmYc05aOkWUQuimOsN2gjH8xATKA9nfmYPRmIA61/Md5kXo/K8NGecU5Ev1ZKQPrI1WpMsA+yMrEWFA08= chengchengmu@192-168-1-171.tpgi.com.au"];
  services.openssh.passwordAuthentication = false;
  services.openssh.permitRootLogin = "yes";
  users.users.root.initialPassword = "root";

  # chengcheng user config
  users.users.chengchengmu.isNormalUser = true;
  home-manager.users.chengchengmu = import ../users/chengchengmu/home-manager.nix;

}

