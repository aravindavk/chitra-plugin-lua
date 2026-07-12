no_stroke()

local txt = "Hello World!"
text_font("American Typewriter", 50)
text(txt, 10, 10)
local box = text_size(txt)

-- Draw text underline same as text width
fill(0, 0, 255, 0.5)
rect(10, 10 + box.height, box.width, 5)

-- Algin Text to the middle of the canvas
local x = (width() - box.width) / 2.0
local y = (height() - box.height) / 2.0
text(txt, x, y)

save("text.png")
