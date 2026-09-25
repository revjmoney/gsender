# gSender RotatoCAM Preview — Raspberry Pi 4 ARM64

Normal gSender desktop app with Y-aligned rotary preview selected by default
and automatic RotatoCAM Z-zero metadata reading. Includes the PR 959 changes.
Connect to the FluidNC card using the usual gSender connection controls.
No separate browser, headless service, or kiosk is required.

For Raspberry Pi OS Legacy 64-bit (Bookworm) on Pi 4:

```sh
sha256sum -c SHA256SUMS
sudo apt update
sudo apt install ./gsender-rotatocam-preview*.deb
```

Open **gSender RotatoCAM Preview** from the application menu. It uses its own
settings profile (`~/.config/gSender RotatoCAM Preview`) and can coexist with
the official gSender. No automatic updater is included in this preview build.
Do not connect both copies to the same controller simultaneously.

If the Pi has plain Lite without a graphical session, add one first:

```sh
sudo apt install --no-install-recommends xserver-xorg xinit openbox
startx /usr/bin/gsender-rotatocam-preview -- :0
```

Run `startx` at the Pi's attached console as your normal user, not with sudo.
If gSender already runs on the screen, the graphical session is already there.
USB serial connections need membership in `dialout`, as with normal gSender.

Valid `rotatocam-meta: z_zero_offset=... radial=z units=mm` comments set the
preview centerline automatically, including positive, negative and zero offsets.
Files without supported metadata use the Rotary centerline Z setting.
Y alignment can still be changed to X under Config > Rotary.
These settings affect display only; streamed G-code is unchanged.

Built on native ARM64 Debian Bookworm. The build checks 37 rotary regression
cases, native serial binding loading, Debian package metadata and desktop page
startup under a virtual display. Physical Pi display, FluidNC connection and
machine operation still need testing on the target Pi.

This is a RotatoCAM preview build, not an official Sienci Labs release.