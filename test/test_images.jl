test_image_results = [0, 1, 1, 4, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 3, 1, 2, 2, 2]

# Black pixels
test_image_1 = [
0 0 0 0 0 ;
0 0 0 0 0 ;
0 0 0 0 0 ;
0 0 0 0 0 ;
0 0 0 0 0]

# White pixels
test_image_2 = [
1 1 1 1 1 ;
1 1 1 1 1 ;
1 1 1 1 1 ;
1 1 1 1 1 ;
1 1 1 1 1]

# Single pixel
test_image_3 = [
0 0 0 0 0 ;
0 0 0 0 0 ;
0 0 1 0 0 ;
0 0 0 0 0 ;
0 0 0 0 0]

# Multiple single pixels
test_image_4 = [
0 0 0 0 0 ;
0 1 0 1 0 ;
0 0 0 0 0 ;
0 1 0 1 0 ;
0 0 0 0 0]

# Checkerboard 1
test_image_5 = [
1 0 1 0 1 ;
0 1 0 1 0 ;
1 0 1 0 1 ;
0 1 0 1 0 ;
1 0 1 0 1]

# Checkerboard 2
test_image_6 = [
0 1 0 1 0 ;
1 0 1 0 1 ;
0 1 0 1 0 ;
1 0 1 0 1 ;
0 1 0 1 0]

# External contour
test_image_7 = [
0 0 0 0 0 ;
0 1 1 1 0 ;
0 1 0 1 0 ;
0 1 1 1 0 ;
0 0 0 0 0]

# Cut-off external contour
test_image_8 = [
0 0 0 0 0 ;
0 1 1 1 0 ;
0 1 0 1 0 ;
0 1 0 1 0 ;
0 1 0 1 0]

# Multiple external contour
test_image_9 = [
0 0 0 0 0 ;
1 1 1 1 0 ;
0 0 0 0 0 ;
0 1 1 1 1 ;
0 0 0 0 0]

# Single pixel internal contour
test_image_10 = [
1 0 1 0 1 ;
1 1 1 1 1 ;
1 1 0 1 1 ;
1 1 1 1 1 ;
0 1 1 1 0]

# Internal contour
test_image_11 = [
1 0 1 0 1 ;
1 1 1 1 1 ;
1 0 0 0 1 ;
1 1 1 1 1 ;
0 1 1 1 0]

# Multiple internal contours
test_image_12 = [
1 0 1 0 1 ;
1 1 1 1 1 ;
1 0 1 0 1 ;
1 1 1 1 1 ;
0 1 0 1 0]

# Labelled internal contours
test_image_13 = [
1 1 1 1 1 ;
1 0 0 1 1 ;
1 0 0 0 1 ;
1 1 0 1 1 ;
1 1 1 1 1]

# Unlabelled internal contours
test_image_14 = [
1 1 1 1 1 ;
1 1 1 1 1 ;
1 0 0 1 1 ;
1 0 0 1 1 ;
1 1 1 1 1]

# No dummy row
test_image_15 = [
0 0 0 0 0 ;
1 1 1 1 1 ;
1 0 1 0 1 ;
1 0 1 0 1 ;
1 1 1 1 1]

# Multiple external and internal contours 1
test_image_16 = [
0 0 0 0 0 0 0 0 0 0;
0 1 1 1 1 1 1 1 1 0;
0 1 0 0 0 0 0 0 1 0;
0 1 0 1 1 1 1 1 1 0;
0 1 1 1 0 0 0 0 0 0;
0 0 0 0 0 1 1 1 1 0;
0 1 1 1 0 1 0 0 1 0;
0 1 0 1 0 1 0 0 1 0;
0 1 1 1 0 1 1 1 1 0;
0 0 0 0 0 0 0 0 0 0]

# Multiple external and internal contours 2
test_image_17 = [
0 0 0 0 0 0 0 0 0 0;
0 1 1 1 1 1 1 1 1 0;
0 1 0 0 1 1 0 0 1 0;
0 1 0 0 0 0 1 0 1 0;
0 1 1 0 0 1 0 0 1 0;
0 1 1 1 1 0 0 1 0 0;
0 0 0 0 0 0 0 0 1 0;
0 1 0 0 0 0 1 1 1 0;
0 1 1 1 1 1 1 1 0 0;
0 0 0 0 0 0 0 0 0 0]

# Multiple external and internal contours 3
test_image_18 = [
0 0 0 0 0 0 0 0 0 0;
0 0 1 1 1 1 1 0 0 0;
0 1 0 1 0 1 1 1 0 0;
0 1 0 0 1 0 0 0 0 0;
0 1 0 0 0 0 0 0 0 0;
0 1 1 1 1 0 0 0 0 0;
0 0 1 0 0 0 1 1 0 0;
0 0 0 0 0 1 0 0 1 0;
0 0 0 0 0 1 0 0 1 0;
0 0 0 0 0 0 1 0 1 0]

# Multiple external and internal contours 4
test_image_19 = [
0 0 0 0 1 1 0 0 0 0;
0 0 0 1 0 0 1 0 0 0;
0 0 1 0 0 0 0 1 0 0;
0 1 0 0 1 1 0 0 1 0;
1 0 0 1 0 0 1 0 0 1;
1 0 0 1 0 0 1 0 0 1;
0 1 0 1 0 0 1 0 1 0;
0 1 0 0 1 1 0 0 1 0;
0 0 1 0 0 0 0 1 0 0;
0 0 0 1 1 1 1 0 0 0]

# Multiple external and internal contours 5
test_image_20 = [
0 1 0 0 0 0 0 0 1 0;
0 1 1 1 1 1 1 1 1 0;
0 1 0 0 1 0 0 0 1 0;
0 1 0 0 0 1 0 0 1 0;
0 1 0 1 0 0 1 1 1 0;
0 1 0 0 1 0 0 0 1 0;
0 1 0 1 0 1 0 0 1 0;
0 1 0 1 0 0 1 0 1 0;
0 1 0 0 1 1 1 0 1 0;
0 1 0 0 1 0 0 0 1 0]
