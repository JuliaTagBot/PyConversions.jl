
"""
    @pywith context symbol block

This is a python context-manager block.  The above is equivalent to
```python
with context as symbol:
    block
```
in Python. 

___TODO:___ Currently this doesn't handle exceptions the way it's supposed to due to Python
and Julia having different scoping rules for their `try`, `catch` blocks.  Making this work
correctly would require a somewhat complicated macro that looked for all assignments in the
block and repeated them after the `try` construct.
"""
macro pywith(context, as::Symbol, block::Expr)
    # is it possible to escape only portions of the output, or do I have to do this?
    sys = gensym()
    mgr = gensym()
    exit = gensym()
    value = gensym()
    esc(quote
        @pyimport sys as $sys
        $mgr = $context
        $exit = pytypeof($mgr)[:__exit__]
        $value = pytypeof($mgr)[:__enter__]($mgr)
        let $as = $value
            $block
        end
        $exit($mgr, $sys.exc_info()...)
    end)
end

macro pywith(context, block::Expr)
    sys = gensym()
    mgr = gensym()
    exit = gensym()
    esc(quote
        @pyimport sys
        $mgr = $context
        $exit = pytypeof($mgr)[:__exit__]
        pytypeof($mgr)[:__enter__]($mgr)
        $block
        $exit($mgr, sys.exc_info()...)
    end)
end
export @pywith

