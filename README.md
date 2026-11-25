# Samba Auto Conf

> A minimal, run-out-of-the-box installer that turns a fresh Debian/Ubuntu machine into a working Samba file server.

[![Platform](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-A81D33?logo=debian&logoColor=white)](#requirements)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](#quick-start)
[![Samba](https://img.shields.io/badge/service-Samba-D22128)](#what-gets-installed)

Samba Auto Conf bundles a known-good `smb.conf` with a short provisioning script, so a shared folder can be served over SMB in a single command. No manual editing, no hunting through the default configuration file.

---

## Table of contents

- [Features](#features)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [What gets installed](#what-gets-installed)
- [Configuration](#configuration)
- [Connecting from a client](#connecting-from-a-client)
- [Managing users](#managing-users)
- [Security notes](#security-notes)
- [Troubleshooting](#troubleshooting)
- [Project structure](#project-structure)
- [Author](#author)

---

## Features

- **One-command setup** — installs Samba, creates the share and starts the service.
- **Opinionated, working configuration** — ships a tested `smb.conf` instead of relying on distro defaults.
- **Ready-to-use share** — `/home/sharedF` is exported as `server_shared-F` with read/write access.
- **Authenticated access** — an SMB account is created interactively via `smbpasswd`.
- **Firewall-friendly** — opens the UFW `samba` profile when applicable.
- **Instant feedback** — prints the server's network interfaces so clients know where to connect.

## Requirements

| Item | Detail |
| --- | --- |
| OS | Debian or Ubuntu (any `apt`-based derivative) |
| Privileges | `sudo` or root |
| Network | SMB ports `137–139`, `445` reachable from clients |
| Firewall | Optional — UFW is configured automatically if present |

> The installer is written for `apt`-based systems. On other distributions, install Samba manually and reuse the bundled `smb.conf`.

## Quick start

```bash
git clone https://github.com/mohammed20033/samba_auto_conf.git
cd samba_auto_conf
sudo bash server_installer.sh
```

During the run you will be prompted to choose a password for the SMB account. When the script finishes, the share is available at:

```
smb://<server-ip>/server_shared-F
```

## What gets installed

| Step | Action |
| --- | --- |
| 1 | Updates the package index and installs Samba |
| 2 | Creates `/home/sharedF` and grants full read/write permissions |
| 3 | Creates the local user `seven` and registers it as an SMB user |
| 4 | Replaces `/etc/samba/smb.conf` with the bundled configuration |
| 5 | Restarts `smbd` and allows Samba through UFW |
| 6 | Prints the network interfaces and the service status |

## Configuration

The exported share is defined at the end of [`smb.conf`](smb.conf):

```ini
[server_shared-F]
        path = /home/sharedF
        read list = seven
        write list = seven
        browseable = yes
```

Key globals:

| Setting | Value | Purpose |
| --- | --- | --- |
| `workgroup` | `WORKGROUP` | SMB workgroup advertised to clients |
| `server role` | `standalone server` | Simple file server, no domain controller |
| `map to guest` | `bad user` | Failed logins fall back to the guest account |
| `usershare allow guests` | `yes` | Permits public user-defined shares |

After editing the configuration, validate and reload it:

```bash
sudo testparm -s
sudo systemctl restart smbd
```

> Changing the share path, share name, or allowed users requires editing `smb.conf` and restarting the service.

## Connecting from a client

| Client | Address |
| --- | --- |
| Windows | `\\<server-ip>\server_shared-F` |
| macOS | Finder → **Go** → **Connect to Server** → `smb://<server-ip>/server_shared-F` |
| Linux (file manager) | `smb://<server-ip>/server_shared-F` |
| Linux (CLI) | `smbclient //<server-ip>/server_shared-F -U seven` |

Log in with the username `seven` and the password set during installation.

## Managing users

Add a new SMB user (the local account must exist first):

```bash
sudo adduser <username>
sudo smbpasswd -a <username>
```

Disable or remove an SMB account:

```bash
sudo smbpasswd -d <username>   # disable
sudo smbpasswd -x <username>   # delete
```

Then grant the user access in `smb.conf` and restart `smbd`.

## Security notes

This project prioritises convenience over hardening — review these points before exposing it beyond a trusted LAN:

- `/home/sharedF` is created with `chmod 777`, so every local user can read and write to it.
- Guests are mapped to the `bad user` account; disable this if all access must be authenticated.
- UFW is opened for Samba, not restricted to a subnet. Tighten the rule if the server is publicly reachable.
- SMBv1 is not required by this configuration. Keep it disabled on clients.
- For production use, consider per-user shares, `valid users`, and encrypted transport (SMB3).

## Troubleshooting

```bash
# Validate the configuration
sudo testparm -s

# Check the service
systemctl status smbd
sudo systemctl restart smbd

# Inspect logs
ls /var/log/samba/
tail -f /var/log/samba/log.smbd

# Confirm the firewall rule
sudo ufw status
```

| Symptom | Likely cause |
| --- | --- |
| Share not visible | `smbd` not running, or ports blocked |
| Access denied | SMB password missing — run `sudo smbpasswd -a <user>` |
| Changes have no effect | `smbd` not restarted after editing `smb.conf` |

## Project structure

```
samba_auto_conf/
├── README.md            # This document
├── server_installer.sh  # Provisioning script
└── smb.conf             # Samba configuration deployed to /etc/samba
```

## Author

**Mohamed Refaay** — [@mohammed20033](https://github.com/mohammed20033)

Built for quick, repeatable Samba setups. Issues and pull requests are welcome.
