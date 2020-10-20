# WPS PIN generator
![GitHub](https://img.shields.io/github/license/drygdryg/wpspin-nim)
![GitHub All Releases](https://img.shields.io/github/downloads/drygdryg/wpspin-nim/total)
[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)

## Overview
WPS PIN generator uses known MAC address based algorithms commonly found in routers firmware to generate their default PIN codes. PIN codes can be used with programs like [Reaver](https://github.com/t6x/reaver-wps-fork-t6x), [Bully](https://github.com/aanarchyy/bully)  or [OneShot](https://github.com/drygdryg/OneShot) to recover Wi-Fi passwords.
## Installation
### Installing on Debian >= 11 or Ubuntu >= 20.04
```
sudo apt install -y nim
git clone https://github.com/drygdryg/wpspin-nim
cd wpspin-nim/
make
sudo make install
```

### Installing on older versions of Debian/Ubuntu
Download universal Linux executable from the [releases](https://github.com/drygdryg/wpspin-nim/releases)

### Installing on Arch Linux or Manjaro
![AUR version](https://img.shields.io/aur/version/wpspin)
```
yay -S wpspin
```

### Installing on [Termux](https://play.google.com/store/apps/details?id=com.termux)
```
pkg install nim
git clone https://github.com/drygdryg/wpspin-nim
cd wpspin-nim/
make && make install
```

### Installing on Windows
Download Windows executable from the [releases](https://github.com/drygdryg/wpspin-nim/releases)

### Installing with Nimble (platform-independent)
```
nimble install wpspin
```

## Usage
Basic usage
```
wpspin 60:A4:4C:D0:D5:80
```
To generate all PIN codes in addition to the suggested ones use `-A`
```
wpspin -A 60:A4:4C:D0:D5:80
```
To use algorithms for testing use `-T`
```
wpspin -A -T 60:A4:4C:D0:D5:80
```
*More detailed usage: `wpspin --help`*

## Credits
3WiFi offline WPS PIN generator: https://3wifi.stascorp.com/wpspin