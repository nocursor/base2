# Base2

Base2 is an Elixir library for encoding and decoding Base2 binaries. 

Is this a problem worth solving? Yes, but only if you need to work with Base2 as actual binaries, not just bits.

Working with Base2 is a relatively simple task chaining a few Elixir built-in functions or using a third-party generic "BaseX" type library, but most of these implementations leave a lot to be desired. Generally, most built-in methods and third-party libraries are often not very optimized. Using built-in functions also is not uniform with other ways of handling Bases such as via the Elixir `Base` module. Most of these methods are great for scratch work, but less suitable for bulk encoding and decoding and working at scale. Further, the multiple ways of approaching different bases lead to very inconsistent interfaces, for instance `Integer.to_string()` vs. `Base` vs a third-party module with its own conventions.

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
    
The overall rationale for this module is:

* Avoid the aforementioned pitfalls with many popular Base2 encoding/decoding methods using BIFs only
    * Performance and memory footprint
    * Loss of leading zeroes
    * Scattered interfaces/necessity to encapsulate chained calls for consistency in a real-world app
    * Padding behavior and loss of data fidelity
* Attempt to encapsulate the fastest, most pragmatic methods for encoding and decoding Base2 in one place, with tests.
* Minimal memory footprint and good performance in tight loops or aggressive callers.
* Unified interface and consistent behavior with regard to data transparency for working with [Multibase](https://github.com/multiformats/multibase).
* Offer error handling versions of Base2 decoding.
* Consistent with the core Elixir 'Base' module.
* No extra NIFs.
* Control over padding behavior.
* Control over transparent encoding and decoding.
* Decode Base2 strings whether padded or not.

You *should* use `Base2` if:

* You want faster Base2 binary encoding than any methods like `Integer.to_string()` that are based off `div` and `rem` approaches. Both are extremely slow in Elixir.
* You need to build some sort of multi-base/base-x implementation such as Multibase](https://github.com/multiformats/multibase) where you want efficient encoding and/or decoding across different Base values.
* You want a single, unified and clear interface for working with Base2 or potentially other Base values as well.
* You want basic error handling versions for Base2 decoding without rolling it yourself
* You need specific padding behavior, perhaps for transparency or display reasons (ex: binary viewers/editors)  

You should *not* use `Base2` if:

* You do not need to represent Base2 as Elixir binaries. It is best to work with Base2 in terms of bits when possible and will be much faster than dealing with strings.
* You do not care about performance or any of the other reasons above. I probably don't want to know you either, bub.

## Usage

Encoding a simple binary:

```elixir
Base2.encode2(<<1>>)
"1"

# notice the difference
Base2.encode2("1")
"110001"

Base2.encode2("hello")
"110100001100101011011000110110001101111"
```

Encode a leading 0 binary:

```elixir
# notice the 0 is padded by default so we can decode it in exactly the same form we encoded it
Base2.encode2(<<0, 1>>)  
"0000000000000001"

# if we do not need this behavior
# note: will not decode to the same binary, instead it will be <<1>>
Base2.encode2(<<0, 1>>, padding: :none)
"1"
```

We can always pad our binary if we like, even if it does not have a leading zero:

```elixir
# always a multiple of 8
Base2.encode2(<<1>>, padding: :all) 
"00000001"

# this is quite nice if we want to do things like examine chunks uniformly, maybe for your future bin viewer/editor
for <<block::binary-8 <- Base2.encode2(<<0, 1, 2, 3>>, padding: :all)>>, do: block
["00000000", "00000001", "00000010", "00000011"]
```

Let's decode some of the things we just encoded above:

```elixir
Base2.decode2!("1")
<<1>>

Base2.decode2!("110001")
"1"

Base2.decode2!("110100001100101011011000110110001101111")
"hello"

# what if we had some leading zeroes in front of that?
# of course it transparently decodes - our input is exactly our output
Base2.decode2!("00000000110100001100101011011000110110001101111")
<<0, 104, 101, 108, 108, 111>>


# that transparently decoded, but why does it look that way?
# no worries, exactly what we wanted - it's just the leading zero, let's clip it quick and dirty to prove it
Base2.decode2!("00000000110100001100101011011000110110001101111") |> :binary.part(1, 5)
"hello"

# and let's just prove it's transparent in 1 step
Base2.encode2(<<0, "hello">>) |> Base2.decode2!()
<<0, 104, 101, 108, 108, 111>>


# what if we want error handling?
Base2.decode2("110100001100101011011000110110001101111")
{:ok, "hello"}

# Let's try something that isn't Base2
Base2.decode2("I am not a Base2 binary")
:error
```

Sometimes you might want to start with an integer. No worries, just convert it to binary using the appropriate method.

Shockingly, some people are not very familiar how to do this. Let's help them even though we're not one of those people.

```elixir
# If it's unsigned, here's a fast way:
:binary.encode_unsigned(1234) |> Base2.encode2()
"10011010010"

# If you already know the intended size, you could of course do this too
myinteger = 32767
<<myinteger::unsigned-integer-size(2)-unit(8)>> |> Base2.encode2()
"111111111111111"


# We can play with the size too easily to zero-pad it
<<myinteger::unsigned-integer-size(3)-unit(8)>> |> Base2.encode2()
"000000000111111111111111"
```

## Installation

Base2 is available via [Hex](https://hex.pm/packages/base2). The package can be installed by adding `base2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:base2, "~> 0.1.0"}
  ]
end
```

API Documentation can be found at [https://hexdocs.pm/base2/base2.html](https://hexdocs.pm/basefiftyeight/base2.html).
