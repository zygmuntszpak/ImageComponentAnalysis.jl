# ImageComponentAnalysis.jl Documentation

A Julia package for analyzing connected components.

```@contents
Depth = 3
```

## Getting started
This package is part of a wider Julia-based image processing
[ecosystem](https://github.com/JuliaImages). If you are starting out, then you
may benefit from [reading](https://juliaimages.org/latest/quickstart/) about
some fundamental conventions that the ecosystem utilizes that are markedly
different from how images are typically represented in OpenCV, MATLAB, ImageJ or
Python.

The usage examples in the `ImageComponentAnalysis.jl` package assume that you have
already installed some key packages. Notably, the examples assume that you are
able to load and display an image. Loading an image is facilitated through the
[FileIO.jl](https://github.com/JuliaIO/FileIO.jl) package, which uses
[QuartzImageIO.jl](https://github.com/JuliaIO/QuartzImageIO.jl) if you are on
`MacOS`, and [ImageMagick.jl](https://github.com/JuliaIO/ImageMagick.jl)
otherwise. Depending on your particular system configuration, you might
encounter problems installing the image loading packages, in which case you can
refer to the [troubleshooting
guide](https://juliaimages.org/latest/troubleshooting/#Installation-troubleshooting-1).

Image display is typically handled by the
[ImageView.jl](https://github.com/JuliaImages/ImageView.jl) package. However,
there are some known issues with this package. For example, on `Windows` the
package has the side-effect of introducing substantial [input
lag](https://github.com/JuliaImages/ImageView.jl/issues/176) when typing in the
Julia REPL. Also, as of writing, some users of `MacOS` are [unable to
use](https://github.com/JuliaImages/ImageView.jl/issues/175) the `ImageView.jl`
package.

As an alternative, one can display an image using the
[Makie.jl](https://github.com/JuliaPlots/Makie.jl) plotting package. There is
also the [ImageShow.jl](https://github.com/JuliaImages/ImageShow.jl) package
which facilitates displaying images in `Jupyter` notebooks via
[IJulia.jl](https://github.com/JuliaLang/IJulia.jl).

Finally, one can also obtain a useful preview of an image in the REPL using the
[ImageInTerminal.jl](https://github.com/JuliaImages/ImageInTerminal.jl) package.
However, this package assumes that the terminal uses a monospace font, and tends
not to produce adequate results in a Windows environment.

Another package that is used to illustrate the functionality in
`ImageComponentAnalysis.jl` is the
[TestImages.jl](https://github.com/JuliaImages/TestImages.jl) which serves as a
repository of many standard image processing test images.


## Basic usage

Each connected component analysis algorithm in `ImageComponentAnalysis.jl` is an
[`AbstractComponentAnalysisAlgorithm`](@ref ImageComponentAnalysis.ComponentAnalysisAPI.AbstractComponentAnalysisAlgorithm).

Suppose one wants to determine the size of each connected component. This can be
achieved by simply choosing an appropriate algorithm and calling
[`analyze_components`](@ref) or [`analyze_components!`](@ref) on an array of
labelled components.

Let's see a simple demo:

```@example
using TestImages, ImageComponentAnalysis, ImageBinarization
using FileIO # hide
img = binarize(testimage("cameraman"), Otsu())
components = label_components(img)
measurements = analyze_components(components, BasicMeasurement(area = true, perimeter = true))
```

This usage reads as "`analyze_components` of the label array `components` with
algorithm `alg`"

For more advanced usage, please check [function reference](@ref
function_reference) page.
