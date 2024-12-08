{ config, pkgs, ... }:

{
 imports = [
   ./hardware-configuration.nix
 ];

 # Современный загрузчик
 boot = {
   loader = {
     systemd-boot = {
       enable = true;
       configurationLimit = 10;
       consoleMode = "max";
     };
     efi.canTouchEfiVariables = true;
   };
   # Оптимизации для NVMe SSD и большой RAM
   kernel.sysctl = {
     "vm.swappiness" = 1;
     "vm.vfs_cache_pressure" = 50;
     "vm.dirty_ratio" = 3;
     "vm.dirty_background_ratio" = 2;
   };
   # Современные параметры ядра
   kernelParams = [
     "intel_pstate=active"
     "i915.enable_psr=1"
     "i915.enable_fbc=1"
     "i915.force_probe=46a6"
     "quiet"
     "splash"
     "loglevel=3"
     "rd.systemd.show_status=false"
     "rd.udev.log_level=3"
   ];
   # Самое свежее ядро
   kernelPackages = pkgs.linuxPackages_latest;
 };

 # Железо
 hardware = {
   cpu.intel.updateMicrocode = true;
   # Современные драйверы Intel
   opengl = {
     enable = true;
     driSupport = true;
     driSupport32Bit = true;
     extraPackages = with pkgs; [
       intel-media-driver
       intel-compute-runtime
       vaapiIntel
       vaapiVdpau
       libvdpau-va-gl
     ];
   };
   # Продвинутое энергосбережение
   power = {
     enable = true;
     powertop.enable = true;
     tlp = {
       enable = true;
       settings = {
         CPU_SCALING_GOVERNOR_ON_AC = "performance";
         CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
         CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
         CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
         CPU_MIN_PERF_ON_AC = 0;
         CPU_MAX_PERF_ON_AC = 100;
         CPU_MIN_PERF_ON_BAT = 0;
         CPU_MAX_PERF_ON_BAT = 75;
       };
     };
   };
 };

 # Современный нетворкинг
 networking = {
   networkmanager = {
     enable = true;
     wifi.backend = "iwd";
   };
   firewall = {
     enable = true;
     allowPing = false;
   };
 };

 # Продвинутый Pipewire
 security.rtkit.enable = true;
 services.pipewire = {
   enable = true;
   alsa.enable = true;
   alsa.support32Bit = true;
   pulse.enable = true;
   jack.enable = true;
   # Низкая латентность
   lowLatency = {
     enable = true;
     quantum = 64;
     rate = 48000;
   };
 };

 # Современный графический стек
 services = {
   xserver = {
     enable = true;
     # Улучшенный тачпад
     libinput = {
       enable = true;
       touchpad = {
         tapping = true;
         naturalScrolling = true;
         middleEmulation = true;
         disableWhileTyping = true;
         accelSpeed = "0.3";
         accelProfile = "adaptive";
       };
     };
     layout = "us,ru";
     xkbOptions = "grp:alt_shift_toggle";
   };
   # Самая свежая KDE Plasma 6
   desktopManager.plasma6.enable = true;
   displayManager = {
     sddm = {
       enable = true;
       wayland.enable = true;
     };
     defaultSession = "plasma";
   };
   # Автоматические обновления
   auto-cpufreq.enable = true;
   thermald.enable = true;
   fstrim.enable = true;
 };

 # Пользователь
 users.users.jondaw = {
   isNormalUser = true;
   hashedPassword = null;
   extraGroups = [
     "wheel"
     "networkmanager"
     "video"
     "audio"
     "docker"
     "libvirtd"
     "podman"
     "wireshark"
     "dialout"
     "plugdev"
   ];
   shell = pkgs.fish;
   createHome = true;
   homeMode = "755";
 };

 # Система
 i18n.defaultLocale = "en_US.UTF-8";
 time.timeZone = "America/Chicago";

 # Оптимизированные пакеты
 environment = {
   systemPackages = with pkgs; [
     vim
     wget
     curl
     git
     zip
     unzip
     p7zip
     powertop intel-gpu-tools
     kitty
     wayland-utils
     wl-clipboard
     fish
   ];
   plasma6.excludePackages = with pkgs.kdePackages; [
     konsole oxygen
   ];
   # Wayland переменные
   sessionVariables = {
     NIXOS_OZONE_WL = "1";
     MOZ_ENABLE_WAYLAND = "1";
     QT_QPA_PLATFORM = "wayland;xcb";
   };
 };

  # Разрешенные шеллы
  programs.fish = {
    enable = true;
    useBabelfish = true;  # Улучшенная совместимость с bash-скриптами
  };

 # Виртуализация
 virtualisation = {
   docker.enable = true;
   libvirtd.enable = true;
   podman = {
     enable = true;
     dockerCompat = true;
   };
 };

 # Современный Nix
 nix = {
   settings = {
     auto-optimise-store = true;
     experimental-features = [ "nix-command" "flakes" ];
     max-jobs = "auto";
     cores = 12;
     # Оптимизация кэша
     substituters = [
       "https://cache.nixos.org"
       "https://nix-community.cachix.org"
     ];
     trusted-public-keys = [
       "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
       "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
     ];
   };
   gc = {
     automatic = true;
     dates = "weekly";
     options = "--delete-older-than 7d";
   };
   # Оптимизация диска
   optimise = {
     automatic = true;
     dates = [ "weekly" ];
   };
 };

 # Последняя стабильная версия
 system.stateVersion = "24.11";
}
