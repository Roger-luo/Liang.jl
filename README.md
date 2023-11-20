# Liang

The universal emulator

**Disclaimer** This is in a very early stage of development. The package is not expected
to be used by anyone other than the author. I make it public only to make a few things clear
legally due to some personal changes in the near future.

## Installation

<p>
Liang is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package. To install Liang,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press <kbd>]</kbd>
    key in the REPL to use the package mode, then type the following command
</p>

```julia
pkg> add Liang
```

## Acknowledgement

This package is inspired by the following projects:

- Yao & QuSpin: the major starting point of this package.
- QuTiP & QuanutmOptics: helped us understand better the use cases of the package.
- Symbolics: the rewrite engine and the symbolic data structure are largely inspired by Symbolics and my conversation with Yingbo Ma.
- OMEinsum: the tensor network contraction engine is largely inspired by OMEinsum's contraction tree.

## License

MIT License
