defmodule TypeClassPlayground.ReturnTest do
  @moduledoc """
  `return` (also known as `unit` or `pure`) simply creates a elevated value from a normal value.

  Common Names: `return`, `pure`, `unit`, `yield`, `point`
  Common Operators: None
  What it does: Lifts a single value into the elevated world
  Signature: `a -> E<a>`

  https://fsharpforfunandprofit.com/posts/elevated-world/#return
  """
  use ExUnit.Case

  test "return an option" do
    return_option = fn x -> {:some, x} end

    assert {:some, :foo} == return_option.(:foo)
  end
end
