# i3lock-webcam-trap

## What is different about this version?

This fork/version of i3lock adds the following features on top of the original i3lock-color:

- **Webcam Trap:** If the mouse is clicked or a wrong password is entered, a photo is taken using your webcam. This can be used for security or fun purposes.
- **Fake Desktop Generation:** The `scripts/generateFakeDesktop.sh` script can generate a fake desktop background with a blurred bar and a customizable icon bar, useful for tricking people into thinking you left your PC unlocked.

### Usage of `generateFakeDesktop.sh`

Run the script to generate a composite image (`$HOME/.monitors.png`) that mimics your desktop layout, including a blurred/darkened bar at the bottom and a row of icons. The icon bar is built from PNG files in `scripts/icons/center/`. You can configure icon size and margin at the top of the script.

**Example:**
```bash
cd scripts
./generateFakeDesktop.sh
```
This will create the image as `$HOME/.monitors.png`.

To actually use the image in i3lock:
```bash
i3lock -i ~/.monitors.png
```

### Additional Requirements

This version requires some extra dependencies beyond the original i3lock-color:

- [ImageMagick](https://imagemagick.org/) (for all image compositing and manipulation)
- [fswebcam](https://www.sanslogic.co.uk/fswebcam/) (for taking webcam photos)
- [xrandr](https://www.x.org/wiki/Projects/XRandR/) (for monitor layout detection)
- [feh](https://feh.finalrewind.org/) or other wallpaper managers (optional, for wallpaper detection)

Make sure these tools are installed and available in your `$PATH`.

---

For general usage, features, and build instructions, please refer to the original [i3lock-color repository](https://github.com/Raymo111/i3lock-color). This fork only documents the features and requirements that are unique to this version.

## Dependencies
The following dependencies will need to be installed for a successful build, depending on your OS/distro.

### Arch Linux
- autoconf
- cairo
- fontconfig
- gcc
- libev
- libjpeg-turbo
- libxinerama
- libxkbcommon-x11
- libxrandr
- pam
- pkgconf
- xcb-util-image
- xcb-util-xrm

### Debian
Run this command to install all dependencies:
```
sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev
```
If you still see missing packages during build after installing all of these dependencies, try following the steps [here](https://github.com/Raymo111/i3lock-color/issues/211#issuecomment-809891727).

### Fedora
Run this command to install all dependencies:

```sh
sudo dnf install -y autoconf automake cairo-devel fontconfig gcc libev-devel libjpeg-turbo-devel libXinerama libxkbcommon-devel libxkbcommon-x11-devel libXrandr pam-devel pkgconf xcb-util-image-devel xcb-util-xrm-devel
```

### Ubuntu 18/20.04 LTS
Run this command to install all dependencies:
```
sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev
```

## Building i3lock-color
Before you build - check and see if there's a packaged version available for your distro (there usually is, either in a community repo/PPA).

**If you want to build a non-debug version, you should tag your build before configuring.**

For example: `git tag -f "git-$(git rev-parse --short HEAD)"` will add a tag with the short commit ID, which will be used for the version info.

i3lock-color uses GNU autotools for building.

To build/install i3lock-color, first install the dependencies listed above, then clone the repo:
```
git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
```
To build without installing, run:
```
./build.sh
```
To build AND install, run:
```
./install-i3lock-color.sh
```
You may choose to modify the script based on your needs/OS/distro.

## Alpine Linux Packages
Alpine packages i3lock-color for a variety of architectures. A full list can be found on [pkgs.alpinelinux.org](https://pkgs.alpinelinux.org/packages?name=i3lock-color&branch=edge).

## Arch Linux Packages
~~[Stable version in Community](https://www.archlinux.org/packages/community/x86_64/i3lock-color/)~~

Unfortunately the previous maintainer left, and the package got dumped back into the AUR where I'm now maintaining it. You can get it on AUR:
- [Release Version on AUR](https://aur.archlinux.org/packages/i3lock-color/)
- [Git Version on AUR](https://aur.archlinux.org/packages/i3lock-color-git/)

If you're an Arch TU and you're reading this please consider sponsoring it into Community again!

## Gentoo Linux Package
i3lock-color is available on **GURU**, under [`x11-misc/i3lock-color`](https://github.com/gentoo/guru/tree/master/x11-misc/i3lock-color).

## Kali Linux Package
A Debian/Kali package is available: https://gitlab.com/kalilinux/packages/i3lock-color.

## NixOS Package
A NixOS package is available. To install, run
```
nix-env -iA nixos.i3lock-color
```

## Void Linux Package
A Void Linux package is available at https://github.com/void-linux/void-packages/tree/master/srcpkgs/i3lock-color.

## FreeBSD port
A FreeBSD port is available on freshports: [x11/i3lock-color/](https://www.freshports.org/x11/i3lock-color/).

## Running i3lock-color
Simply invoke the 'i3lock' command. To get out of it, enter your password and press enter.

A [sample script](examples/lock.sh) is included in this repository.

On OpenBSD the `i3lock` binary needs to be setgid `auth` to call the authentication helpers, e.g. `/usr/libexec/auth/login_passwd`.

## Contributors
This project was started by [eBrnd](https://github.com/eBrnd/i3lock-color), maintained for a few years by [PandorasFox](https://github.com/PandorasFox) and now maintained and being developed by [Raymo111](https://github.com/Raymo111). The full list of contributors can be found [here](https://github.com/Raymo111/i3lock-color/graphs/contributors).

## Upstream
Please submit pull requests for i3lock things to [https://github.com/i3/i3lock](https://github.com/i3/i3lock) and pull requests for additional features on top of regular i3lock at [https://github.com/Raymo111/i3lock-color](https://github.com/Raymo111/i3lock-color).
