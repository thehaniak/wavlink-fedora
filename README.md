
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

If you're too lazy to check the code 😜 ...

1) Downloads and installs the _latest_ EVDI driver RPM from [displaylink-rpm](https://github.com/displaylink-rpm/displaylink-rpm/releases) (the version/link is actually hardcoded, but can be changed easily)
2) Copies the binaries (firmware and driver) to _/opt/siliconmotion_.
3) Installs _smiusbdisplay.service_.

# Next steps

- Cleanup the install script.
- Make the EVDI version installation dynamic.
- Make it possible to uninstall the SMI and EVDI drivers.

# Wavlink Original License

```
//Copyright (c) 2020, SiliconMotion Inc.
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//    * Neither the name of the <organization> nor the
//      names of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


3rd party components
====================

evdi (Extensible Virtual Display Interface) Linux Kernel Module
===============================================================
The evdi kernel module is licensed under the GNU General Public License, version 2.0.
The GPL v2.0 license text for the module can be found next to the source code in a separate LICENSE file.

libevdi wrapper library
=======================
The libevdi wrapper library is licensed under the GNU Lesser General Public License, version 2.1.
The LGPL v2.1 license text can be found below.

libusb library
=======================
The Software uses libusb, which is licensed under LGPL v2.1.
```
