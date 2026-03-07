#!/bin/bash
set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_DIR="$(realpath "$SCRIPT_DIR/../vm")"
ISO_URL="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-virt-3.21.3-x86_64.iso"
ISO_FILE="$VM_DIR/alpine.iso"
DRIVE_FILE="$VM_DIR/drive.qcow2"
SSH_PORT=2222
DRIVE_SIZE="20G"
RAM="2G"
CPUS=2

# Set by check_deps
KVM_FLAGS=""

# ─── Helpers ──────────────────────────────────────────────────────────────────
info() { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m  $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
die()  { echo -e "\033[1;31m[ERR ]\033[0m  $*" >&2; exit 1; }

# ─── Dependency Check ─────────────────────────────────────────────────────────
check_deps() {
    local missing=()
    for cmd in curl qemu-img qemu-system-x86_64; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    [[ ${#missing[@]} -eq 0 ]] || die "Missing tools: ${missing[*]}. Install with: sudo pacman -S qemu-full curl"

    if [[ -w /dev/kvm ]] 2>/dev/null; then
        KVM_FLAGS="-enable-kvm -cpu host"
    else
        warn "/dev/kvm not accessible — VM will run without hardware acceleration"
    fi
}

# ─── Setup ────────────────────────────────────────────────────────────────────
cmd_setup() {
    info "Creating VM directory: $VM_DIR"
    mkdir -p "$VM_DIR"

    # Download Alpine Linux virt ISO
    if [[ -f "$ISO_FILE" ]]; then
        ok "ISO already present, skipping download"
    else
        info "Downloading Alpine Linux ISO (~60 MB)..."
        curl -L --progress-bar -o "$ISO_FILE.tmp" "$ISO_URL"
        mv "$ISO_FILE.tmp" "$ISO_FILE"
        ok "ISO downloaded: $ISO_FILE"
    fi

    # Create qcow2 drive
    if [[ -f "$DRIVE_FILE" ]]; then
        ok "Drive already present, skipping creation"
    else
        info "Creating qcow2 drive ($DRIVE_SIZE)..."
        qemu-img create -f qcow2 "$DRIVE_FILE" "$DRIVE_SIZE"
        ok "Drive created: $DRIVE_FILE"
    fi

    ok "Setup complete"
}

# ─── Install (boot into Alpine live ISO) ─────────────────────────────────────
cmd_install() {
    [[ -f "$ISO_FILE"   ]] || die "ISO not found. Run: $0 setup"
    [[ -f "$DRIVE_FILE" ]] || die "Drive not found. Run: $0 setup"

    info "Booting Alpine Linux live environment (headless, serial console)"
    info "  To enable SSH: passwd && service sshd start"
    info "  SSH into the VM: ssh -p $SSH_PORT root@localhost"
    info "  To install: setup-alpine"
    info "  After install completes, run: $0 boot"

    # shellcheck disable=SC2086
    qemu-system-x86_64 \
        $KVM_FLAGS \
        -m "$RAM" \
        -smp "$CPUS" \
        -drive file="$DRIVE_FILE",if=virtio,format=qcow2 \
        -drive file="$ISO_FILE",media=cdrom,readonly=on \
        -boot order=d \
        -netdev user,id=net0,hostfwd=tcp::"$SSH_PORT"-:22 \
        -device virtio-net-pci,netdev=net0 \
        -display none \
        -serial stdio \
        -name "SphinxOS-Install"
}

# ─── Boot (post-installation) ─────────────────────────────────────────────────
cmd_boot() {
    [[ -f "$DRIVE_FILE" ]] || die "Drive not found: $DRIVE_FILE"

    info "Booting SphinxOS VM..."

    # shellcheck disable=SC2086
    qemu-system-x86_64 \
        $KVM_FLAGS \
        -m "$RAM" \
        -smp "$CPUS" \
        -drive file="$DRIVE_FILE",if=virtio,format=qcow2 \
        -boot order=c \
        -display gtk \
        -name "SphinxOS"
}

# ─── Entry Point ──────────────────────────────────────────────────────────────
check_deps

case "${1:-install}" in
    setup)   cmd_setup ;;
    install) cmd_setup; cmd_install ;;
    boot)    cmd_boot ;;
    *)
        echo "Usage: $0 [setup|install|boot]"
        echo
        echo "  setup    — Download ISO and create drive"
        echo "  install  — Setup then boot into Alpine live ISO for installation (default)"
        echo "  boot     — Boot the installed VM (run after installation is complete)"
        exit 1
        ;;
esac