# Operator Expression

```bnf
<op> ::= <literal>
    | <variable>
    | <add>
    | <mul>
    | <kron>
    | <comm>
    | <acomm>
    | <pow>
    | <adjoint>
    | <subscript>
    | <reduction>
    | <call>
    | <outer>
    | <fn>
    | <annotation>
    | <identity>
    | <intrinsic>

<add> ::= <scalar> '*' <identity> '+' (<scalar> '*' <op>)*

<mul> ::= '*' <op> <op>+

<kron> ::= 'kron' <op> <op>+

<comm> ::= 'comm' <group element> <op> <index>
<acomm> ::= 'acomm' <group element> <op> <index>
<group element> ::= <op>

<pow> ::= <pow kind> <op> '^' <int>
<pow kind> ::= 'kron' | '*'

<adjoint> ::= 'adjoint' <op>

<subscript> ::= <op> '[' <index> (',' <index>)* ']'
<index> ::= <int> | <variable>

<reduction> ::= <reduce kind> '{' <variable> '}' <region> <subscript>
<reduce kind> ::= 'sum' | 'prod'
<region> ::= <lattice lang>

<call> ::= <primtive fn> <op>+
<primtive fn> ::= 'exp' | 'tr' | 'det' | 'inv' | 'sqrt' | 'transpose'

<outer> ::= 'outer' <state> <state>

<fn> ::= <ident> '(' <ident> (',' <ident>)* ')' '=' <op>

<annotation> ::= <op> '::' <info>
<info> ::= <basis> | <unit>

<literal> ::= <pauli string>
    | <permutation>
    | <creation>
<pauli string> ::= <int8>+
<permutation> ::= 'P' <int> <complex>+ <int>+

<identity> ::= 'I'
<variable> ::= <ident>
<alis>     ::= <ident> <op>
```

## Addition

Operator addition is communitive and associative, and thus
can be flattened into a list of operators with coefficients.

This can be stored more efficiently as a dictionary with keys
as the operator expression and values as the coefficients, with
identity operator special cased.

We allow the list of non-identity operators to be empty to represent
uniform scaling operator, so that no special case required for scalar
multiplication, and such multiplication can reuse the same canonicalization
rules as addition.

The coefficients are represented by the [scalar expression](scalar.md).

### Canonicalization

Nested addition can be flattened into a single addition.

## Multiplication & Kronecker Product

Kronecker product is a special case of operator multiplication,
and operator multiplication is not commutative but is associative, thus
we can flatten the expression into a list of operators.

## Commutator

The commutator is not associative or commutative, thus we can only
store it as a tuple of two operators, e.g using Lie-algebra identity

$$
[A, [B, C]] = [[C, A], B] + [[A, B], C]
$$

The commutator expression is defined as the power of the commutator
$\text{adj}_{A}^n$ this is because commutator power requires three
fields: the group element, the exponent and the operator.

### Canonicalization

Commutator with the same group element can be merged into a single
commutator expression.

## Anticommutator

Anticommutators are commutative, but not associative, thus we
can only store them as a tuple of two operators.

$$
\begin{aligned}
A \circ (B \circ C) &= A \circ (BC + CB)\\
&= ABC + ACB + BCA + CBA\\
\neq (A\circ B)\circ C &= ABC + BAC + CAB + CBA\\
\neq B\circ (A \circ C) &= B \circ (AC + CA)\\
&= BAC + BCA + ACB + CAB\\
=(C\circ B)\circ A
\end{aligned}
$$

The anti-commutator expression is defined as the power of the anti-commutator
similarly to the commutator.

### Canonicalization

Anticommutator with the same group element can be merged into a single
anticommutator expression.

## Power

Power is defined as a special case of multiplication operator,
where all the operators are the same, and thus can be stored
as a tuple of the operator and the exponent based on the kind of power,
we support the following power expression:

- `kron` power: $A^{\otimes n}$
- `*` power: $A^{n}$

### Canonicalization

the same kind multiplication of power can be flattened into a single power $A^{i} A^{j} = A^{i+j}$

## Adjoint

Adjoint is a special call expression that creates the adjoint $A \rightarrow A^{\dagger}$.

### Canonicalization

The adjoint operator cancels itself out, thus we always propgate the adjoint
operation to the child operator, and thus evenly nested adjoint operator gets
cancelled out.

## Subscript

Subscript is used to represent tensor product of operators, it's
a sparse version of Kronecker product, and is communitive if the
subscripts are different.

```
[A, B]_[1, 2] == A_[1] * B_[2] == kron(A, B)_[1, 2]
```

subscript can be nested, e.g

```
(A_[1] * B_[2])_[3, 2] * C_[3] == (A * C)_[3] * B_[2]
```

nested subscript is useful when calling external operator definitions where
the subscripts are pre-defined in a local location. Then user can use nested
subscript to re-map the subscripts to the desired order.

thus the subscript can be stored as a dictionary with keys as
the subscript and values as the operator, where the child operator
should not contain `kron` or `subscript` anymore.

Subscript should not appear with `kron` with `*`, e.g the following expression
is invalid:

```
A_[1] * kron(B, C)
```

### Canonicalization

The same subscript multiplied together can be merged into a single subscript
with values being the multiplication of the operators.

The nested subscript can be flattened into a single subscript with the
subscripts being re-mapped to the new subscript.

The subscript on kronecker product can be flattened into a subscript
on the child operator of kronecker product.

## Reduction

Reduction can be think of as the inverse of subscript context, it cancels
subscript by filling them in a geometric space, and thus re-store the dense
operator representation, e.g reduction expression can appear with `kron` or `*`
but cannot appear with `subscript` in a multiplication.

The region specification can be found in the [region expression](./region.md).

### Canonicalization

Nested reduction can be flattened into a single reduction, e.g

$$
\begin{aligned}
\sum_{i} \sum_{j} A_{i, j} &= \sum_{i, j} A_{i, j}\\
\prod_{i} \prod_{j} A_{i, j} &= \prod_{i, j} A_{i, j}
\end{aligned}
$$

except for cases where the reduction has dependencies, e.g

$$
\sum_{i} \sum_{j} A_{i, j} \sum_{k=1}^{j} B_{i, k}
$$

this require analysis of the region specification, and thus cannot be
flattened into a single reduction, we will just keep it as is.

## Calls

The call expression is only supported for primitive functions, one cannot
define a custom function or callable operator in the DSL, this is because
host language usually provides a better way to define functions, and the input
arguments of a given operator are usually scalars, which is not primarily supported by
this DSL.

Thus all callable expressions are treated as primitive functions, and special cases
in the compiler.

## Outer Product

Outer product is a way to build an operator from state expressions. It is defined as
a tuple of two [state expressions](state.md), e.g

$$
\ket{a}\bra{b}
$$

### Canonicalization

The outer product of a state and an addition of states can be flattened into
an addition of outer product, e.g

$$
\ket{lhs}(\bra{rhs_1} + \bra{rhs_2}) = \ket{lhs}\bra{rhs_1} + \ket{lhs}\bra{rhs_2}
$$

and similarly

$$
(\ket{lhs_1} + \ket{lhs_2})\bra{rhs} = \ket{lhs_1}\bra{rhs} + \ket{lhs_2}\bra{rhs}
$$

## Annotation

Annotations are used to store additional information about the operator,
this currently includes the following:

- `basis`: the basis of the operator, can be found in the [basis](basis.md) section
- `unit`: the unit of the operator, can be found in the [unit](unit.md) section, e.g $\text{Hz}$ for Hamiltonian

### Implicit conversion

Similar to Julia's type annotation, nested annotation implies the conversion of basis
or unit. This is because one may call an external operator expression that has a 
different basis or unit, thus the user can annotate the operator with the desired
basis or unit.

## Identity

Identity operator is special-cased because notation-wise it is usually used
as a placeholder for arbitrary-size identity operator. Thus it is always equivalent
to a `kron` expression with `n` identity operators or $I^{\otimes n}$

### Canonicalization

**Identity operator annotated with basis**: the kronecker product of such
identity expression should be merged into a single identity expression with
the basis being the union of the basis of the identity operators.

**Identity operator annotated with unit**: the kronecker product of such
identity expression should be merged into a single identity expression with
the unit being the union of the unit of the identity operators.

**Identity operator with subscript**: the product of such
identity expression should be merged into a single identity expression with
the subscript being the union of the subscript of the identity operators.

**Identity operator with sum**: the reduction should be lifted to an
addition expression.

### Validation

**Identity operator without annotation**: the kronecker product of such
identity is invalid, one should use subscript instead.

## Index

The index expression is used to represent the index of a given operator,
it is either an integer or a variable that will have an integer value. This
is a special scalar value that will only appear in the operator expression.

## Variables

Variables are defined as a symbol, and can be used as a placeholder for
anything that is available in the [main expression](main.md). The compiler
should analyze the main expression to determine the type of the variable
before analyzing the operator expression.

## Alias

Alias is a way to define a new operator expression that can be used in the
operator expression. This is useful when one wants to define a new operator
that is not a primitive operator, e.g

```
H = exp(-im*pi/2 * X)
```

one can create fundamental operators using the literals.

## Operator function/Parametric operator

An operator function is defined by:

- a name (optional).
- a list of parameters.
- a body expression that must be operator expression.

this semantic is not designed to create arbitrary function
that can return arbitrary expression, but rather to create
parametric operators that can be used in the operator
expression.

More complicated function syntax should be defined in
the host language using host language's function syntax.


## Literals

### OpString

The a list of `UInt8` that means a chain of tensor product of:

- 0,1,2,3 - `I`, `X`, `Y`, `Z`
- 4,5 - 'a', 'a^{\dagger}'

### Permutation Sum

and for any operator on discrete basis,
we can define it as a weighted sum of permutation

$$
O = \sum_i w_i P_i
$$

The permutation sum is described by

- a list of `Int8` that describes the permutation index
- a list of weight in [scalar](scalar.md) that describes the weight of each permutation
- an integer that denotes the number of sites

The choice of `UInt8` is because we are not expecting permutation
group size to be arbitrary long during compilation and for creating
fundamental operators, thus we can use `UInt8` to save space.

For cases where one wants to create larger permutation group, one can
instead use the subscript expression and the `X` operator to create
larger permutation group that will not be evaluated during compilation.

### Examples

We can represent rotation on different axis as an operator function

```
Rx(theta) = exp(-i theta/2 * X)
Ry(theta) = exp(-i theta/2 * Y)
Rz(theta) = exp(-i theta/2 * Z)
```

this as a composition can define arbitrary operators, then we can define
a standard library of operators such as `H`, `CNOT`, etc. and special case
them as a built-in pattern in the compiler.

And for some operators, permutation group is an easier way to define them,
because this is basically just specifying the matrix elements of the operator
in COO format, and because we restrict the permutation sum literal to have
`UInt8` as the index type, the maximum size of such literal is 4-site, which
is enough for most cases.

### Side note

Implementation-wise, we still allow a set of special cases to be defined
for simplicity, e.g annilation operators and variable names such as `X`, `Y`, `Z`
are reserved as a short-path for compilation.

TODO: special intrinsic operator that contains implicit basis,
this is mainly because the following operators are not defined
generic basis, but rather defined in a specific basis, e.g

```
x # positional
p # momentum
```
