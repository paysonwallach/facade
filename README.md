<div align="center">
  <h1>Façade</h1>
  <br>
  <p>Set Gtk theme variants by window class.</p>
  <a href=https://github.com/paysonwallach/facade/release/latest>
    <img src=https://img.shields.io/github/v/release/paysonwallach/facade?style=flat-square>
  </a>
  <a href=https://github.com/paysonwallach/facade/blob/master/LICENSE>
    <img src=https://img.shields.io/github/license/paysonwallach/facade?style=flat-square>
  </a>
  <a href=https://buymeacoffee.com/paysonwallach>
    <img src=https://img.shields.io/badge/donate-Buy%20me%20a%20coffe-yellow?style=flat-square>
  </a>
  <br>
  <br>
</div>

[Façade](https://github.com/paysonwallach/facade) is a small service that lets you set Gtk theme variants on windows by their Xorg `WM_CLASS` properties.

## Installation

### From source using [`meson`](http://mesonbuild.com/)

Clone this repository or download the [latest release](https://github.com/paysonwallach/facade/releases/latest).

```sh
git clone https://github.com/paysonwallach/facade.git
```

Configure the build directory at the root of the project.

```sh
meson --prefix=/usr build
```

Install with `ninja`.

```sh
ninja -C build install
```

You'll probably want to set [Façade](https://github.com/paysonwallach/facade) to launch on login as well.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Code of Conduct

By participating in this project, you agree to abide by the terms of the [Code of Conduct](https://github.com/paysonwallach/facade/blob/master/CODE_OF_CONDUCT.md).

## License

[Façade](https://github.com/paysonwallach/facade) is licensed under the [GNU Public License v3.0](https://github.com/paysonwallach/facade/blob/master/LICENSE).
