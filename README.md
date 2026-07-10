# Nix Configuration

A comprehensive NixOS configuration using flakes, featuring multi-machine support with specialized modules for desktop environments, development tools, and system services.

## Features

- **Multi-machine support**: Separate configurations for "legion" (laptop) and "lain" (desktop/server) machines
- **Flake-based**: Modern Nix package management with reproducible builds
- **Modular architecture**: Organized modules for desktop, development, gaming, and system services
- **Home Manager integration**: User-level configuration management
- **Secure boot**: Lanzaboote for UEFI Secure Boot support
- **Secrets management**: SOPS-Nix for encrypted secrets
- **Desktop environments**: Support for Hyprland, Niri, COSMIC, and Plasma
- **Development tools**: Pre-configured editors (Zed), LSP support, containerization, and Android development
- **Gaming support**: Steam and gaming-related packages
- **Theming**: Stylix for system-wide theming with wallpaper support

## Technologies

- NixOS with flakes
- Home Manager
- Lanzaboote (Secure Boot)
- SOPS-Nix (secrets)
- Stylix (theming)
- Just (command runner)
- Niri, Hyprland, COSMIC, Plasma (desktop environments)

## Usage

Install [NixOS](https://nixos.org/download/) with flakes enabled, then:

```bash
# Check configuration
just check

# Switch to legion configuration
just s

# Switch to lain configuration
just l

# Test Legion configuration
just t

# Update all flake inputs
just u

# Clean nix store
just clean
```

## Project Structure

```
.
├── base/           # Base system configuration (boot, networking, services)
├── modules/        # Modular system features
│   ├── desktop/    # Desktop environments (Hyprland, Niri, COSMIC, Plasma)
│   ├── dev/        # Development tools and editors
│   └── ...         # Gaming, fonts, nvidia, etc.
├── system/         # Machine-specific configurations
│   ├── legion/     # Laptop configuration
│   └── lain/       # Desktop/server configuration
├── wrapped/        # Wrapped configurations for shells and panels
├── icons/          # Custom icons
├── wallpapers/     # Wallpaper collection
└── flake.nix       # Main flake configuration
```

## License

MIT License - Copyright (c) 2026-present Jasdeep-Dhillon
