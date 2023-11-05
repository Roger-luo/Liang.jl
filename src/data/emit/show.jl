@pass function emit_show_variant(info::EmitInfo)
    return quote
        function $Base.show(io::IO, x::$(info.type.variant))
            $Data.show_variant(io, x)
        end

        function $Base.show(io::IO, mime::$(MIME"text/plain"), x::$(info.type.variant))
            $Data.show_variant(io, mime, x)
        end
    end
end

@pass function emit_show_data(info::EmitInfo)
    return quote
        function $Base.show(io::IO, x::$(info.type.name))
            $Data.show_data(io, x)
        end

        function $Base.show(io::IO, mime::$(MIME"text/plain"), x::$(info.type.name))
            $Data.show_data(io, mime, x)
        end
    end
end
