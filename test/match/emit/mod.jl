using Liang.Match: @match, EmitInfo

info = EmitInfo(
    Main,
    Float64,
    quote
        1 => "hi"
        Float64 => "hello"
    end,
)

blk = quote
    1 => "hi"
    Float64 => "hello"
end

@match Float64 $Float64 => "hello"

@match Float64 begin
    1 => "hi"
    Float64 => "hello"
end

@match Float64 begin
    1 => "hello"
    Tuple{Int64} => "hi"
end

Float64 === 1
