
# About

This is an installation port for Fedora 41 Linux of the [Wavlink WL-UG6902H](https://www.wavlink.com/en_us/product/WL-UG6902H.html).
The device works (is supported) for Ubuntu 24.04, by just running the installation script provided by Wavlink ([check my Gist about this](https://gist.github.com/thehaniak/c40506846f1418f624f4f25164e62eff)).

To make it work on Fedora, I needed to figure out how the official installation script works and rework it accordingly.

# How to install 

Clone this repo:

```
git clone https://github.com/thehaniak/wavlink-fedora.git
cd wavlink-fedora
```


Add run permissions and run the install.sh script as root:

```
chmod +x install.sh
sudo ./install.sh
```

The install script will prompt you to install the EVDI driver. If you approve, it will also install the SMI USB driver and service.

If the device is not working straight away, just start the **smiusbdisplay.service**.

```
systemctl start smiusbdisplay.service
```

After installation, you **shoud** reboot to make sure everything is working properly.

# How the installation port works



# Next steps

- Cleanup the install script.
- Make it possible to uninstall the SMI and EVDI drivers.
