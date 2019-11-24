var documenterSearchIndex = {"docs":
[{"location":"reference/#function_reference-1","page":"Function Reference","title":"Function References","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"Pages = [\"reference.md\"]\nDepth = 3","category":"page"},{"location":"reference/#General-function-1","page":"Function Reference","title":"General function","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"analyze_components\nanalyze_components!\nlabel_components","category":"page"},{"location":"reference/#ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components","page":"Function Reference","title":"ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components","text":"analyze_components(components::AbstractArray{<:Integer}, f::AbstractComponentAnalysisAlgorithm, args...; kwargs...)\n\nAnalyze enumerated components using algorithm f.\n\nOutput\n\nThe information about the components is stored in a DataFrame, where each row number contains information corresponding to a particular label number.\n\nExamples\n\nJust simply pass the label array and algorithm to analyze_component\n\nf = BasicMeasurement()\nanalyze_components = analyze_component(labels, f)\n\nThis reads as \"analyze_components of label array labels using algorithm f\".\n\nSee also analyze_components! for appending information to an existing DataFrame.\n\n\n\n\n\n","category":"function"},{"location":"reference/#ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components!","page":"Function Reference","title":"ImageComponentAnalysis.ComponentAnalysisAPI.analyze_components!","text":"analyze_components!(dataframe::AbstractDataFrame, components::AbstractArray{<:Integer}, f::AbstractComponentAnalysisAlgorithm, args...; kwargs...)\n\nAnalyze enumerated components using algorithm f.\n\nOutput\n\nThe dataframe will be changed in place.\n\nExamples\n\nJust simply pass an algorithm to analyze_components!:\n\ndf = DataFrame()\nf = BasicMeasurement()\nanalyze_components!(df, components, f)\n\nSee also: analyze_components\n\n\n\n\n\n","category":"function"},{"location":"reference/#ImageComponentAnalysis.label_components","page":"Function Reference","title":"ImageComponentAnalysis.label_components","text":"label_components(tf, [connectivity])\nlabel_components(tf, [region])\n\nFind the connected components in a binary array tf. There are two forms that connectivity can take:\n\nIt can be a boolean array of the same dimensionality as tf, of size 1 or 3\n\nalong each dimension. Each entry in the array determines whether a given neighbor is used for connectivity analyses. For example, connectivity = trues(3,3) would use 8-connectivity and test all pixels that touch the current one, even the corners.\n\nYou can provide a list indicating which dimensions are used to\n\ndetermine connectivity. For example, region = [1,3] would not test neighbors along dimension 2 for connectivity. This corresponds to just the nearest neighbors, i.e., 4-connectivity in 2d and 6-connectivity in 3d. The default is region = 1:ndims(A). The output label is an integer array, where 0 is used for background pixels, and each connected region gets a different integer index.\n\n\n\n\n\n","category":"function"},{"location":"reference/#Algorithms-1","page":"Function Reference","title":"Algorithms","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"ImageComponentAnalysis.ComponentAnalysisAPI.AbstractComponentAnalysisAlgorithm","category":"page"},{"location":"reference/#ImageComponentAnalysis.ComponentAnalysisAPI.AbstractComponentAnalysisAlgorithm","page":"Function Reference","title":"ImageComponentAnalysis.ComponentAnalysisAPI.AbstractComponentAnalysisAlgorithm","text":"AbstractComponentAnalysisAlgorithm <: AbstractComponentAnalysis\n\nThe root type for ImageComponentAnalysis package.\n\nAny concrete component analysis algorithm shall subtype it to support analyze_components and analyze_components! APIs.\n\nExamples\n\nAll component analysis algorithms in ImageComponentAnalysis are called in the following pattern:\n\n# determine the connected components and label them\ncomponents = label_components(img)\n\n# generate an algorithm instance\nf = BasicMeasurement(area = true, perimiter = true)\n\n# then pass the algorithm to `analyze_components`\ndataframe = analyze_components(components, f)\n\n# or use in-place version `analyze_components!`\ng = BoundingBox(area = true)\nanalyze_components!(dataframe, components, g)\n\nMost algorithms receive additional information as an argument, e.g., area or perimeter of BasicMeasurement.\n\n# you can explicit specify whether or not you wish to report certain\n# properties\nf = BasicMeasurement(area = false, perimiter = true)\n\nFor more examples, please check analyze_components, analyze_components! and concrete algorithms.\n\n\n\n\n\n","category":"type"},{"location":"reference/#BasicMeasurement-1","page":"Function Reference","title":"BasicMeasurement","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"BasicMeasurement","category":"page"},{"location":"reference/#ImageComponentAnalysis.BasicMeasurement","page":"Function Reference","title":"ImageComponentAnalysis.BasicMeasurement","text":"    BasicMeasurement <: AbstractComponentAnalysisAlgorithm\n    BasicMeasurement(; area = true,  perimeter = true)\n    analyze_components(labels, f::BasicMeasuremen)\n    analyze_components!(df::AbstractDataFrame, labels, f::BasicMeasuremen)\n\nTakes as input an array of labelled connected-components and returns a data frame with columns that store the area and perimeter of each component.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nmeasurements = analyze_components(components, BasicMeasurement(area = true, perimeter = false))\n\n\n\n\n\n\n","category":"type"},{"location":"reference/#BasicTopology-1","page":"Function Reference","title":"BasicTopology","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"BasicTopology","category":"page"},{"location":"reference/#ImageComponentAnalysis.BasicTopology","page":"Function Reference","title":"ImageComponentAnalysis.BasicTopology","text":"    BasicTopology <: AbstractComponentAnalysisAlgorithm\n    BasicTopology(; holes = true,  euler_number = true)\n    analyze_components(labels, f::BasicTopolgy)\n    analyze_components!(df::AbstractDataFrame, labels, f::BasicTopolgy)\n\nTakes as input an array of labelled connected-components and returns a data frame with columns that store the euler_number and the total number of holes for each component.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nmeasurements = analyze_components(components, BasicTopology(holes = true, euler_number = true))\n\n\n\n\n\n\n","category":"type"},{"location":"reference/#BoundingBox-1","page":"Function Reference","title":"BoundingBox","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"BoundingBox","category":"page"},{"location":"reference/#ImageComponentAnalysis.BoundingBox","page":"Function Reference","title":"ImageComponentAnalysis.BoundingBox","text":"    BoundingBox <: AbstractComponentAnalysisAlgorithm\n    BoundingBox(;  box_area = true)\n    analyze_components(labels, f::BoundingBox)\n    analyze_components!(df::AbstractDataFrame, labels, f::BoundingBox)\n\nTakes as input an array of labelled connected-components and returns a data frame with columns that store a tuple of StepRange types that demarcate the minimum (image axis-aligned) bounding box of each component.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nmeasurements = analyze_components(components, BoundingBox(box_area = true))\n\n\n\n\n\n\n","category":"type"},{"location":"reference/#MinimumOrientedBoundingBox-1","page":"Function Reference","title":"MinimumOrientedBoundingBox","text":"","category":"section"},{"location":"reference/#","page":"Function Reference","title":"Function Reference","text":"MinimumOrientedBoundingBox","category":"page"},{"location":"reference/#ImageComponentAnalysis.MinimumOrientedBoundingBox","page":"Function Reference","title":"ImageComponentAnalysis.MinimumOrientedBoundingBox","text":"    MinimumOrientedBoundingBox <: AbstractComponentAnalysisAlgorithm\n    MinimumOrientedBoundingBox(;  oriented_box_area = true, oriented_box_aspect_ratio = true)\n    analyze_components(labels, f::MinimumOrientedBoundingBox)\n    analyze_components!(df::AbstractDataFrame, labels, f::MinimumOrientedBoundingBox)\n\nTakes as input an array of labelled connected-components and returns a data frame with columns that store a length-4 vector containing the four corner points of the minimum oriented bounding box of each component.\n\nExample\n\nusing ImageComponentAnalysis, TestImages, ImageBinarization, ColorTypes\n\nimg = Gray.(testimage(\"blobs\"))\nimg2 = binarize(img, Otsu())\ncomponents = label_components(img2, trues(3,3), 1)\nmeasurements = analyze_components(components, MinimumOrientedBoundingBox(oriented_box_area = true, oriented_box_aspect_ratio = true))\n\n\n\n\n\n\n","category":"type"},{"location":"#ImageComponentAnalysis.jl-Documentation-1","page":"Home","title":"ImageComponentAnalysis.jl Documentation","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"A Julia package for analyzing connected components.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Depth = 3","category":"page"},{"location":"#Getting-started-1","page":"Home","title":"Getting started","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"This package is part of a wider Julia-based image processing ecosystem. If you are starting out, then you may benefit from reading about some fundamental conventions that the ecosystem utilizes that are markedly different from how images are typically represented in OpenCV, MATLAB, ImageJ or Python.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"The usage examples in the ImageComponentAnalysis.jl package assume that you have already installed some key packages. Notably, the examples assume that you are able to load and display an image. Loading an image is facilitated through the FileIO.jl package, which uses QuartzImageIO.jl if you are on MacOS, and ImageMagick.jl otherwise. Depending on your particular system configuration, you might encounter problems installing the image loading packages, in which case you can refer to the troubleshooting guide.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Image display is typically handled by the ImageView.jl package. However, there are some known issues with this package. For example, on Windows the package has the side-effect of introducing substantial input lag when typing in the Julia REPL. Also, as of writing, some users of MacOS are unable to use the ImageView.jl package.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"As an alternative, one can display an image using the Makie.jl plotting package. There is also the ImageShow.jl package which facilitates displaying images in Jupyter notebooks via IJulia.jl.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Finally, one can also obtain a useful preview of an image in the REPL using the ImageInTerminal.jl package. However, this package assumes that the terminal uses a monospace font, and tends not to produce adequate results in a Windows environment.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Another package that is used to illustrate the functionality in ImageComponentAnalysis.jl is the TestImages.jl which serves as a repository of many standard image processing test images.","category":"page"},{"location":"#Basic-usage-1","page":"Home","title":"Basic usage","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Each connected component analysis algorithm in ImageComponentAnalysis.jl is an AbstractComponentAnalysisAlgorithm.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Suppose one wants to determine the size of each connected component. This can be achieved by simply choosing an appropriate algorithm and calling analyze_components or analyze_components! on an array of labelled components.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Let's see a simple demo:","category":"page"},{"location":"#","page":"Home","title":"Home","text":"using TestImages, ImageComponentAnalysis, ImageBinarization\nusing FileIO # hide\nimg = binarize(testimage(\"cameraman\"), Otsu())\ncomponents = label_components(img)\nmeasurements = analyze_components(components, BasicMeasurement(area = true, perimeter = true))","category":"page"},{"location":"#","page":"Home","title":"Home","text":"This usage reads as \"analyze_components of the label array components with algorithm alg\"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"For more advanced usage, please check function reference page.","category":"page"}]
}
