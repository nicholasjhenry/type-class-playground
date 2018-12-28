defmodule TypeClassPlayground.ZipTest do
  @moduledoc """
  Some data types might have more than one valid implementation of `apply`. For example, there is
  another possible implementation of `apply` for lists, commonly called `ZipList` or some variant
  of that.

  In this implementation, the corresponding elements in each list are processed at the same time,
  and then both lists are shifted to get the next element. That is, the list of functions `[f; g]`
  applied to the list of values `[x; y]` becomes the two-element list `[f x; g y]`.

  Common Names: `zip`, `zipWith`, `map2`
  Common Operators: `<*>` (in the context of ZipList world)
  What it does:  Combines two lists (or other enumerables) using a specified function
  Signature: `E<(a->b->c)> -> E<a> -> E<b> -> E<c>` where `E` is a list or other enumerable type,
              or `E<a> -> E<b> -> E<a,b>` for the tuple-combined version.

  https://fsharpforfunandprofit.com/posts/elevated-world/#zip
  """
  use ExUnit.Case

  def zip_list(flist, xlist) do
    case {flist, xlist} do
      {[], _} -> []
      {_, []} -> []
      {[f | ftail], [x | xtail]} -> [f.(x) | zip_list(ftail, xtail)]
    end
  end

  # Based on Witchcraft: https://github.com/expede/witchcraft#operators
  def flist <<~ xlist do
    zip_list(flist, xlist)
  end

  test "zip list" do
    add_10 = fn x -> x + 10 end
    add_20 = fn x -> x + 20 end
    add_30 = fn x -> x + 30 end

    assert [11, 22, 33] == [add_10, add_20, add_30] <<~ [1, 2, 3]
  end
end
