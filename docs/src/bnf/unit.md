# Unit

The unit expression is defined as follows

```bnf
<unit> ::= <const> | <arith>
<arith> ::= <unary> <unit>
    | <binary> <unit> <unit>
    | 'pow' <unit> <int>
<unary> ::= 'inv' | 'sqrt'
<binary> ::= '*' | '/'
<const> ::= 'm'
    | 'nm'
    | 'mm'
    | 'cm'
    | 'km'
    | 's'
    | 'ns'
    | 'ms'
    | 'us'
    | 'Hz'
    | 'kHz'
    | 'MHz'
    | 'GHz'
    | 'THz'
    | 'rad'
    | 'deg'
    | 'eV'
    | 'meV'
    | 'keV'
    | 'GeV'
    | 'T'
    | 'mT'
    | 'uT'
    | 'nT'
    | 'G'
    | 'mG'
    | 'uG'
    | 'nG'
    | 'A'
    | 'mA'
    | 'uA'
    | 'nA'
```

## Reference

- https://dataprotocols.org/json-table-schema/
- https://www.qudt.org/
- https://ucum.org/ucum#para-44
