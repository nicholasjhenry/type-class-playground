defmodule TypeClassPlayground.MapTest do
  @moduledoc """
  `map` is the generic name for something that takes a function in the normal world and transforms
  it into a corresponding function in the elevated world.

  Common Names: `map`, `fmap`, `lift`, `Select`
  Common Operators: `<$>` `<!>`
  What it does: Lifts a function into the elevated world
  Signature: `(a->b) -> E<a> -> E<b>`. Alternatively with the parameters reversed: `E<a> -> (a->b) -> E<b>`

  > Consequently, I prefer to talk about “mappable” worlds. In practical programming, you will
    almost never run into a elevated world that does not support being mapped over somehow.

  Functor == Mappable

  https://fsharpforfunandprofit.com/posts/elevated-world/#map
  """

  use ExUnit.Case

  test "map for option" do
    map_option = fn opt, f ->
      case opt do
        :nothing -> :nothing
        {:some, x} -> {:some, f.(x)}
      end
    end

    assert {:some, 2} == map_option.({:some, 1}, &(&1 + 1))
    assert :nothing == map_option.(:nothing, &(&1 + 1))
  end
end
