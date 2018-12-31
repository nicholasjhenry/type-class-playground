defmodule TypeClassPlayground.CoreFunctionsInPracticeTest do
  use ExUnit.Case

  # type CustomerId = CustomerId of int
  defmodule CustomerId do
    use TypedStruct

    typedstruct do
      field :value, non_neg_integer, enforce: true
    end

    def new(term) do
      struct!(__MODULE__, value: term)
    end
  end

  # type EmailAddress = EmailAddress of string
  defmodule EmailAddress do
    use TypedStruct

    typedstruct do
      field :value, String.t, enforce: true
    end

    def new(term) do
      struct!(__MODULE__, value: term)
    end
  end

  # type CustomerInfo = {
  #     id: CustomerId
  #     email: EmailAddress
  #     }
  defmodule CustomerInfo do
    use TypedStruct

    typedstruct do
      field :id, CustomerId.t, enforce: true
      field :email, EmailAddress.t, enforce: true
    end

    def new(id, email) do
      struct!(__MODULE__, id: id, email: email)
    end
  end

  # type Result<'a> =
  # | Success of 'a
  # | Failure of string list

  defmodule Result do
    use Currying

    @type t(a) :: {:ok, a} | {:error, [String.t]}

    def success(term), do: {:ok, term}
    def failure(term), do: {:error, List.wrap(term)}

    def map(x_result, f) do
      case x_result do
        {:ok, x} ->
          success(curry(f).(x))
        {:error, errors} ->
          failure(errors)
        end
    end

    def f <|> x_result do
       map(x_result, f)
     end

    def return(x) do
      success(x)
    end

    def ap(x_result, f_result) do
      case {f_result, x_result} do
        {{:ok, f}, {:ok, x}} ->
          success(curry(f).(x))
        {{:error, errs}, {:ok, _x}} ->
          failure(errs)
        {{:ok, _f}, {:error, errs}} ->
          failure(errs)
        {{:error, errs_1}, {:error, errs_2}} ->
          failure(Enum.concat(errs_1, errs_2))
      end
    end

    def result_f <<~ result_x, do: ap(result_x, result_f)

    def bind(result_x, f) do
      case result_x do
        {:ok, x} ->
          curry(f).(x)
        {:error, errs} ->
          failure(errs)
      end
    end

    def result_x >>> f, do: bind(result_x, f)
  end

  def create_customer_id(id) do
    if id > 0 do
      Result.success(CustomerId.new(id))
    else
      Result.failure(["CustomerId must be positive"])
    end
  end

  def create_email_address(str) do
    cond do
      is_nil(str) || String.length(str) == 0 ->
        Result.failure(["Email must not be empty"])
      String.contains?(str, "@") ->
        Result.success(EmailAddress.new(str))
      true ->
        Result.failure(["Email must contain @-sign"])
    end
  end

  def create_customer(customer_id, email) do
    CustomerInfo.new(customer_id,  email)
  end

  # applicative version
  def create_customer_result_a(id, email) do
    import Result, only: ["<|>": 2, "<<~": 2]

    id_result = create_customer_id(id)
    email_result = create_email_address(email)
    (&create_customer/2) <|> id_result <<~ email_result
  end

  test "applicative style (with map and apply)" do
    good_id = 1
    bad_id = 0
    good_email = "test@example.com"
    bad_email = "example.com"

    customer_result = create_customer_result_a(good_id, good_email)
    assert customer_result == Result.success(CustomerInfo.new(CustomerId.new(1), EmailAddress.new("test@example.com")))

    customer_result = create_customer_result_a(bad_id, bad_email)
    assert customer_result == Result.failure(["CustomerId must be positive", "Email must contain @-sign"])
  end

  # monadic version
  def create_customer_result_m(id, email) do
    import Result, only: [">>>": 2]

    create_customer_id(id) >>> (fn customer_id ->
      create_email_address(email) >>> (fn email_address ->
        customer = create_customer(customer_id, email_address)
        Result.success(customer)
      end)
    end)
  end

  test "monadic style (with bind)" do
    good_id = 1
    bad_id = 0
    good_email = "test@example.com"
    bad_email = "example.com"

    customer_result = create_customer_result_m(good_id, good_email)
    assert customer_result == Result.success(CustomerInfo.new(CustomerId.new(1), EmailAddress.new("test@example.com")))

    customer_result = create_customer_result_m(bad_id, bad_email)
    assert customer_result == Result.failure(["CustomerId must be positive"])
  end
end
