{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;  
  boot.loader.generic-extlinux-compatible.enable = true;
  hardware.deviceTree.name = "amlogic/meson-gxl-s905x-p212.dtb"; # STB hg680p
  #boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.plymouth.enable = true;

  #driver wifi STB
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8189fs ];
  
  #zram
  zramSwap.enable = true;
  zramSwap.memoryPercent = 100;  

  #filesystem
  boot.supportedFilesystems = [
      "btrfs"
      "ntfs"
      "fat32"
      "exfat"
  ];
  
  # nixpkgs config
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "nixos-server"; # Define your hostname.
  
  # networkmanager terminal User interface(nmtui)
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.UTF-8";
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };

  console = {
     font = "Lat2-Terminus16";
     keyMap = "us";  
  };

  # ENV
  environment.variables = {
    
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ramuni = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [

     ];
  };

  # List packages installed in system profile. 
  environment.systemPackages = with pkgs; [
    wget nano 
    neofetch btop htop duf
    #docker-compose
    p7zip git
    lshw util-linux hwinfo dmidecode pciutils busybox
    #overide php cli with extension
    (php.buildEnv {
      extensions = ({ enabled, all }: enabled ++ (with all; [
        snmp
        sqlite3
      ]));
    })
  ];
  
  # List services that you want to enable:

  # cockpit panel
  #services.cockpit.enable = true;
  #services.cockpit.port = 9000;
  #services.udisks2.enable = true;
  #services.packagekit.enable = true;

  # docker
  #virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes"; #for root
  
  # cronjob
  services.cron.enable = true;

  # apache
  services.httpd.enable = true;
  services.httpd.extraConfig = "
    <VirtualHost *:80>
      ServerAdmin webmaster@example.com
      ServerName mekardata.my.id
      DocumentRoot /home/ramuni/www    
        <Directory /home/ramuni/www>
          DirectoryIndex index.php index.html
          Options Indexes FollowSymLinks
          AllowOverride All
          Require all granted
        </Directory>
    </VirtualHost>
  ";
  services.httpd.group = "users";
  services.httpd.user = "ramuni";  
  
  # php
  services.httpd.enablePHP = true;
  services.httpd.phpOptions = ''

  '';

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 21 80 9000 ];
  networking.firewall.allowedUDPPorts = [  ];
  
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; 
}

