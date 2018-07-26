defmodule Commands.IntCommands do

    alias Interp.Functions
    alias Commands.GeneralCommands
    require Interp.Functions

    # All characters available from the 05AB1E code page, where the
    # alphanumeric digits come first and the remaining characters
    # ranging from 0x00 to 0xff that do not occur yet in the list are appended.
    def digits, do: digits = String.to_charlist(
                             "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmno" <>
                             "pqrstuvwxyzǝʒαβγδεζηθвимнт\nΓΔΘιΣΩ≠∊∍∞₁₂₃₄₅₆ !\"#$%" <>
                             "&'()*+,-./:;<=>?@[\\]^_`{|}~Ƶ€Λ‚ƒ„…†‡ˆ‰Š‹ŒĆŽƶĀ‘’“”–" <>
                             "—˜™š›œćžŸā¡¢£¤¥¦§¨©ª«¬λ®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉ" <>
                             "ÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ")
    
    def factorial(0), do: 1
    def factorial(value), do: factorial(value, 1)
    def factorial(1, acc), do: acc
    def factorial(value, acc), do: factorial(value - 1, acc * value)

    def pow(n, k) do
        cond do
            k < 0 -> 1 / pow(n, -k, 1)
            true -> pow(n, k, 1)
        end 
    end
    defp pow(_, 0, acc), do: acc
    defp pow(n, k, acc) when k > 0 and k < 1, do: acc * :math.pow(n, k)
    defp pow(n, k, acc), do: pow(n, k - 1, n * acc)

    # Modulo operator:
    #  -x.(f|i) % -y.(f|i)     -->  -(x.(f|i) % y.(f|i))
    #  -x.f % y.f              -->  (y.f - (x.f % y.f)) % y.f
    #  x.f % -y.f              -->  -(-x.f % y.f)
    #  x.(f|i) % y.(f|i)       -->  ((x / y) % 1) * y.(f|i)
    #  -x.i % -y.i             -->  -(x.i % y.i) 
    #  -x.i % y.i              -->  (y.i - (x.i % y.i)) % y.i 
    #  x.i % -y.i              -->  -(-x.i % y.i)
    #  x.i % y.i               -->  rem(x.i, y.i)
    def mod(dividend, divisor) when dividend < 0 and divisor < 0, do: -mod(-dividend, -divisor)
    def mod(dividend, divisor) when is_float(divisor) do
        cond do
            dividend < 0 and divisor > 0 ->
                case mod(-dividend, divisor) do
                    0 -> 0
                    x -> divisor - x
                end
            dividend > 0 and divisor < 0 -> -mod(-dividend, -divisor)
            true -> mod(dividend / divisor, 1) * divisor
        end
    end
    def mod(dividend, divisor) when is_float(dividend) and is_integer(divisor) do
        int_part = trunc(dividend)
        float_part = dividend - int_part
        mod(int_part, divisor) + float_part
    end
    def mod(dividend, divisor) when is_integer(dividend) and is_integer(divisor) do
        cond do
            dividend < 0 and divisor > 0 ->
                case mod(-dividend, divisor) do
                    0 -> 0
                    x -> divisor - x
                end
            dividend > 0 and divisor < 0 -> -mod(-dividend, -divisor)
            true -> rem(dividend, divisor)
        end
    end

    def divide(dividend, divisor) when is_float(dividend) or is_float(divisor), do: trunc(dividend / divisor)
    def divide(dividend, divisor), do: div(dividend, divisor)

    def to_base(value, base) do
        Integer.digits(value, base) |> Enum.map(fn x -> Enum.at(digits(), x) end) |> List.to_string
    end

    def string_from_base(value, base) do
        list = to_charlist(value) |> Enum.map(fn x -> Enum.find_index(digits(), fn y -> x == y end) end)
        list_from_base(list, base)
    end

    def list_from_base(value, base) do
        value = Enum.to_list(value)
        {result, _} = Enum.reduce(value, {0, length(value) - 1}, fn (x, {acc, index}) -> {acc + pow(base, index) * x, index - 1} end)
        result
    end

    def is_prime?(value) when value in [2, 3], do: true
    def is_prime?(value) when value < 2, do: false
    def is_prime?(value) do
        max_index = :math.sqrt(value) |> Float.floor |> round
        !Enum.any?(2..max_index, fn x -> rem(value, x) == 0 end)
    end

    def n_choose_k(n, k) when k > n, do: 0
    def n_choose_k(n, k), do: div(factorial(n), factorial(k) * factorial(n - k))

    def n_permute_k(n, k) when k > n, do: 0
    def n_permute_k(n, k), do: div(factorial(n), factorial(n - k))

    def max_of(list) do
        cond do
            Functions.is_iterable(list) -> max_of(Enum.to_list(list), nil)
            true -> max_of(String.graphemes(to_string(list)), nil)
        end
    end
    def max_of([], value), do: value
    def max_of(list, value) do
        head = List.first Enum.take(list, 1)
        cond do
            Functions.is_iterable(head) and value == nil -> max_of(Enum.drop(list, 1), max_of(head))
            Functions.is_iterable(head) -> max_of(Enum.drop(list, 1), max(max_of(head), value))
            value == nil -> max_of(Enum.drop(list, 1), Functions.to_number(head))
            Functions.to_number(head) > value and is_number(Functions.to_number(head)) -> max_of(Enum.drop(list, 1), Functions.to_number(head))
            true -> max_of(Enum.drop(list, 1), value)
        end
    end

    def min_of(list) do
        cond do
            Functions.is_iterable(list) -> min_of(Enum.to_list(list), nil)
            true -> min_of(String.graphemes(to_string(list)), nil)
        end
    end
    def min_of([], value), do: value
    def min_of(list, value) do
        head = List.first Enum.take(list, 1)
        cond do
            Functions.is_iterable(head) and value == nil -> min_of(Enum.drop(list, 1), min_of(head))
            Functions.is_iterable(head) -> min_of(Enum.drop(list, 1), min(min_of(head), value))
            value == nil -> min_of(Enum.drop(list, 1), Functions.to_number(head))
            Functions.to_number(head) < value and is_number(Functions.to_number(head)) -> min_of(Enum.drop(list, 1), Functions.to_number(head))
            true -> min_of(Enum.drop(list, 1), value)
        end
    end

    # GCD that also supports decimal numbers.
    def gcd_of(a, a), do: a
    def gcd_of(a, 0), do: a
    def gcd_of(0, b), do: b
    def gcd_of(a, b) when is_integer(a) and is_integer(b), do: Integer.gcd(a, b)
    def gcd_of(a, b) when a < 0 and b < 0, do: -gcd_of(-a, -b)
    def gcd_of(a, b) when a < 0, do: gcd_of(-a, b)
    def gcd_of(a, b) when b < 0, do: gcd_of(a, -b)
    def gcd_of(a, b) when a > b, do: gcd_of(a - b, b)
    def gcd_of(a, b) when a < b, do: gcd_of(a, b - a)
end