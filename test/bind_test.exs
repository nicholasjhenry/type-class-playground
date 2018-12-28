defmodule TypeClassPlayground.BindTest do
  @moduledoc """
  We frequently have to deal with functions that cross between the normal world and the
  elevated world.

  What `bind` does is transform a world-crossing function (commonly known as a "monadic function")
  into a lifted function `E<a> -> E<b>`.

  Common Names: `bind`, `flatMap`, `andThen`, `collect`, `SelectMany`
  Common Operators: `>>=` (left to right), `=<<` (right to left)
  What it does:  Allows you to compose world-crossing ("monadic") functions
  Signature: `(a->E<b>) -> E<a> -> E<b>`. Alternatively with the parameters reversed:
    `E<a> -> (a->E<b>) -> E<b>`

  https://fsharpforfunandprofit.com/posts/elevated-world/#bind
  """
  use ExUnit.Case

  defmodule Option do
    defstruct value: nil, some: false

    def return do
      struct(__MODULE__)
    end

    def return(value) do
      struct(__MODULE__, value: value, some: true)
    end

    def bind(xopt, f) do
      case xopt.some do
        true -> f.(xopt.value)
        _ -> :none
      end
    end
  end

  # https://github.com/expede/witchcraft#haskell-translation-table
  def xopt >>> f do
    Option.bind(xopt, f)
  end

  def parse_int(string) do
    string
    |> String.to_integer()
    |> Option.return()
  rescue _ ->
    :none
  end

  defmodule OrderQty do
    defstruct value: 0

    def new(qty) do
      if qty >= 1 do
        {:some, struct(__MODULE__, value: qty)}
      else
        :none
      end
    end
  end

  def parse_order_quantity(str) do
    str |> parse_int >>> &OrderQty.new/1
  end

  test "bind" do
    assert OrderQty.new(1) == parse_order_quantity("1")
  end
end
