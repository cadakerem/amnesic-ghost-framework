# Creating the Hidden Vault (VeraCrypt)

Before you can use this framework, you need to create the encrypted vault (`hidden_vault.hc`) where all your tools and sensitive data will reside. Since this is an Amnesic Live OS, the vault must be created on a persistent section of your USB drive (e.g., the `usb_drive` partition).

You can create the vault using either the VeraCrypt GUI or the command line.

## Method A: Using the VeraCrypt GUI (Recommended for Beginners)

1. Launch VeraCrypt from your application menu or by typing `veracrypt` in the terminal.
2. Click on **Create Volume**.
3. Select **Create an encrypted file container** and click Next.
4. Select **Standard VeraCrypt volume** (or Hidden if you prefer plausible deniability) and click Next.
5. **Volume Location:** Click *Select File*, navigate to your persistent USB partition (e.g., `/media/usb_drive/`), and name the file `hidden_vault.hc` (or camouflage it as something like `system_cache.sys`). Click Next.
6. **Encryption Options:** Leave the default (AES / SHA-512) or choose your preferred algorithms. Click Next.
7. **Volume Size:** Enter the desired size (e.g., `2 GB` or `5 GB` depending on your tools). Click Next.
8. **Volume Password:** Enter a strong, random password (at least 20+ characters). We do NOT recommend using keyfiles on a Live USB setup to avoid leaving unencrypted key traces. Click Next.
9. **Volume Format:** Move your mouse randomly within the window to increase cryptographic strength, select `ext4` or `exFAT` as the filesystem, and click **Format**.
10. Once formatted, exit the wizard. Your vault is now ready to be mounted.

## Method B: Using the Command Line (Headless/Automated)

If you prefer terminal-based creation (or want to script it), run the following command. 

*Note: Replace `<size>` with your preferred size in bytes, kilobytes (K), megabytes (M), or gigabytes (G), e.g., `2G`.*

```bash
veracrypt -t -c \
    --volume-type=normal \
    "/media/usb_drive/hidden_vault.hc" \
    --size=2G \
    --encryption=aes \
    --hash=sha-512 \
    --filesystem=ext4 \
    --pim=0 \
    --keyfiles="" \
    --random-source=/dev/urandom
```

The terminal will prompt you to enter and confirm your new volume password. Once completed, your vault is ready.

## Next Steps
After creating the vault, mount it (see [README](../README.md)), open it in your file manager, and copy the `scripts/` folder (including `ghost.sh` and `opsec-check.sh`) into it. You should also create any necessary directories for your tools (e.g., `repo/` for `.deb` packages).
