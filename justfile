alias s := switch-legion
alias l := switch-lain
alias t := test-legion
alias u := update-all
# alias sh := switch-home

# Update all flake inputs
update-all:
    nix flake update --commit-lock-file --accept-flake-config

# Update specificied input
update INPUT:
    nix flake update {{ INPUT }} --commit-lock-file --accept-flake-config

# Check flake configuration
check:
    nix flake check --accept-flake-config

# Check Home manager configuration
# check-home:
#     home-manager --dry-run switch --flake .

# Check flake with show-trace
trace-check:
    nix flake check --show-trace

# Switch legion generation
switch-legion:
    nh os switch . -H legion --accept-flake-config

# Switch legion generation
switch-lain:
    nh os switch . -H lain --accept-flake-config

# Boot to configuration
boot-legion:
    nh os boot . -H legion --accept-flake-config

# Boot to configuration
boot-lain:
    nh os boot . -H lain --accept-flake-config

# Switch legion generation with show-trace
trace-switch-legion:
    nh os switch . -H legion --accept-flake-config --show-trace

# Switch lain generation with show-trace
trace-switch-lain:
    nh os switch . -H lain --accept-flake-config --show-trace

# Switch home manager generation
# switch-home:
#     home-manager switch  --flake .

# Switch home manager generation with show-trace
# trace-switch-home:
#     home-manager switch  --flake . --show-trace

# Test legion configuration
test-legion:
    nh os test . -H legion --accept-flake-config

# Test legion configuration
test-lain:
    nh os test . -H lain --accept-flake-config

# Clear unused packages from nix store
clean:
    nh clean all

# Run SDDM in test mode
sddm:
    sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/breeze/

# Copy keys to sops config directory
keys:
    sudo mkdir -p /persist/sops
    sudo cp keys.txt /persist/sops

# Optimise nix store
optimise:
    nix store optimise
