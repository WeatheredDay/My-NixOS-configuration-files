# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, pkgs-unstable, ... }:

{
nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

#Enable 32bit gaming
hardware.graphics.enable32Bit = true;


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Mexico_City";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # Use the WirePlumber session manager
    #wireplumber.enable = true;
  };

#Fonts packages so i can larp even more of using the terminal
fonts.packages = with pkgs; [
  fira-code
  jetbrains-mono

];




  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."weatherday" = {
    isNormalUser = true;
    description = "weatherday";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
    git
easyeffects
wget
(let
  pseint = pkgs.buildFHSEnv {
    name = "pseint";
    targetPkgs = p: with p; [
  libxxf86vm libsm libice libx11
  libGL libGLU gtk3
  glib gdk-pixbuf cairo pango atk harfbuzz
  fontconfig freetype zlib libpng
  libxext libxrender libxi libxcursor libxrandr libxinerama
  libxt libxtst
  wayland
  gsettings-desktop-schemas
  adwaita-icon-theme
    ];
    runScript = pkgs.writeShellScript "pseint-run" ''
      export GDK_BACKEND=x11
      cd /home/weatherday/Documents/pseint
      exec ./pseint "$@"
    '';
  };
  pseint-desktop = pkgs.makeDesktopItem {
    name = "pseint";
    desktopName = "PSeInt";
    exec = "pseint";
    categories = [ "Education" "Development" ];
  };
in pkgs.symlinkJoin {
  name = "pseint";
  paths = [ pseint pseint-desktop ];
})
####pkgs-unstable.osu-lazer-bin
lutris
steam
obs-studio
lufus
pkgs-unstable.heroic
pkgs-unstable.brave-origin
pkgs.kitty
#Python packages with added libraries or whatever
(pkgs.python3.withPackages (ps: with ps; [numpy pandas matplotlib tkinter polars]))
discord
joplin-desktop
blender
pkgs.kdePackages.kdenlive
audacity
openlinkhub
vim
vmware-workstation
nodejs
#Qemu and kvm
pkgs.qemu
pkgs.virt-manager
#Roblox studio and developement
vinegar
#String of packages for c language programing
  gcc
  gdb
  gnumake
  cmake
  pkg-config
  clang-tools   # provides clangd
  bear
  lldb
#For vscode extensions
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        llvm-vs-code-extensions.vscode-clangd
        vadimcn.vscode-lldb
      ];
    })
    ];
  };



  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;



  # Start the default libvirt network automatically
  systemd.services.libvirt-default-network = {
    description = "Autostart libvirt default network";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.libvirt}/bin/virsh -c qemu:///system net-autostart default || true
      ${pkgs.libvirt}/bin/virsh -c qemu:///system net-start default || true
    '';
  };






virtualisation.vmware.host.enable = true;
programs.hyprland.enable = true; # enable Hyprland


services.udev.extraRules = ''
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b1c", MODE="0666"
  KERNEL=="hidraw*", ATTRS{idVendor}=="1b1c", MODE="0666"
'';


  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

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

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

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
  system.stateVersion = "26.05"; # Did you read the comment?


nix.gc = {
automatic = true;
dates = "weekly";
options = "--delete-older-than-30d";
};


}
