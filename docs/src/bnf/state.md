# State expression

The state is a description of an element in the provided space, e.g in the `qubit` 
space, a state is a superposition of product state with configuration on `0` and `1`.
The state expression is defined as follows

```bnf
<state> ::= <product>
    | <kron>
    | <add>
    | <binop>
    | <eigen>
    | <intrinsic>
    | <annotate>
<product> ::= 'product' <config>+
<kron> ::= 'kron' <state> <state>+
<add> ::= <scalar> '*' <state> ('+' <scalar> '*' <state>)*
<eigen> ::= 'eigen' <op> <int>
<annotate> ::= <state> '::' <info>
<info> ::= <basis>

<config> ::= <int>
    | <real>
    | <complex>
<complex> ::= <real> <real>

# these actually live on fock space
<intrinsic> ::= <gaussian>
    | <coherent>
    | <gkp>
    | <homonic ossilator>
```

## Product state

The product state is a string of configuration, e.g in the `qubit` space, a product
state is a string of `0` and `1`, e.g `0101` is a product state. The configuration
can be extended for other spaces, e.g gaussian state can be a string of `(real, real)`.

## Kronecker product

The kronecker product is a binary operation that takes two states and returns a
state that is the kronecker product of the two states.

### Canonicalization

Kronecker product of two product state should be canonicalized to a single product
state, e.g `kron(product(0, 1), product(0, 1))` should be canonicalized to
`product(0, 0, 1, 1)`.

## Binary operation

The binary operation can be a summation or a substraction of two states, e.g
`1/2 * state1 + 1/2 * state2`. These binary operations between two states are
communitative and associative, thus we can store them in a dictionary with the
state as the key and the coefficient as the value. The coefficient is specified
by the [scalar expression](scalar.md).

### Canonicalization

Nested binary state of the same kind should be canonicalized to a single binary
state.

## Eigen state

The eigen state is a state that is the eigen state of [an operator](op.md), e.g `eigen(sigmax, 0)` is the first eigen state of `sigmax`, where the order of the eigen state is defined by the absolute value of the eigen value.

## Annotation

The annotation is a way to annotate a state with additional information, currently
the only supported annotation is the [basis](basis.md), e.g `state :: basis`.
