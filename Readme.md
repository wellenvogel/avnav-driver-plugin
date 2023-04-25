Kernel Modules for AvNav Images
===============================
This package contains some kernel modules for [AvNav](https://www.wellenvogel.net/software/avnav/docs/install.html?lang=en#h2:AvNavImagesnamedHeadlessinthepast) images on a raspberry pi.
They will be installed using [DKMS](https://manpages.ubuntu.com/manpages/bionic/man8/dkms.8.html).
By installing this package only the sources and the dkms.conf files for the included modules are installed to /usr/src.

Activation of modules is only done when explicitely enabled in the [/boot/avnav.conf](https://www.wellenvogel.net/software/avnav/docs/install.html?lang=en#preparation).

All the set up handling on the system is executed by the [setup.sh](setup.sh) script.

Included Modules
----------------
  * [RTL8188EU](https://github.com/lwfinger/rtl8188eu/): driver for wifi adapters with the rtl8188eu chip set
  * [RTL8192EU](https://github.com/Mange/rtl8192eu-linux-driver): driver for wifi adapters using the rtl8192eu chip set

Releases
--------
  * [20230425](../../releases/tag/20230425)
    Initial relasese after renaminng.  
