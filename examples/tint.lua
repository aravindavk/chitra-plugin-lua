size(800, 400)

grid(4, 2, {gap=4})

local img_path = "tiger.png"

function drawTinted(box, tint_color)
   if tint_color ~= "" then 
      tint(tint_color)
   end
   image(img_path, box.x, box.y, box.width, box.height, {fit= COVER})
end

local colors = {"", "#D4AF37", "#E6C280", "#FF7F50", "#4A90E2", "#50C878", "#4a90a4", "#c13584"}
for i = 1, 8 do
   local box = grid_cell(i)
   drawTinted(box, colors[i])
end

save("tinted7.png", {resolution=72})
