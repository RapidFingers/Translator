[![Build Status](https://travis-ci.com/RapidFingers/Translator.svg?branch=master)](https://travis-ci.com/RapidFingers/Translator)

<p align="center">
  <a href="https://appcenter.elementary.io/com.github.rapidfingers.translator">
    <img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter">
  </a>
</p>

# Summary
Native Elementary OS translater app. Uses Yandex API.
* Simple
* Fast
* Beautiful :)

![Screenshot](https://raw.githubusercontent.com/rapidfingers/translator/master/data/screenshots/screenshot1.png)

## Building from source

First you will need to install elementary SDK

 `sudo apt install elementary-sdk`
 
 ### Dependencies

These dependencies must be present before building
 - `valac`
 - `granite`
 - `gtk+-3.0`
 - `libsoup2.4`
 - `libgee-0.8`
 - `libjson-glib`
 
 ### Building
```
meson build --prefix=/usr
cd build
ninja
```

### Installing
`sudo ninja install`
 

## Arch Linux
Arch Linux users can find Translator under the name [translator-git](https://aur.archlinux.org/packages/translator-git/) in the **AUR**:

`$ aurman -S translator-git`

# Donate


## MIT License
Copyright 2019 Grabli66

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
