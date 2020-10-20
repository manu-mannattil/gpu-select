# gpu-select

gpu-select is a simple shell script to switch between Intel/NVIDIA
graphics on PRIME systems.  It's similar in functionality to Ubuntu's
`prime-select` command.

## Installation

gpu-select requires [bbswitch][bbswitch] (Debian package
`bbswitch-dkms`) from the Bumblebee Project.  To install gpu-select,
clone this repository and run `make install` as root.

The X configuration files that gpu-select uses are installed in
`/etc/gpu-select`.  Intel and NVIDIA specific configuration are kept in
the files `intel.conf` and `nvidia.conf` of that directory.  One should
ensure that the correct bus ID for the devices have been set in the
configuration files.  To find the bus ID, see `lspci`'s output, e.g.,

```
$ lspci | grep -E '3D|VGA'
00:02.0 VGA compatible controller: Intel Corporation UHD Graphics 620 (Whiskey Lake) (rev 02)
3c:00.0 3D controller: NVIDIA Corporation Device 1d34 (rev a1)
```

X requires decimal bus IDs (as opposed to the hexadecimal bus IDs that
`lspci` shows) in its configuration files.  Since 3c is 60 in decimal,
the decimal bus ID of the NVIDIA device in the above example is
`60:0:0`.

## Usage

The basic usage is

```
$ gpu-select intel|hybrid|nvidia|query
```

The options `nvidia` and `intel` turn the GPU on/off and configures X to
run on the NVIDIA GPU/Intel graphics.  The option `hybrid` turns on the
GPU, but configures X to run on Intel graphics.  (Depending on the
supplied option, the appropriate X configuration file is copied from
`/etc/gpu-select` to the `xorg.conf.d` directory.)  And finally, the
option `query` reports the state, which can also be read from the file
`/etc/gpu-select/state`.

Note that the installation blacklists *all* NVIDIA drivers by default.
This means that even if the discrete GPU is selected, the system reverts
back to Intel graphics and powers down the GPU on reboot.

Also, gpu-select doesn't configure `xinit` for you.  Hence, one should
check if the discrete GPU is turned on before starting X and run the
appropriate `xrandr` call, e.g., by adding the following snippet in
`~/.xinitrc`:

```sh
#!/usr/bin/env bash
# ~/.xinitrc

gpu=$(</etc/gpu-select/state)
if [[ "$gpu" == "nvidia" ]]
then
  xrandr --setprovideroutputsource modesetting NVIDIA-0
  xrandr --auto
fi

# rest of ~/.xinitrc
```

## Issues

Sometimes, bbswitch fails to turn the GPU off, e.g.,

```
$ echo "OFF" >/proc/acpi/bbswitch
$ cat /proc/acpi/bbswitch
0000:3c:00.0 ON
```

On some Lenovo ThinkPads (e.g., P53s, P43s, T490, etc.) this issue can
be fixed by passing `acpi_osi='!Linux-Lenovo-NV-HDMI-Audio'` to the
kernel parameters (see [here][tp1] and [here][tp2]).

Some laptops may also [require adding][bbker] `pcie_port_pm=off` to the
kernel parameters for bbswitch to work.  However, note that
`pcie_port_pm=off` disables PCIe port power management, which almost
always *will* result in poor battery life.

gpu-select has been most recently tested with bbswitch 0.8-9 and NVIDIA
drivers 440.100 from buster-backports on Debian 10.5.

## License

Public domain.  See the file UNLICENSE for more details.

[bbker]: https://github.com/Bumblebee-Project/bbswitch/issues/140
[bbswitch]: https://github.com/Bumblebee-Project/bbswitch
[tp1]: https://forums.lenovo.com/t5/ThinkPad-P-and-W-Series-Mobile-Workstations/Disable-NVIDIA-P520-on-the-P43s-ACPI-Calls/m-p/4545175
[tp2]: https://www.reddit.com/r/archlinux/comments/cm6z2a/thinkpad_t490_battery_life/fg30e5f
