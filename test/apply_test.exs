defmodule TypeClassPlayground.ApplyTest do
  @moduledoc """
  `apply` unpacks a function wrapped inside a elevated value (E<(a->b)>) into a
  lifted function E<a> -> E<b>.

  Common Names: `apply`, `ap`
  Common Operators: `<*>`
  What it does: Unpacks a function wrapped inside a elevated value into a
    lifted function E<a> -> E<b>.

  Signature: E<(a->b)> -> E<a> -> E<b>
  """

  use ExUnit.Case

  import Kernel, except: [apply: 2]

  def apply(fopt, xopt) do
    use Currying

    with {:some, f} <- fopt,
         {:some, x} <- xopt do
      {:some, curry(f).(x)}
    else
      _ -> :none
    end
  end

  # Based on Witchcraft: https://github.com/expede/witchcraft#operators
  def fun <<~ argument do
    apply(fun, argument)
  end

  test "applying a function" do
    result = apply({:some, fn x -> x + 1 end}, {:some, 2})
    assert {:some, 3} = result
  end

  test "currying apply and infix operator" do
    add = fn a, b, c -> a + b + c end
    result = {:some, add} <<~ {:some, 2} <<~ {:some, 3} <<~ {:some, 4}
    assert result == {:some, 9}
  end
end
