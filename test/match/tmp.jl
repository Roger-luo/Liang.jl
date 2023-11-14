begin
    #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:17 =#
    var"##value#327" = x
    #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:18 =#
    begin
        begin
            #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:7 =#
            if begin
                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:5 =#
                var"##value#330" = var"##value#327"
                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:6 =#
                begin
                    #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:47 =#
                    var"##value#331" = var"##value#330"
                    #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:48 =#
                    (Liang.Data).isa_variant(
                        var"##value#331", Liang.Expression.Scalar.Sum
                    ) && (
                        begin
                            #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:26 =#
                            true && begin
                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:5 =#
                                var"##value#332" = (Base).getproperty(var"##value#331", 1)
                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:6 =#
                                begin
                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/leafs.jl:15 =#
                                    var"##333" = var"##value#332"
                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/leafs.jl:16 =#
                                    true
                                end
                            end
                        end && begin
                            #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:26 =#
                            true && begin
                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:5 =#
                                var"##value#334" = (Base).getproperty(var"##value#331", :terms)
                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:6 =#
                                begin
                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:47 =#
                                    var"##value#335" = var"##value#334"
                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:48 =#
                                    var"##value#335" isa Dict && (
                                        begin
                                            #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:26 =#
                                            true && begin
                                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:5 =#
                                                var"##value#336" = (Core).getfield(
                                                    var"##value#335", 1
                                                )
                                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:6 =#
                                                begin
                                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:47 =#
                                                    var"##value#337" = var"##value#336"
                                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:48 =#
                                                    var"##value#337" isa Pair && (
                                                        begin
                                                            #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:26 =#
                                                            begin
                                                                #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:26 =#
                                                                true &&
                                                                    begin
                                                                        #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:5 =#
                                                                        var"##value#338" = (
                                                                            Core
                                                                        ).getfield(
                                                                            var"##value#337",
                                                                            1,
                                                                        )
                                                                        #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:6 =#
                                                                        begin
                                                                            #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:47 =#
                                                                            var"##value#339" =
                                                                                var"##value#338"
                                                                            #= /Users/roger/Code/Julia/Liang/src/match/emit/call.jl:48 =#
                                                                            (
                                                                                Liang.Data
                                                                            ).isa_variant(
                                                                                var"##value#339",
                                                                                Liang.Expression.Scalar.Constant,
                                                                            ) &&
                                                                                (
                                                                                    begin
                                                                                        #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:26 =#
                                                                                        true &&
                                                                                            begin
                                                                                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:5 =#
                                                                                                var"##value#340" = (
                                                                                                    Base
                                                                                                ).getproperty(
                                                                                                    var"##value#339",
                                                                                                    1,
                                                                                                )
                                                                                                #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:6 =#
                                                                                                begin
                                                                                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/leafs.jl:24 =#
                                                                                                    var"##value#340" ==
                                                                                                    1.0
                                                                                                end
                                                                                            end
                                                                                    end &&
                                                                                    true
                                                                                )
                                                                        end
                                                                    end
                                                            end &&
                                                                begin
                                                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:5 =#
                                                                    var"##value#341" = (
                                                                        Core
                                                                    ).getfield(
                                                                        var"##value#337",
                                                                        2,
                                                                    )
                                                                    #= /Users/roger/Code/Julia/Liang/src/match/emit/decons.jl:6 =#
                                                                    begin
                                                                        #= /Users/roger/Code/Julia/Liang/src/match/emit/leafs.jl:15 =#
                                                                        var"##342" =
                                                                            var"##value#341"
                                                                        #= /Users/roger/Code/Julia/Liang/src/match/emit/leafs.jl:16 =#
                                                                        true
                                                                    end
                                                                end
                                                        end && true
                                                    )
                                                end
                                            end
                                        end && true
                                    )
                                end
                            end
                        end
                    )
                end
            end && true
                #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:8 =#
                var"##return#329" = let a = var"##342", coeffs = var"##333"
                    #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:9 =#
                    a
                end
                #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:11 =#
                $(Expr(:symbolicgoto, Symbol("##final#328")))
            end
        end
    end
    #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:19 =#
    error("matching non-exhaustic")
    #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:20 =#
    $(Expr(:symboliclabel, Symbol("##final#328")))
    #= /Users/roger/Code/Julia/Liang/src/match/emit/mod.jl:21 =#
    var"##return#329"
end
