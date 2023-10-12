function emit(info::EmitInfo)
    quote
        let $(info.value_holder) = $(info.value)
            if cond
                body
                @goto $(info.final_label)
            end
        end
        @label $(info.final_label)
    end
end
