defmodule Base2 do
  @moduledoc """
  This module provides data encoding and decoding functions for Base2.

  ## Overview

  Converting to and from Base2 is very simple in Elixir and Erlang. Unfortunately, most approaches use generic methodologies that are suitable for any Base, and thus do not optimize for any Base typically.

  Working with Base2 is a relatively simple task chaining a few Elixir built-in functions or using a third-party generic "BaseX" type library, but most of these implementations leave a lot to be desired. Generally, most built-in methods and third-party libraries are often not very optimized. Using built-in functions also is not uniform with other ways of handling Bases such as via the Elixir `Base` module. Most of these methods are great for scratch work, but less suitable for bulk encoding and decoding.  Further, the multiple ways of approaching different bases lead to very inconsistent interfaces, for instance `Integer.to_string()` vs. `Base` vs a third-party module with its own conventions.

  `Base2` includes the following functionality:

  * Encodes and Decodes binaries as Base2.
  * Consistent with the `Base` module interface design.
  * Optionally preserves transparency encoding and decoding leading zeroes.
  * Reasonably fast, because every library claims it is fast.
    * Faster than libraries that take generic approaches to encode any Base either via module generation or runtime alphabets
    * Faster than doing `:binary.encode_unsigned("hello") |> Integer.to_string(2)`
    * Faster than methods using power-based functions that can also overflow when using the BIF
    * Avoids the div/rem operation that is the source of many slowdowns, such as in `Integer.to_string/2` and its wrapped `:erlang.integer_to_binary/2`
  * Uses less memory than most other methods
  * Option to remove extra padding if losing losing leading zeroes is desirable or wanted to produce smaller resulting binaries
    * Loses transparency
  * Control over shape of output binary
    * Force padding always, only for leading zeroes, or return a smaller binary representation

  ## Padding

  `Base2` allows full control over padding behavior when encoding a binary into a Base2 string.

  There are three options for padding:

    * `:zeroes` (default) - Allows zeroes to be padded to ensure transparent decode of leading zeroes.
    * `:all` - Uniformly pads the data with zeroes. String length will always a multiple of 8 and fast, but at the cost of an increased output size.
    * `:none` - Produces a smaller representation by dropping all leading zeroes, but at the cost of fully transparent decode if there are leading zeroes.

    `:zeroes` is good for general usage, while typically being smaller. Zeroes are fully padded to byte boundaries. Transparency is fully preserved.

    `:all` is good for uniformly working with Base2 string output. Transparency is fully preserved.

    `:none` exhibit the same behavior as methods such as `Integer.to_string("hello", 2)` that try to use a smaller representation. This method should be used with caution as it comes at a cost of transparency. Simply, if you want the exact same output when decoding as your input, do not use this option. If, however, you want the smallest representation, then it is a good choice.

  """

  @typedoc """
  A Base2 encoded string.
  """
  @type base2_binary() :: binary()

  @doc """
  Encodes a binary string into a base 2 encoded string.

  Accepts a `:padding` option which will control the padding behavior of the resulting strings.

  The options for `:padding` can be:

    * `:zeroes` (default) - Allows zeroes to be padded to ensure transparent decode of leading zeroes.
    * `:all` - Uniformly pads the data with zeroes. String length will always a multiple of 8 and fast, but at the cost of an increased output size.
    * `:none` - Produces a smaller representation by dropping all leading zeroes, but at the cost of fully transparent decode if there are leading zeroes.

  ## Examples

      iex> Base2.encode2("hello world")
      "110100001100101011011000110110001101111001000000111011101101111011100100110110001100100"

      iex> Base2.encode2(<<0, 1>>, padding: :zeroes)
      "0000000000000001"

      iex> Base2.encode2(<<0, 1>>, padding: :none)
      "1"

      iex> Base2.encode2(<<0, 1>>, padding: :all)
      "0000000000000001"

      iex> Base2.encode2(<<1>>, padding: :all)
      "00000001"

  """
  @spec encode2(binary(), keyword()) :: base2_binary()
  def encode2(binary, opts \\ [])
  def encode2(binary, opts) when is_binary(binary) do
    pad_type = Keyword.get(opts, :padding, :zeroes)
    do_encode(binary, pad_type)
  end

  @doc """
  Decodes a base 2 encoded string as a binary string.

  An ArgumentError is raised if the string is not a base 2 encoded string.

  ## Examples

      iex> Base2.decode2!("110100001100101011011000110110001101111001000000111011101101111011100100110110001100100")
      "hello world"

      iex> Base2.decode2!("1")
      <<1>>

      iex> Base2.decode2!("0000000000000001")
      <<0, 1>>

      iex> Base2.decode2!("00000001")
      <<1>>

  """
  @spec decode2!(base2_binary()) :: binary()
  def decode2!(string) when is_binary(string) do
    do_decode(string)
  end

  @doc """
  Decodes a base 2 encoded string as a binary string.

  Returns `:error` if the string is not a base 2 encoded string.

  ## Examples

      iex> Base2.decode2("110100001100101011011000110110001101111001000000111011101101111011100100110110001100100")
      {:ok, "hello world"}

      iex> Base2.decode2("1")
      {:ok, <<1>>}

      iex> Base2.decode2("0000000000000001")
      {:ok, <<0, 1>>}

      iex> Base2.decode2("00000001")
      {:ok, <<1>>}

      iex> Base2.decode2("hello world")
      :error

      iex> Base2.decode2("00101015")
      :error

  """
  @spec decode2(base2_binary()) :: {:ok, binary()} | :error
  def decode2(string) when is_binary(string) do
    {:ok, decode2!(string)}
    rescue
      ArgumentError -> :error
  end

#===============================================================================
# Private Island
#===============================================================================

  defp do_encode(data, :none) do
    trim_encode(data, false)
  end

  defp do_encode(data, :zeroes) do
    trim_encode(data, true)
  end

  defp do_encode(data, :all) do
    encode_body(data, [])
  end

  defp trim_encode(<<>>, _pad?) do
    <<>>
  end

  defp trim_encode(<<0>>, _pad?) do
    "0"
  end

  defp trim_encode(data, pad?) do
    trim_encode(data, [], pad?)
  end

  defp trim_encode(<<0, rest::binary>>, _acc, true) do
    # here we could try to make a more compact representation, but it complicates decoding so not sure if it's worth it
    encode_body(rest, '00000000')
  end

  defp trim_encode(<<1::1, rest::bitstring>>, _acc, _pad?) do
    encode_body(rest, ['1'])
  end

  defp trim_encode(<<0::1, rest::bitstring>>, acc, pad?) do
    trim_encode(rest, acc, pad?)
  end

  defp trim_encode(<<>>, [], _pad?) do
    <<>>
  end

  defp encode_body(<<>>, acc) do
    acc |> Enum.reverse() |> to_string()
  end

  defp encode_body(<<1::1, rest::bitstring>>, acc) do
    encode_body(rest, ['1' | acc])
  end

  defp encode_body(<<0::1, rest::bitstring>>, acc) do
    encode_body(rest, ['0' | acc])
  end

  defp count_leading_zeroes(<<"00000000", rest::binary>>, acc) do
    # This call here could be tweaked with another few pattern matches if we want a smaller representation for the case of `:zeroes` padding, however experimenting, the decoding speed was a bit less
    count_leading_zeroes(rest, acc + 1)
  end

  defp count_leading_zeroes(_string, acc) do
    acc
  end

  defp do_decode(string) do
    # Using String.to_integer + encode_unsigned is much faster than manual recursive decode to build individual bits
    leading_zeroes = count_leading_zeroes(string, 0)
    <<0::size(leading_zeroes)-unit(8), (String.to_integer(string, 2) |> :binary.encode_unsigned())::binary>>
  end

end
