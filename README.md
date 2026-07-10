# Chitra Lua plugin and CLI

Build the CLI

```
dub build :chitra-cli
```

## Usage:

Execute the Chitra code from a Lua file

```lua
-- sample.lua file
size(400)
save("hello.png", {resolution=72})
```

```
./chitra -f sample.lua
```

OR execute the code directly

```
./chitra -c 'size(400); save("hello.png", {resolution=72})'
```

Verify the generated file

```
file hello.png
hello.png: PNG image data, 400 x 400, 8-bit/color RGBA, non-interlaced
```
