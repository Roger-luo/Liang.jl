# Basis expression

the basis expression is defined as follows

```bnf
<basis> ::= <op> <space>
<space> ::= 'qubit'
    | 'qudit' <int>
    | 'spin' <int>
    | 'fock'
    | <product>
    | <subspace>
<subspace> ::= <space> <int>+
<product> ::= 'product' <space>+
```

A basis expression is a combination of a operator and a space, the operator eigenvalues
describe the eigen-basis on the corresponding space, the space is used to specify the 
size and type of space. For example, the `qubit` space is a two dimensional space, and
we can define an `X`-basis on the `qubit` space as

```
basis(X, qubit)
```

## Discrete Space

The space currently includes the following types:

### Qubit

a two dimensional space, the eigenvalues of the operator is `0` and `1`.

### Qudit

a `n` dimensional space, the eigenvalues of the operator is `0` to `n-1`.

### Spin

a `2n+1` dimensional space, the eigenvalues of the operator is `-n` to `n`.

### TODO: Fermion

a `n` dimensional space, the eigenvalues of the operator is `0` to `n-1`.

### TODO: Anyon

a `n` dimensional space, the eigenvalues of the operator is `0` to `n-1`.

## Continuous Space

Reference:

- [Gaussian states](https://strawberryfields.ai/photonics/conventions/states.html)

### Coherent

a continuous space on parameter `alpha`. The corresponding operator is a displaced displacement operator $D(\alpha)$. It is the eigen-basis of the annihilation operator $a$.

It has the following decomposition in fock basis:

$$
\ket{\alpha} = e^{-|\alpha|^2/2} \sum_{n=0}^{\infty} \frac{\alpha^n}{\sqrt{n!}} \ket{n}
$$

### Fock space

Fock space is an infinite dimensional space. The configuration goes from `0` to `+inf`.

### TODO: Gaussian
### TODO: GKP

## Product Space

A product space is a combination of multiple spaces, the eigenvalues of the operator is a tuple of eigenvalues of the corresponding spaces.

## Subspace

### Discrete Subspace

A discrete subspace is a subspace of a discrete space, the eigenvalues of the operator is a subset of the eigenvalues of the corresponding space. This is described by a list of integers.

### TODO: Generic Subspace

A generic subspace is a collection of states.

|gkp(r)>::gkp
