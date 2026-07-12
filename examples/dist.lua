size(1024)

grid(32, 32)

stroke(0, 0, 255, 0.1)

main_x = 512
main_y = 512
within = 1024

for i = 0, 1024 do
   local box = grid_cell(i+1)
   local x2 = box.x > main_x and box.x + box.width or box.x
   local y2 = box.y > main_y and box.y + box.height or box.y
   local d = dist(main_x, main_y, x2, y2)
   fill(0, 0, 255, (d / within) + 0.1)

   rect(box.x, box.y, box.width, box.height)
end

save("dist.png", {resolution=72})
