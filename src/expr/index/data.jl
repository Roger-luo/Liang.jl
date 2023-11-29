@data Index begin
    Inf
    Constant(Int)
    Variable(Variable.Type)

    struct Add
        coeffs::Int
        terms::ACSet{Index,Int}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Mul
        coeffs::Int
        terms::ACSet{Index,Int}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Div
        num::Index
        den::Index
    end

    struct Pow
        base::Index
        exp::Index
    end

    struct Rem
        base::Index
        mod::Index
    end

    struct Max
        terms::Set{Index}
        hash::Hash.Cache = Hash.Cache()
    end

    struct Min
        terms::Set{Index}
        hash::Hash.Cache = Hash.Cache()
    end

    Abs(Index)

    # a special variable referring
    # to an `n_sites` call on operator
    # expression
    NSites(Variable.Type)
    AssertEqual(Index, Index, String)
end

@derive Index[PartialEq, Hash, Tree]
