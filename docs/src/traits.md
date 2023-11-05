# Notes on using Traits

We simulate traits in Julia by defining a module of functions that can be
overloaded externally. For example, the following is the definition of the
`PartialEq` trait

```julia
module PartialEq
eq(lhs, rhs) = not_implemented()
ne(lhs, rhs) = not_implemented()
end
```

The `not_implemented` function is defined in the `err` module and throws an
error when called. The reason why we choose this approach instead of something
stricter like in rust is because in Julia we only loosely depend on a collection
of interfaces, e.g we don't always ask people to overload everything, and overload
only partial number of interface is totally fine. Thus unlike other approaches,
this approach is more flexible and useful in practice.

And we can even provide a Holy trait type in each module for dispatching purposes.
It might worth providing a utilitie macro to generate these definitions, e.g

```julia
@trait PartialEq begin
    eq(lhs, rhs) # call statement if not implemented
    ne(lhs, rhs) = !eq(lhs, rhs) # function definition if implemented
end
```

will generate

```julia
module PartialEq

eq(lhs, rhs) = not_implemented()
ne(lhs, rhs) = !eq(lhs, rhs)

end
```

and in terms of dispatch, developers should just check if their input object implements
the trait interface by calling it (Julia does not do static checking anyway)!

## Traits and Interfaces

A set of interfaces defined within a module is a trait. The module
should contain a set of holy-trait types that is used for dispatching. For example,

```julia
module PartialEq

abstract type Trait end
struct Full <: Trait end # all the interface is implemented
struct Some <: Trait end # some of the interface is implemented
struct None <: Trait end # none of the interface is implemented

@generated function Trait(self::Type)
    # checks if self is overloaded on all the interface
end

eq(lhs, rhs) = error("not implemented")
ne(lhs, rhs) = !eq(lhs, rhs)

end
```
