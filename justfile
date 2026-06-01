alias s := switch-legion
alias l := switch-lain
alias t := test-legion
alias u := update-all
# alias sh := switch-home

# Update all flake inputs
update-all:
    nix flake update --commit-lock-file

# Update specificied input
update INPUT:
    nix flake update {{ INPUT }} --commit-lock-file

# Check flake configuration
check:
    nix flake check

# Check Home manager configuration
# check-home:
#     home-manager --dry-run switch --flake .

# Check flake with show-trace
trace-check:
    nix flake check --show-trace

# Switch legion generation
switch-legion:
    nh os switch . -H legion

# Switch legion generation
switch-lain:
    nh os switch . -H lain

# Boot to configuration
boot-legion:
    nh os boot . -H legion

# Boot to configuration
boot-lain:
    nh os boot . -H lain

# Switch legion generation with show-trace
trace-switch-legion:
    nh os switch . -H legion --show-trace

# Switch lain generation with show-trace
trace-switch-lain:
    nh os switch . -H lain --show-trace

# Switch home manager generation
# switch-home:
#     home-manager switch  --flake .

# Switch home manager generation with show-trace
# trace-switch-home:
#     home-manager switch  --flake . --show-trace

# Test legion configuration
test-legion:
    nh os test . -H legion

# Test legion configuration
test-lain:
    nh os test . -H lain

# Clear unused packages from nix store
clean:
    nh clean all

# Run SDDM in test mode
sddm:
    sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/breeze/
