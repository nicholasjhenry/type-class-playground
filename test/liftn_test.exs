defmodule TypeClassPlayground.LiftnTest do
  @moduledoc """
  The `apply` and `return` functions can be used to define a series of helper functions `liftN`
  (`lift2`, `lift3`, `lift4`, etc) that take a normal function with N parameters
  (where N=2,3,4, etc) and transform it to a corresponding elevated function.

  Note that `lift1` is just map, and so it is not usually defined as a separate function.

  Common Names: `lift2`, `lift3`, `lift4` and similar
  Common Operators: None
  What it does: Combines two (or three, or four) elevated values using a specified function
  Signature: lift2: (a->b->c) -> E<a> -> E<b> -> E<c>,
             lift3: (a->b->c->d) -> E<a> -> E<b> -> E<c> -> E<d>,
             etc.

  https://fsharpforfunandprofit.com/posts/elevated-world/#lift
  """

  use ExUnit.Case

  defmodule Option do
    import Kernel, except: [apply: 2]

    use Currying

    def map(opt, f) do
      case opt do
        :nothing -> :nothing
        {:some, x} -> {:some, curry(f).(x)}
      end
    end

    # <!>
    def fun <|> opt do
      map(opt, fun)
    end

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

    def lift2(f, x, y) do
        f <|> x <<~ y
    end

    def lift3(f, x, y) do
        f <|> x <<~ y
    end

    def lift3(f, x, y, z) do
      f <|> x <<~ y <<~ z
    end
  end

  test "lift 2 " do
    # define a two-parameter function to test with
    add_pair = fn(x, y) -> x + y end

    # lift a two-param function
    result = Option.lift2(add_pair, {:some, 1}, {:some, 2})

    assert result == {:some, 3}
  end

  test "lift 3" do
    # define a three-parameter function to test with
    add_triple = fn(x, y, z) -> x + y + z end

    # lift a three-param function
    result = Option.lift3(add_triple, {:some, 1}, {:some, 2}, {:some, 3})

    assert result == {:some, 6}
  end
end
