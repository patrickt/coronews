# coronews

[![Hackage](https://img.shields.io/hackage/v/coronews.svg?logo=haskell)](https://hackage.haskell.org/package/coronews)
[![GPL-3 license](https://img.shields.io/badge/license-GPL--3-blue.svg)](LICENSE)

CLI interface to COVID-19 stats API. Features handsome colored output.

```
~ $ coronews
Confirmed: 372563
Recovered: 100885
Deaths:    16377
Updated:   Mon, 23 Mar 2020 18:55:06 UTC
```

# Compilation

1. Download [`ghcup`](https://www.haskell.org/ghcup/).
2. `ghcup set 8.8`
3. Download the repo.
4. `cabal build && cabal install`
