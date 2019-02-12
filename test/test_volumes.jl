test_volume_results = [0, 1, 1, 8, 1, 1, 1, 1, 2, 1, 1, 1, 3, 2, 1, 9, 3, 2, 2, 6]

black_surface = zeros(Int, 5, 5)
white_surface = ones(Int, 5, 5)

separated_voxels = [0 0 0 0 0; 0 1 0 1 0; 0 0 0 0 0; 0 1 0 1 0; 0 0 0 0 0]
checkerboard_1 = [1 0 1 0 1; 0 1 0 1 0; 1 0 1 0 1; 0 1 0 1 0; 1 0 1 0 1]
checkerboard_2 = [0 1 0 1 0; 1 0 1 0 1; 0 1 0 1 0; 1 0 1 0 1; 0 1 0 1 0]
hollow_structure = [0 0 0 0 0; 0 1 1 1 0; 0 1 0 1 0; 0 1 1 1 0; 0 0 0 0 0]
cutoff_hollow = [0 0 0 0 0; 0 1 1 1 0; 0 1 0 1 0; 0 1 0 1 0; 0 1 0 1 0]
two_blocks = [0 0 0 0 0; 1 1 1 1 0; 0 0 0 0 0; 0 1 1 1 1; 0 0 0 0 0]
single_hollow_voxel = [1 0 1 0 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 0 1 1 1 0]
enclosed_hollow = [1 0 1 0 1; 1 1 1 1 1; 1 0 0 0 1; 1 1 1 1 1; 0 1 1 1 0]
multiple_single_hollow_voxel = [1 0 1 0 1; 1 1 1 1 1; 1 0 1 0 1; 1 1 1 1 1; 0 1 0 1 0]
border_voxels = [1 1 1 1 1; 1 0 0 0 1; 1 0 0 0 1; 1 0 0 0 1; 1 1 1 1 1]

# Black voxels
test_volume_1 = zeros(Int, 5, 5, 5)

# White voxels
test_volume_2 = ones(Int, 5, 5, 5)

# Single voxel
_test_volume_3 = zeros(Int, 5, 5, 5)
_test_volume_3[3, 3, 3] = 1
test_volume_3 = _test_volume_3

# Multiple single voxels
test_volume_4 = cat(black_surface, separated_voxels, black_surface, separated_voxels, black_surface; dims = 3)

# Checkerboard 1
test_volume_5 = cat(checkerboard_1, checkerboard_2, checkerboard_1, checkerboard_2, checkerboard_1; dims = 3)

# Checkerboard 2
test_volume_6 = cat(checkerboard_2, checkerboard_1, checkerboard_2, checkerboard_1, checkerboard_2; dims = 3)

# Hollow structure
test_volume_7 = cat(black_surface, hollow_structure, hollow_structure, hollow_structure, black_surface; dims = 3)

# Cut-off hollow structure
test_volume_8 = cat(black_surface, cutoff_hollow, cutoff_hollow, cutoff_hollow, cutoff_hollow; dims = 3)

# Two blocks
test_volume_9 = cat(black_surface, two_blocks, two_blocks, two_blocks, black_surface; dims = 3)

# Single hollow voxel
test_volume_10 = cat(single_hollow_voxel, single_hollow_voxel, single_hollow_voxel, single_hollow_voxel, single_hollow_voxel; dims = 3)

# Enclosed hollow structure
test_volume_11 = cat(enclosed_hollow, enclosed_hollow, enclosed_hollow, black_surface, black_surface; dims = 3)

# Multiple single hollow voxels
test_volume_12 = cat(black_surface, black_surface, multiple_single_hollow_voxel, black_surface, black_surface; dims = 3)

# Border voxels
test_volume_13 = cat(border_voxels, black_surface, border_voxels, black_surface, border_voxels; dims = 3)

# Cube in cube
_test_volume_14 = cat(white_surface, border_voxels, border_voxels, border_voxels, white_surface; dims = 3)
_test_volume_14[3, 3, 3] = 1
test_volume_14 = _test_volume_14

# Unfixed hollow voxel sizes
test_volume_15 = cat(border_voxels, hollow_structure, hollow_structure, border_voxels; dims = 3)

# Cubes in cube
_white_surface_7 = ones(Int, 7, 7)
_border_voxels_7 = [1 1 1 1 1 1 1; 1 0 0 0 0 0 1; 1 0 0 0 0 0 1; 1 0 0 0 0 0 1; 1 0 0 0 0 0 1; 1 0 0 0 0 0 1; 1 1 1 1 1 1 1]
_cube_slices = [1 1 1 1 1 1 1; 1 0 0 0 0 0 1; 1 0 1 0 1 0 1; 1 0 0 0 0 0 1; 1 0 1 0 1 0 1; 1 0 0 0 0 0 1; 1 1 1 1 1 1 1]
test_volume_16 = cat(_white_surface_7, _border_voxels_7, _cube_slices, _border_voxels_7, _cube_slices, _border_voxels_7, _white_surface_7; dims = 3)

# Cube in cube in cube
_white_surface_9 = ones(Int, 9, 9)
_border_voxels_9 = [1 1 1 1 1 1 1 1 1; 1 0 0 0 0 0 0 0 1; 1 0 0 0 0 0 0 0 1; 1 0 0 0 0 0 0 0 1; 1 0 0 0 0 0 0 0 1; 1 0 0 0 0 0 0 0 1; 1 0 0 0 0 0 0 0 1; 1 0 0 0 0 0 0 0 1; 1 1 1 1 1 1 1 1 1]
_test_volume_17 = cat(_white_surface_9, _border_voxels_9,  _border_voxels_9, _border_voxels_9, _border_voxels_9, _border_voxels_9, _border_voxels_9, _border_voxels_9, _white_surface_9; dims = 3)
_test_volume_17[3:7, 3:7, 3:7] = test_volume_14
test_volume_17 = _test_volume_17

# Cuboid 1 (4 x 5 x 5)
_test_volume_18_1 = [0 1 1 1 0; 1 1 0 1 1; 1 0 0 1 1; 1 1 1 1 0]
_test_volume_18_2 = [0 1 1 1 0; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 0 0]
_test_volume_18_3 = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0]
_test_volume_18_4 = [0 1 1 1 0; 1 1 0 1 1; 1 1 0 1 1; 1 1 0 0 0]
_test_volume_18_5 = [0 1 1 1 0; 1 1 0 1 1; 1 1 0 1 1; 1 1 0 0 0]
test_volume_18 = cat(_test_volume_18_1, _test_volume_18_2, _test_volume_18_3, _test_volume_18_4, _test_volume_18_5; dims = 3)

# Cuboid 2 (7 x 5 x 3)
_test_volume_19_1 = [1 1 1 1 1; 1 0 1 0 1; 0 0 1 0 0; 1 0 1 0 1; 1 1 1 1 1; 0 0 0 0 0; 0 0 0 0 0]
_test_volume_19_2 = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0]
_test_volume_19_3 = [1 0 0 0 0; 0 1 0 0 0; 0 0 1 0 0; 0 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0; 0 0 1 0 0]
test_volume_19 = cat(_test_volume_19_1, _test_volume_19_2, _test_volume_19_3; dims = 3)

# Cuboid 3 (4 x 6 x 2)
_test_volume_20_1 = [1 1 0 0 0 0 0; 0 0 0 0 0 1 0; 0 0 0 0 0 0 0; 0 0 1 0 0 0 0]
_test_volume_20_2 = [0 0 0 1 0 0 0; 0 0 0 0 0 0 0; 1 0 0 0 0 0 0; 0 0 0 0 1 1 0]
test_volume_20 = cat(_test_volume_20_1, _test_volume_20_2; dims = 3)
