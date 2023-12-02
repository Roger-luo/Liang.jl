using Liang.Match: @match

@match Float64 begin
    Int64 => "hi"
    Float64 => "hello"
end

@match Float64 begin
    Tuple{Int64} => "hi"
    Float64 => "hello"
end
