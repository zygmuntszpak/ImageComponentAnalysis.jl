# ImageComponentAnalysis

[![Build Status](https://travis-ci.com/zygmuntszpak/ImageComponentAnalysis.jl.svg?branch=master)](https://travis-ci.com/zygmuntszpak/ImageComponentAnalysis.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/zygmuntszpak/ImageComponentAnalysis.jl?svg=true)](https://ci.appveyor.com/project/zygmuntszpak/ImageComponentAnalysis-jl)
[![Codecov](https://codecov.io/gh/zygmuntszpak/ImageComponentAnalysis.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/zygmuntszpak/ImageComponentAnalysis.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://zygmuntszpak.github.io/ImageComponentAnalysis.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://zygmuntszpak.github.io/ImageComponentAnalysis.jl/dev)

A Julia package containing a number of algorithms for analyzing connected components
in binary images. In general, the input is an array of labelled components, and the output
is a [DataFrame](https://github.com/JuliaData/DataFrames.jl) where each row
represents a connected component, and each column represents an attribute of
that connected component. When combined with [Query](https://github.com/queryverse/Query.jl)
it affords a very flexible and easy way of filtering connected components
based on their attributes.


The general usage pattern of this package is:

```julia
measurements = analyze_components(components, algorithm::AbstractComponentAnalysisAlgorithm)
```

For more detailed usage and a full list of algorithms, please check the [documentation](https://zygmuntszpak.github.io/ImageComponentAnalysis.jl/stable).
