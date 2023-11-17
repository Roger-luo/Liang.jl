# Scalars

The scalar expression is used to represent a single scalar or a list of scalar value,
a list of scalar value do not impose any linear algebra structure on the expression,
the scalar expression is defined as follows

```bnf
<scalar> ::= <literal>
    | <binop>
    | <unop>
    | <call>
    | <fn>
    | <variable>
    | <annotate>
<binop> ::= <add> | <mul> | <div> | <pow>
<add> ::= <literal> '*' <scalar> ('+' <literal> '*' <scalar>)*
<mul> ::= <scalar> '^' <literal> ('*' <scalar> '^' <literal>)*
<div> ::= <scalar> '/' <scalar>
<pow> ::= <scalar> '^' <scalar>

<unop> ::= <neg> | <abs>
<neg> ::= '-' <scalar>
<abs> ::= 'abs' <scalar>

<literal> ::= <real> | <complex> | <irrational>
<real> ::= <int> | <float>
<complex> ::= <real> <real>
<irrational> ::= 'pi' | 'e'

<call> ::= <ident> <scalar>*
<fn> ::= <ident> '(' <ident>* ')' '=' <scalar>
<variable> ::= <ident>

<annotate> ::= <scalar> '::' <info>
<info> ::= <unit> | <domain>
<domain> ::= 'complex' | 'real'
```

## Literal

The literal is a single scalar value, it can be a real number, a complex number or
an irrational number.

- real number can be an integer or a floating point number
- complex number is a pair of real number
- irrational number is a special number that cannot be represented by a finite
  decimal expansion, e.g `pi` and `e`

note the name `real` or `complex` do not imply the domain of the scalar, it is
just a name to distinguish the different types of scalar. The domain of scalar
should be denoted by the annotation or inferred.

## Binary operation

The binary operation is a binary operation between two scalar values, e.g `1/2 * 2`.

- The binary operation `*` and `+` is communitative and associative, thus we can store them in a dictionary with the scalar as the key and the coefficient as the value.
- The binary operation `^` and `/` is not communitative and associative, thus we just store a tuple of the two scalar values.

## Unary operation

The unary operation is a unary operation on a scalar value, e.g `-1` or `abs(-1)`.
The absolute value is used here because we have operations that can return an absolute
value, e.g norm of an operator expression.

## Call expression

The call expression is a scalar expression that calls a builtin function or a function expression with known return types e.g `sin(1)` is a builtin expression where the evaluation needs to be done by calling the host langauge implementation.

## Function expression

The function expression is a scalar expression that calls a function defined in the
expression, e.g `f(x) = x^2` is a function expression that defines a function `f`
that can be called elsewhere in the expression.

Unlike normal functions, the function expression can only be called with a single scalar expression body, and cannot have function definition inside. More complicated
function definition should be done in the host langauge and pass as variable value
at runtime.

## Variable expression

Variable expression is a placeholder for a scalar value, it is analyzed in the [main expression](main.md) and lifted as a variable declaration.

## Annotation

The annotation is used to annotate the scalar expression with additional information, e.g `1 :: unit[Hz]` is a scalar expression with a unit annotation. Supported annotations are:

- [unit](unit.md)
- domain: `complex` or `real`
