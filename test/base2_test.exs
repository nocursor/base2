defmodule Base2Test do
  use ExUnit.Case
  doctest Base2

  import Base2

  test "encode/2 encodes binary as base2" do
    assert encode2(<<0>>) == "0"
    assert encode2(<<1>>) == "1"
    assert encode2(<<1, 1>>) == "100000001"
    assert encode2("hello") == "110100001100101011011000110110001101111"
  end

  test "encode/2 encodes an empty string" do
    assert encode2(<<>>) == <<>>
  end

  test "encode2/2 encodes and decodes leading zeroes" do
    assert encode2(<<0>>) == "0"
    assert encode2(<<0, 1>>) == "0000000000000001"
    assert encode2(<<0, 1, 0>>) == "000000000000000100000000"
    assert encode2(<<0, "hello">>) == "000000000110100001100101011011000110110001101111"
    assert encode2(<<0, "hello", 0>>) == "00000000011010000110010101101100011011000110111100000000"
  end

  test "transparently encodes and decodes the Base64 alphabet" do
    b64_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    assert encode2(b64_alphabet) |> decode2!() == b64_alphabet
    assert encode2(b64_alphabet) |> decode2() == {:ok, b64_alphabet}
  end

  test "Base2 transparently encodes binaries" do
    assert "hello" |> Base2.encode2() |> Base2.decode2!() == "hello"
    assert <<0, "hello">> |> Base2.encode2() |> Base2.decode2!() == <<0, "hello">>
  end

  test "encode/2 encodes binary as base2 with padded zeroes" do
    assert encode2(<<0>>, padding: :zeroes) == "0"
    assert encode2(<<1>>, padding: :zeroes) == "1"
    assert encode2(<<1, 1>>, padding: :zeroes) == "100000001"
    assert encode2("hello", padding: :zeroes) == "110100001100101011011000110110001101111"
  end

  test "encode/2 encodes an empty string with padded zeroes" do
    assert encode2(<<>>, padding: :zeroes) == <<>>
  end

  test "encode2/2 encodes and decodes leading zeroes with padded zeroes" do
    assert encode2(<<0>>, padding: :zeroes) == "0"
    assert encode2(<<0, 1>>, padding: :zeroes) == "0000000000000001"
    assert encode2(<<0, 1, 0>>, padding: :zeroes) == "000000000000000100000000"
    assert encode2(<<0, "hello">>, padding: :zeroes) == "000000000110100001100101011011000110110001101111"
    assert encode2(<<0, "hello", 0>>, padding: :zeroes) == "00000000011010000110010101101100011011000110111100000000"
  end

  test "transparently encodes and decodes the Base64 alphabet with padded zeroes" do
    b64_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    assert encode2(b64_alphabet, padding: :zeroes) |> decode2!() == b64_alphabet
    assert encode2(b64_alphabet, padding: :zeroes) |> decode2() == {:ok, b64_alphabet}
  end

  test "Base2 transparently encodes binaries with padded zeroes" do
    assert "hello" |> Base2.encode2(padding: :zeroes) |> Base2.decode2!() == "hello"
    assert <<0, "hello">> |> Base2.encode2(padding: :zeroes) |> Base2.decode2!() == <<0, "hello">>
  end

  test "encode/2 encodes binary as base2 with full padding" do
    assert encode2(<<0>>, padding: :all) == "00000000"
    assert encode2(<<1>>, padding: :all) == "00000001"
    assert encode2(<<1, 1>>, padding: :all) == "0000000100000001"
    assert encode2("hello", padding: :all) == "0110100001100101011011000110110001101111"
  end

  test "encode/2 with full padding always produces strings that are a multiple of eight in length" do
    for n <- 1..128 do
      assert :binary.encode_unsigned(n) |> Base2.encode2(padding: :all) |> String.length() |> rem(8) == 0
      assert :binary.encode_unsigned(n * 255) |> Base2.encode2(padding: :all) |> String.length() |> rem(8) == 0
    end
  end

  test "encode/2 encodes an empty string with full padding" do
    assert encode2(<<>>, padding: :all) == <<>>
  end

  test "encode2/2 encodes and decodes leading zeroes with full padding" do
    assert encode2(<<0>>, padding: :all) == "00000000"
    assert encode2(<<0, 1>>, padding: :all) == "0000000000000001"
    assert encode2(<<0, 1, 0>>, padding: :all) == "000000000000000100000000"
    assert encode2(<<0, "hello">>, padding: :all) == "000000000110100001100101011011000110110001101111"
    assert encode2(<<0, "hello", 0>>, padding: :all) == "00000000011010000110010101101100011011000110111100000000"
  end

  test "transparently encodes and decodes the Base64 alphabet with full padding" do
    b64_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    assert encode2(b64_alphabet, padding: :all) |> decode2!() == b64_alphabet
    assert encode2(b64_alphabet, padding: :all) |> decode2() == {:ok, b64_alphabet}
  end

  test "Base2 transparently encodes binaries with full padding" do
    assert "hello" |> Base2.encode2(padding: :all) |> Base2.decode2!() == "hello"
    assert <<0, "hello">> |> Base2.encode2(padding: :all) |> Base2.decode2!() == <<0, "hello">>
  end

  test "encode/2 encodes binary as base2 with no padding" do
    assert encode2(<<0>>, padding: :none) == "0"
    assert encode2(<<1>>, padding: :none) == "1"
    assert encode2(<<1, 1>>, padding: :none) == "100000001"
    assert encode2("hello", padding: :none) == "110100001100101011011000110110001101111"
  end

  test "encode/2 encodes an empty string with no padding" do
    assert encode2(<<>>, padding: :none) == <<>>
  end

  test "encode2/2 encodes and decodes leading zeroes with no padding" do
    assert encode2(<<0>>, padding: :none) == "0"
    assert encode2(<<0, 1>>, padding: :none) == "1"
    assert encode2(<<0, 1, 0>>, padding: :none) == "100000000"
    assert encode2(<<0, "hello">>, padding: :none) == "110100001100101011011000110110001101111"
    assert encode2(<<0, "hello", 0>>, padding: :none) == "11010000110010101101100011011000110111100000000"
  end

  test "transparently encodes and decodes the Base64 alphabet with no padding" do
    b64_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    assert encode2(b64_alphabet, padding: :none) |> decode2!() == b64_alphabet
    assert encode2(b64_alphabet, padding: :none) |> decode2() == {:ok, b64_alphabet}
  end

  test "Base2 transparently encodes binaries with no padding" do
    assert "hello" |> Base2.encode2(padding: :none) |> Base2.decode2!() == "hello"
    assert <<"hello world">> |> Base2.encode2(padding: :none) |> Base2.decode2!() == "hello world"
  end

  test "decode2!/1 decodes base 2 binaries" do
    assert decode2!("0") == <<0>>
    assert decode2!("1") == <<1>>
    assert decode2!("10") == <<2>>
    assert decode2!("110100001100101011011000110110001101111") == "hello"
    assert decode2!("10000000000001") == <<32, 1>>
  end

  test "decode2/1 decodes base 2 binaries" do
    assert decode2("0") == {:ok, <<0>>}
    assert decode2("1") == {:ok, <<1>>}
    assert decode2("10") == {:ok, <<2>>}
    assert decode2("110100001100101011011000110110001101111") == {:ok, "hello"}
    assert decode2("10000000000001") == {:ok, <<32, 1>>}
  end

  test "decode2!/1 decodes base 2 binaries with 0 padding" do
    assert decode2!("000000000") == <<0, 0>>
    assert decode2!("000000001") == <<0, 1>>
    assert decode2!("0000000010") == <<0, 2>>
    assert decode2!("000000000000000010") == <<0, 0, 2>>
  end

  test "decode2/1 decodes base 2 binaries with 0 padding" do
    assert decode2("000000000") == {:ok, <<0, 0>>}
    assert decode2("000000001") == {:ok, <<0, 1>>}
    assert decode2("0000000010") == {:ok, <<0, 2>>}
    assert decode2("000000000000000010") == {:ok, <<0, 0, 2>>}
  end

  test "decode2/1 handles invalid input" do
    assert "I am not Base2 even if I want to be" |> decode2() == :error
    assert "101010101COMPUTERWELT101010101001" |> decode2() == :error
    assert <<32, "1010100101">> |> decode2() == :error
    assert <<"101010101010", 32>> |> decode2() == :error
    assert "-1" |> decode2() == :error
  end

  test "decode2!/1 raises an error for invalid input" do
    assert_raise ArgumentError, fn ->  "I am not Base2 even if I want to be" |> decode2!() end
    assert_raise ArgumentError, fn -> "101010101COMPUTERWELT101010101001" |> decode2!() end
    assert_raise ArgumentError, fn -> <<32, "1010100101">> |> decode2!() end
    assert_raise ArgumentError, fn -> <<"101010101010", 32>> |> decode2!() end
    assert_raise ArgumentError, fn -> "-1" |> decode2!() end
  end

end
