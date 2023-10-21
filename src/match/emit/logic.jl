function decons_and(info::PatternInfo, pat::Pattern.Type)
    return function and(value)
        return quote
            $(decons(info, pat.:1)(value)) && $(decons(info, pat.:2)(value))
        end
    end
end

function decons_or(info::PatternInfo, pat::Pattern.Type)
    return function or(value)
        return quote
            $(decons(info, pat.:1)(value)) || $(decons(info, pat.:2)(value))
        end
    end
end
