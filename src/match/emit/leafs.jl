function decons_wildcard(info::PatternInfo, pat::Pattern.Type)
    return function wildcard(value)
        return true
    end
end

function decons_variable(info::PatternInfo, pat::Pattern.Type)
    return function variable(value)
        # NOTE: this is used to create a scope
        # using let ... end later, so we cannot
        # directly assign it to the pattern variable
        placeholder = gensym()
        info[pat.:1] = placeholder
        return quote
            $(placeholder) = $value
            true
        end
    end
end

function decons_quote(info::PatternInfo, pat::Pattern.Type)
    return function _quote(value)
        return quote
            $value == $(pat.:1)
        end
    end
end

function decons_splat(view_type_check, info::PatternInfo, pat::Pattern.Type)
    function splat(value)
        if isa_variant(pat.body, Pattern.TypeAnnotate)
            type_check = view_type_check(value, pat.body.type)
            and_expr(type_check, decons(info, pat.body.body)(value))
        else
            decons(info, pat.body)(value)
        end
    end
end
