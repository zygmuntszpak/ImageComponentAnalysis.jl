var documenterSearchIndex = {"docs":
[{"location":"reference/#function_reference-1","page":"Function Reference","title":"Function References","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"Pages = [\"reference.md\"]\nDepth = 3","category":"page"},{"location":"reference/#General-function-1","page":"Function Reference","title":"General function","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"analyze_components\nanalyze_components!\nestablish_contour_hierarchy\nlabel_components","category":"page"},{"location":"reference/#ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components","page":"Function Reference","title":"ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components","text":"analyze_components(components::AbstractArray{<:Integer}, f::AbstractComponentAnalysisAlgorithm, args...; kwargs...)\nanalyze_components(components::AbstractArray{<:Integer}, f::Tuple{AbstractComponentAnalysisAlgorithm, Vararg{AbstractComponentAnalysisAlgorithm}}, args...; kwargs...)\n\nAnalyze connected components using algorithm f or sequence of algorithms specified in a tuple fs, and store the results in a DataFrame.\n\nOutput\n\nThe information about the components is stored in a DataFrame; each row number contains information corresponding to a particular connected component. The columns of the DataFrame will store the measurements that algorithm f or algorithms fs computes.\n\nExamples\n\nPass an array of labelled connected components and component analysis algorithm to analyze_component.\n\nf = BasicMeasurement()\nanalyze_components = analyze_component(components, f)\n\nfs = tuple(RegionEllipse(), Contour())\nanalyze_components!(df, components, fs)\n\nThe first example reads as \"analyze_components of connected components using algorithm f\".\n\nSee also analyze_components! for appending information about connected components to an existing DataFrame.\n\n\n\n\n\n","category":"function"},{"location":"reference/#ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components!","page":"Function Reference","title":"ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components!","text":"analyze_components!(dataframe::AbstractDataFrame, components::AbstractArray{<:Integer}, f::AbstractComponentAnalysisAlgorithm, args...; kwargs...)\nanalyze_components!(dataframe::AbstractDataFrame, components::AbstractArray{<:Integer}, fs::Tuple{AbstractComponentAnalysisAlgorithm, Vararg{AbstractComponentAnalysisAlgorithm}}, args...; kwargs...)\n\nAnalyze connected components using component analysis algorithm f or sequence of algorithms specified in a tuple fs,  and store the results in a DataFrame.\n\nOutput\n\nThe information about the components is stored in a DataFrame; each row number contains information corresponding to a particular connected component. The DataFrame will be changed in place and its columns will store the measurements that algorithm f or algorithms fs computes.\n\nExamples\n\nJust simply pass an algorithm to analyze_components!:\n\ndf = DataFrame()\nf = BasicMeasurement()\nanalyze_components!(df, components, f)\n\nfs = tuple(RegionEllipse(), Contour())\nanalyze_components!(df, components, fs)\n\nSee also: analyze_components\n\n\n\n\n\n","category":"function"},{"location":"reference/#ImageComponentAnalysis.establish_contour_hierarchy","page":"Function Reference","title":"ImageComponentAnalysis.establish_contour_hierarchy","text":"    establish_contour_hierarchy(labels::AbstractArray{<:Integer})\n\nTraces the contour of both the outer boundary and hole boundary of each labelled component and stores the hierarichal relationship among the contours in a tree data structure.\n\nDetails\n\nThe tree is of type LeftChildRightSiblingTree and you can use the functionality from the AbstractTrees.jl package to iterate over it.\n\nEach Node of the tree has a data field of type DigitalContour.\n\nThe parent/child relationship of the tree reflects the nesting of connected components. If a connected component is wholly contained within another connected component, then its contours will be children of the contours of its surrounding connected component.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ImageCore, AbstractTrees, Parameters\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\ntree = establish_contour_hierarchy(components)\n\n# Iterate over all DigitalContour's in the tree.\nfor node in PostOrderDFS(tree)\n    @unpack id, is_outer, pixels node.data # See Parameters.jl for \"@unpack\"\n    @show id, is_outer, pixels\nend\n\nReference\n\nS. Suzuki and K. Abe, “Topological structural analysis of digitized binary images by border following,” Computer Vision, Graphics, and Image Processing, vol. 29, no. 3, p. 396, Mar. 1985.\n\n\n\n\n\n","category":"function"},{"location":"reference/#ImageComponentAnalysis.label_components","page":"Function Reference","title":"ImageComponentAnalysis.label_components","text":"label_components(tf, [connectivity])\nlabel_components(tf, [region])\n\nFind the connected components in a binary array tf. There are two forms that connectivity can take.\n\n(1) It can be a boolean array of the same dimensionality as tf, of size 1 or 3 along each dimension. Each entry in the array determines whether a given neighbor is used for connectivity analyses. For example, connectivity = trues(3,3) would use 8-connectivity and test all pixels that touch the current one, even the corners.\n\n(2) You can provide a list indicating which dimensions are used to determine connectivity. For example, region = [1,3] would not test neighbors along dimension 2 for connectivity. This corresponds to just the nearest neighbors, i.e., 4-connectivity in 2d and 6-connectivity in 3d. The default is region = 1:ndims(A). The output label is an integer array, where 0 is used for background pixels, and each connected region gets a different integer index.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Algorithms-1","page":"Function Reference","title":"Algorithms","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"ImageComponentAnalysis.ComponentAnalysisAPI.AbstractComponentAnalysisAlgorithm","category":"page"},{"location":"reference/#ImageComponentAnalysis.ComponentAnalysisAPI.AbstractComponentAnalysisAlgorithm","page":"Function Reference","title":"ImageComponentAnalysis.ComponentAnalysisAPI.AbstractComponentAnalysisAlgorithm","text":"AbstractComponentAnalysisAlgorithm <: AbstractComponentAnalysis\n\nThe root type for ImageComponentAnalysis package.\n\nAny concrete component analysis algorithm shall subtype it to support analyze_components and analyze_components! APIs.\n\nExamples\n\nAll component analysis algorithms in ImageComponentAnalysis are called in the following pattern:\n\n# determine the connected components and label them\ncomponents = label_components(binary_image)\n\n# generate an algorithm instance\nf = BasicMeasurement(area = true, perimiter = true)\n\n# then pass the algorithm to `analyze_components`\nmeasurements = analyze_components(components, f)\n\n# or use in-place version `analyze_components!`\ng = BoundingBox(area = true)\nanalyze_components!(measurements, components, g)\n\nYou can run a sequence of analyses by passing a tuple of the relevant algorithms. For example,\n\n# determine the connected components and label them\ncomponents = label_components(binary_image)\n\n# generate algorithm instances\np = Contour()\nq = MinimumOrientedBoundingBox(oriented_box_aspect_ratio = false)\nr = EllipseRegion(semiaxes = true)\n\n# then pass the algorithm to `analyze_components`\nmeasurements = analyze_components(components, tuple(p, q, r))\n\n# or use in-place version `analyze_components!`\nanalyze_components!(measurements, components, tuple(p, q, r))\n\nMost algorithms receive additional information as an argument, such as area or perimeter of BasicMeasurement. In general, arguments are boolean flags that signal whether or not to include a particular feature in the analysis.\n\n# you can explicit specify whether or not you wish to report certain\n# properties\nf = BasicMeasurement(area = false, perimiter = true)\n\nFor more examples, please check analyze_components, analyze_components! and concrete algorithms.\n\n\n\n\n\n","category":"type"},{"location":"reference/#BasicMeasurement-1","page":"Function Reference","title":"BasicMeasurement","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"BasicMeasurement","category":"page"},{"location":"reference/#ImageComponentAnalysis.BasicMeasurement","page":"Function Reference","title":"ImageComponentAnalysis.BasicMeasurement","text":"    BasicMeasurement <: AbstractComponentAnalysisAlgorithm\n    BasicMeasurement(; area = true,  perimeter = true)\n    analyze_components(components, f::BasicMeasurement)\n    analyze_components!(dataframe::AbstractDataFrame, components, f::BasicMeasurement)\n\nTakes as input an array of labelled connected components and returns a DataFrame with columns that store basic measurements, such as area and perimeter, of each component.\n\nDetails\n\nThe area and perimeter measures are derived from bit-quad patterns, which are certain 2 × 2 pixel patterns described in [1]. Hence, the function adds six bit-quad patterns to the DataFrame under column names Q₀, Q₁, Q₂, Q₃, Q₄ and Qₓ.\n\nThe function returns two measures for the perimeter, perimiter₀ and perimter₁, which are given by equations 18.2-8b and 18.2-7a in [2]\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nmeasurements = analyze_components(components, BasicMeasurement(area = true, perimeter = false))\n\n\nReferences\n\nS. B. Gray, “Local Properties of Binary Images in Two Dimensions,” IEEE Transactions on Computers, vol. C–20, no. 5, pp. 551–561, May 1971.\nPratt, William K., Digital Image Processing, New York, John Wiley & Sons, Inc., 1991, p. 629.\n\n\n\n\n\n","category":"type"},{"location":"reference/#BasicTopology-1","page":"Function Reference","title":"BasicTopology","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"BasicTopology","category":"page"},{"location":"reference/#ImageComponentAnalysis.BasicTopology","page":"Function Reference","title":"ImageComponentAnalysis.BasicTopology","text":"    BasicTopology <: AbstractComponentAnalysisAlgorithm\n    BasicTopology(; holes = true,  euler_number = true)\n    analyze_components(components, f::BasicTopolgy)\n    analyze_components!(dataframe::AbstractDataFrame, components, f::BasicTopolgy)\n\nTakes as input an array of labelled connected components and returns a DataFrame with columns that store basic topological properties for each component, such as the euler_number and the total number of holes.\n\nThe function returns two variants of the euler_number: euler₄ and euler₈ which correspond to a 4-connected versus 8-connected neighbourhood.\n\nThe euler_number and number of holes are derived from bit-quad patterns, which are certain 2 × 2 pixel patterns described in [1]. Hence, the function adds six bit-quad patterns to the DataFrame under column names Q₀, Q₁, Q₂, Q₃, Q₄ and Qₓ.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nmeasurements = analyze_components(components, BasicTopology(holes = true, euler_number = true))\n\n\nReference\n\nS. B. Gray, “Local Properties of Binary Images in Two Dimensions,” IEEE Transactions on Computers, vol. C–20, no. 5, pp. 551–561, May 1971.\n\n\n\n\n\n","category":"type"},{"location":"reference/#BoundingBox-1","page":"Function Reference","title":"BoundingBox","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"BoundingBox","category":"page"},{"location":"reference/#ImageComponentAnalysis.BoundingBox","page":"Function Reference","title":"ImageComponentAnalysis.BoundingBox","text":"    BoundingBox <: AbstractComponentAnalysisAlgorithm\n    BoundingBox(;  box_area = true)\n    analyze_components(components, f::BoundingBox)\n    analyze_components!(df::AbstractDataFrame, components, f::BoundingBox)\n\nTakes as input an array of labelled connected components and returns a DataFrame with columns that store a tuple of StepRange types that demarcate the minimum (image axis-aligned) bounding box of each component.\n\nThe function can optionally also return the box area.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nmeasurements = analyze_components(components, BoundingBox(box_area = true))\n\n\n\n\n\n\n","category":"type"},{"location":"reference/#MinimumOrientedBoundingBox-1","page":"Function Reference","title":"MinimumOrientedBoundingBox","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"MinimumOrientedBoundingBox","category":"page"},{"location":"reference/#ImageComponentAnalysis.MinimumOrientedBoundingBox","page":"Function Reference","title":"ImageComponentAnalysis.MinimumOrientedBoundingBox","text":"    MinimumOrientedBoundingBox <: AbstractComponentAnalysisAlgorithm\n    MinimumOrientedBoundingBox(;  oriented_box_area = true, oriented_box_aspect_ratio = true)\n    analyze_components(components, f::MinimumOrientedBoundingBox)\n    analyze_components!(df::AbstractDataFrame, components, f::MinimumOrientedBoundingBox)\n\nTakes as input an array of labelled connected components and returns a DataFrame with columns that store a length-4 vector containing the four corner points of the minimum oriented bounding box of each component. It optionally also returns the area and aspect ratio of the minimum oriented bounding box.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nalgorithm = MinimumOrientedBoundingBox(oriented_box_area = true, oriented_box_aspect_ratio = true)\nmeasurements = analyze_components(components, algorithm)\n\n\n\n\n\n\n","category":"type"},{"location":"reference/#Types-1","page":"Function Reference","title":"Types","text":"","category":"section"},{"location":"reference/#DigitalContour-1","page":"Function Reference","title":"DigitalContour","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"DigitalContour","category":"page"},{"location":"#ImageComponentAnalysis.jl-Documentation-1","page":"Home","title":"ImageComponentAnalysis.jl Documentation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"A Julia package for analyzing connected components.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Depth = 3","category":"page"},{"location":"#Getting-started-1","page":"Home","title":"Getting started","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This package is part of a wider Julia-based image processing ecosystem. If you are starting out, then you may benefit from reading about some fundamental conventions that the ecosystem utilizes that are markedly different from how images are typically represented in OpenCV, MATLAB, ImageJ or Python.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The usage examples in the ImageComponentAnalysis.jl package assume that you have already installed some key packages. Notably, the examples assume that you are able to load and display an image. Loading an image is facilitated through the FileIO.jl package, which uses QuartzImageIO.jl if you are on MacOS, and ImageMagick.jl otherwise. Depending on your particular system configuration, you might encounter problems installing the image loading packages, in which case you can refer to the troubleshooting guide.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Image display is typically handled by the ImageView.jl package. However, there are some known issues with this package. For example, on Windows the package has the side-effect of introducing substantial input lag when typing in the Julia REPL. Also, as of writing, some users of MacOS are unable to use the ImageView.jl package.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"As an alternative, one can display an image using the Makie.jl plotting package. There is also the ImageShow.jl package which facilitates displaying images in Jupyter notebooks via IJulia.jl.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Finally, one can also obtain a useful preview of an image in the REPL using the ImageInTerminal.jl package. However, this package assumes that the terminal uses a monospace font, and tends not to produce adequate results in a Windows environment.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Another package that is used to illustrate the functionality in ImageComponentAnalysis.jl is the TestImages.jl which serves as a repository of many standard image processing test images.","category":"page"},{"location":"#Basic-usage-1","page":"Home","title":"Basic usage","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Each connected component analysis algorithm in ImageComponentAnalysis.jl is an AbstractComponentAnalysisAlgorithm.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Suppose one wants to determine the size of each connected component. This can be achieved by simply choosing an appropriate algorithm and calling analyze_components or analyze_components! on an array of labelled components.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Let's see a simple demo:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"using TestImages, ImageComponentAnalysis, ImageBinarization\nusing FileIO # hide\nimg = binarize(testimage(\"cameraman\"), Otsu())\ncomponents = label_components(img)\nmeasurements = analyze_components(components, BasicMeasurement(area = true, perimeter = true))","category":"page"},{"location":"#","page":"Home","title":"Home","text":"This usage reads as \"analyze_components of the label array components with algorithm alg\"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"For more advanced usage, please check function reference page.","category":"page"}]
}
