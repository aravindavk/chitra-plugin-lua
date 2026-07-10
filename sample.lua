size(500, 200)
grid(4, {gap=20})
local c1 = grid_cell(1)
print(string.format("GRID CELL 1: x=%s  y=%s  w=%s  h=%s", c1.x, c1.y, c1.width, c1.height));

local ga = grid_area(1, 2)
print(string.format("GRID AREA 1: x=%s  y=%s  w=%s  h=%s", ga.x, ga.y, ga.width, ga.height));

local box1 = grid_cell(1)
rect(box1.x, box1.y, box1.width, box1.height)

oval_mode(CORNER)
local box2 = grid_cell(2)
oval(box2.x, box2.y, box2.width, box2.height)

save("size_500_200.png", {resolution=72})
