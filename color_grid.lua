size(800)
grid(16, 16)

no_stroke()

for i = 0, 255 do
   local box = grid_cell(i+1)
   fill(0, 0, i)
   rect(box.x, box.y, box.width, box.height)
end

save("color_grid.png", {resolution=72})
