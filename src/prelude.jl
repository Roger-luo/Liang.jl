module Prelude

import Liang.Match: @match
import Liang.Data.Prelude as DataPrelude
import Liang.Expression.Prelude as ExpressionPrelude

for name in names(DataPrelude)
    name == :Prelude && continue
    @eval begin
        using .DataPrelude: $name
        export $name
    end
end

for name in names(ExpressionPrelude)
    name == :Prelude && continue
    @eval begin
        using .ExpressionPrelude: $name
        export $name
    end
end

end # module
