module Prelude

import Liang.Match: @match
import Liang.Data.Prelude as DataPrelude
import Liang.Expression.Prelude as ExpressionPrelude
import Liang.Syntax.Prelude as SyntaxPrelude
using Liang.Tree: Print
using Liang.Canonicalize: canonicalize

export canonicalize, Print
for mod in [:DataPrelude, :ExpressionPrelude, :SyntaxPrelude]
    for name in names(getproperty(Prelude, mod))
        name == :Prelude && continue
        @eval begin
            using .$mod: $name
            export $name
        end
    end
end

end # module
