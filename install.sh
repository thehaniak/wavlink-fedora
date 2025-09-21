#!/bin/bash
export LC_ALL=C
readonly SELF=$0/binaries
readonly COREDIR=/opt/siliconmotion
readonly OTHERPDDIR=/opt/displaylink
readonly LOGPATH=/var/log/SMIUSBDisplay
readonly PRODUCT="Silicon Motion Linux USB Display Software"
readonly FEDORA_VERSION=$(cat /etc/fedora-release | cut -d' ' -f3)
readonly ARCHITECTURE=$(arch)
readonly FEDORA_SUPPORTED_VERSIONS="41 42"


add_systemd_service()
{
  cat > /lib/systemd/system/smiusbdisplay.service <<'EOF'
[Unit]
Description=SiliconMotion Driver Service
After=display-manager.service
Conflicts=getty@tty7.service

[Service]
Environment=LD_LIBRARY_PATH=/opt/siliconmotion
ExecStartPre=/bin/bash -c "modprobe evdi || (dkms remove -m evdi -v $(awk -F '=' '/PACKAGE_VERSION/{print $2}' /opt/siliconmotion/module/dkms.conf) --all; if [ $? != 0 ]; then rm –rf /var/lib/dkms/$(awk -F '=' '/PACKAGE_VERSION/{print $2}' /opt/siliconmotion/module/dkms.conf) ;fi; dkms install /opt/siliconmotion/module/ && cp /opt/siliconmotion/evdi.conf /etc/modprobe.d && modprobe evdi)"

ExecStart= /opt/siliconmotion/SMIUSBDisplayManager
Restart=always
WorkingDirectory=/opt/siliconmotion
RestartSec=5

EOF

  chmod 0644 /lib/systemd/system/smiusbdisplay.service
}

trigger_udev_if_devices_connected()
{
  for device in $(grep -lw 090c /sys/bus/usb/devices/*/idVendor); do
    udevadm trigger --action=add "$(dirname "$device")"
  done
}

install()
{
  echo "Installing..."

  echo "Finding latest EVDI driver for Fedora ${FEDORA_VERSION} ${ARCHITECTURE}..."

  jq_query=".assets[] | select(.browser_download_url | contains(\"${ARCHITECTURE}\") and contains(\"fedora-${FEDORA_VERSION}\")) | .browser_download_url"

  DISPLAYLINK_RPM=$(curl -sL https://api.github.com/repos/displaylink-rpm/displaylink-rpm/releases/latest | jq -r "${jq_query}")

  echo "Found EVDI displaylink driver URL: ${DISPLAYLINK_RPM}"

  read -rp 'Do you want to continue with EVDI installation? [y/N] ' CHOICE

  [[ "${CHOICE:-N}" == "${CHOICE#[nN]}" ]] || exit 1

  dnf install ${DISPLAYLINK_RPM} lsb_release || exit 1

  mkdir -p $COREDIR
  chmod 0755 $COREDIR

  echo "Copying binaries..."
  cp -vf $(pwd)/binaries/* $COREDIR

  echo "Creating symlinks and setting permissions..."
  ln -sf $COREDIR/libusb-1.0.so.0.2.0 $COREDIR/libusb-1.0.so.0
  ln -sf $COREDIR/libusb-1.0.so.0.2.0 $COREDIR/libusb-1.0.so
  ln -sf /usr/libexec/displaylink/libevdi.so $COREDIR/libevdi.so.1

  chmod 0755 $COREDIR/SMIUSBDisplayManager
  chmod 0755 $COREDIR/libusb*.so*
  chmod 0755 $COREDIR/SMIFWLogCapture

  ln -sf $COREDIR/SMIFWLogCapture /usr/bin/SMIFWLogCapture
  chmod 0755 /usr/bin/SMIFWLogCapture

  source smi-udev-installer.sh
  siliconmotion_bootstrap_script="$COREDIR/smi-udev.sh"
  create_bootstrap_file "$SYSTEMINITDAEMON" "$siliconmotion_bootstrap_script"

  echo "Adding udev rule for SiliconMotion devices"
  create_udev_rules_file /etc/udev/rules.d/99-smiusbdisplay.rules

  echo "Adding upstart scripts"
  if [ "upstart" == "$SYSTEMINITDAEMON" ]; then
    echo "Starting SMIUSBDisplay upstart job"
    add_upstart_script
#   add_pm_script "upstart"
  elif [ "systemd" == "$SYSTEMINITDAEMON" ]; then
    echo "Starting SMIUSBDisplay systemd service"
    add_systemd_service
#  add_pm_script "systemd"
  fi

  echo -e "\nInstallation complete!"
  echo -e "\nPlease reboot your computer and check if everything is working as intended."
}


usage()
{
  echo
  echo "Installs $PRODUCT."
  echo "Usage:"
  echo " sudo $0 [ install | help | system-check ]"
  echo
  echo "The default operation is system-check."
  echo "If unknown argument is given, a quick compatibility check is performed but nothing is installed."
}

detect_init_daemon()
{
    INIT=$(readlink /proc/1/exe)
    if [ "$INIT" == "/sbin/init" ]
    then
        INIT=$(/sbin/init --version)
    fi


    [ -z "${INIT##*systemd*}" ] && SYSTEMINITDAEMON="systemd"

    if [ -z "$SYSTEMINITDAEMON" ]; then
        echo "Error: You're not using the upstart system. This is no longer supported. Please use systemd." >&2
        exit 1
    fi
}

prompt_supported()
{
  if ! system_check
  then
    read -rp 'Do you want to continue? [y/N] ' CHOICE

    [[ "${CHOICE:-N}" == "${CHOICE#[nN]}" ]] || exit 1
  fi
}

system_check()
{
  echo "System check:"

  if [ -f /etc/fedora-release ] \
    && [[ "${ARCHITECTURE}" == "x86_64" ]] \
    && [[ "${FEDORA_SUPPORTED_VERSIONS}" =~ (" "|^)${FEDORA_VERSION}(" "|$) ]]
  then
    echo "✔ Found Fedora ${FEDORA_VERSION} on arch ${ARCHITECTURE}"
    echo "✔ Found init system: $SYSTEMINITDAEMON"
    return 0
  fi

  echo "⚠ This script has not been tested on your distro/release or arquitecture:"
  echo "  - Supported Fedora versions are: ${FEDORA_SUPPORTED_VERSIONS}"
  echo "  - Supported architecture is ${ARCHITECTURE}"
  return 1
}


case $1 in

  "install")
    if [ "$(id -u)" != "0" ]; then
      echo "You need to be root to use this script." >&2
      exit 1
    fi
    detect_init_daemon
    prompt_supported
    install
    ;;

  "usage" | "help")
    usage
    ;;

  *)
    if system_check && detect_init_daemon
    then
      echo "To install run \"sudo $0 install\"."
    fi
    ;;

esac

