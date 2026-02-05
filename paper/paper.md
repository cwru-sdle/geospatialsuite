---
title: 'geospatialsuite: Comprehensive Geospatiotemporal Analysis and Multimodal Integration Toolkit for R'
tags:
- R
- geospatial analysis
- remote sensing
- vegetation indices
- NDVI
- spatial interpolation
- terra
- sf
- agricultural research
- environmental monitoring
date: "28 December 2025"
output:
  html_document:
    df_print: paged
  pdf_document: default
bibliography: paper.bib
authors:
- name: Olatunde D. Akanbi
  orcid: "0000-0001-7719-2619"
  equal-contrib: true
  affiliation: '1'
  corresponding: true
- name: Vibha Mandayam
  orcid: "0009-0008-8628-9904"
  equal-contrib: true
  affiliation: '1'
- name: Yinghui Wu
  orcid: "0000-0003-3991-5155"
  affiliation: '1'
- name: Jeffrey Yarus
  orcid: "0000-0002-9331-9568"
  affiliation: '1'
- name: Erika I. Barcelos
  orcid: "0000-0002-9273-8488"
  affiliation: '1'
- name: Roger H. French
  orcid: "0000-0002-6162-0532"
  affiliation: '1'
affiliations:
- name: Case Western Reserve University, Cleveland, OH, USA
  index: 1
  ror: 051fd9666
---


# Summary

Geospatial analysis in environmental and agricultural research requires reliable, standardized tools that can handle diverse datasets across different geographic regions and satellite platforms. geospatialsuite is a comprehensive R package for geospatiotemporal analysis that provides researchers with a unified toolkit for multimodal spatial data integration. The package features over 60 vegetation indices with automatic satellite band detection, universal spatial join operations that work with any raster-vector combination, robust raster visualization with built-in error handling, and rapid mapping capabilities through the `quick_map()` function. Designed for reliability and universal applicability, geospatialsuite addresses critical needs in agricultural research, environmental monitoring, and remote sensing applications while maintaining computational efficiency for large datasets.

The package seamlessly integrates with the modern R spatial ecosystem through `terra` [@hijmans2022terra] and `sf` [@pebesma2018simple], providing enhanced NDVI calculations with quality filtering, comprehensive water quality analysis using multiple indices (NDWI [@mcfeeters1996normalized], MNDWI [@xu2006modification], NDMI), crop data layer (CDL) analysis [@usda2024cdl], spatial interpolation techniques [@cressie1993statistics], and terrain analysis. Unlike existing solutions that are often limited by complex dependencies or geographic scope, geospatialsuite emphasizes universal functionalityâ€”working seamlessly across different regions, satellite platforms (Landsat, Sentinel-2, MODIS), and data types with comprehensive error handling throughout. The package has enabled research in agricultural systems monitoring [@akanbi2024multiscale] and multimodal data integration [@akanbi2024integrating].

# Statement of Need

While foundational packages like `terra` [@hijmans2022terra] and `sf` [@pebesma2018simple] provide essential spatial data handling capabilities, researchers often face significant challenges when attempting to integrate multiple data sources, calculate specialized indices, or create reliable visualizations from large raster datasets.

Current solutions in the R ecosystem present several critical limitations: vegetation index packages typically cover only a subset of available indices and lack automatic band detection across different satellite platforms; spatial join operations often fail with edge cases or require extensive preprocessing; visualization tools frequently encounter memory issues with large rasters or produce inconsistent results; and multimodal data integration requires custom workflows that are difficult to reproduce, error-prone, and time-consuming to implement.

geospatialsuite addresses these fundamental challenges through several key innovations:

**Universal spatial operations with robust error handling**: The package provides a universal spatial join function that reliably handles any raster-vector combination with comprehensive error checking, automatic coordinate system handling, and graceful failure recovery. This eliminates the common frustrations researchers face when working with diverse spatial datasets.

**Comprehensive vegetation analysis with automatic detection**: Over 60 vegetation indices including NDVI [@rouse1974monitoring], EVI [@huete2002overview], SAVI [@rondeaux1996optimization], and ARVI [@kaufman1992atmospherically] with automatic band detection that works seamlessly across Landsat, Sentinel-2, and MODIS platforms. Quality filtering and standardized output formats ensure consistent results regardless of input data source.

**Reliable visualization for large datasets**: Built on `terra`'s efficient raster handling, `quick_map()` maintains constant memory usage (~75 MB) regardless of raster size while providing substantial performance advantages over data frame-based visualization approaches. Benchmarking demonstrates 4.2× faster execution and 7.6× better memory efficiency compared to ggplot2 for realistic satellite imagery (5,000×5,000 pixels), with performance advantages increasing at larger scales. The visualization system includes robust error handling that prevents common plotting failures.

**Performance Comparison**

Benchmarking `quick_map()` against comparable functions demonstrates:

| Method | Memory (5K×5K) | Time (5K×5K) |
|--------|----------------|--------------|
| `quick_map()` | 75 MB | 684 ms |
| `terra::plot()` | 75 MB | 675 ms |
| `ggplot2::geom_raster()` | 572 MB | 2,897 ms |

For realistic satellite imagery, `quick_map()` demonstrates 7.6× better 
memory efficiency and 4.2× faster execution compared to ggplot2.

![Example output from geospatialsuite's `quick_map()` function demonstrating universal spatial mapping capabilities. The function automatically detects data types, coordinate systems, and optimal visualization parameters, requiring only a single line of code to produce publication-quality maps from any spatial data format.](../img/quick.png){#fig:quickmap width=90%}

**Multimodal integration workflows**: Streamlined functions for combining satellite imagery, weather data, crop data layers, and administrative boundaries with built-in spatial and temporal alignment, quality checks, and standardized output formats. This addresses the type of complex geospatial analysis challenges found across diverse research domains [@gordon2025geospatial].

The package architecture prioritizes reproducibility, computational efficiency, and ease of use through comprehensive documentation, extensive testing, and a consistent API design. This approach has proven essential in research funded by the National Science Foundation Engineering Research Center for Advancing Sustainable and Distributed Fertilizer Production (CASFER), where reliable geospatial analysis tools are critical for understanding agricultural systems at multiple scales [@akanbi2024multiscale; @akanbi2024leveraging].

geospatialsuite fills a critical gap by providing a single, well-documented package that handles the most common geospatial analysis challenges with the reliability and consistency required for reproducible science, while maintaining the flexibility needed for specialized research applications.

# Software Architecture

geospatialsuite is organized into 10 functional categories comprising 165 functions (Figure 2), designed to provide comprehensive geospatial analysis capabilities while maintaining ease of use and reliability. The package architecture emphasizes modularity, with each functional category serving specific analytical needs while integrating seamlessly with other components.

![geospatialsuite functional organization showing the 10 major categories of functions: Core Spatial Operations, Water Quality and Indices, Spatial Interpolation, Testing & Validation, Utility Functions, Temporal Analysis, Data Processing, Visualization & Mapping, Comprehensive Workflows, and Vegetation Analysis.](../img/fig2.png){#fig:architecture width=70%}

The core design philosophy centers on universal compatibility and robust error handling. Functions automatically detect data types, coordinate systems, and optimal processing methods, reducing the technical barrier for researchers while maintaining the flexibility needed for advanced applications. This architecture enables both novice users to quickly generate results and experienced researchers to implement sophisticated analytical workflows.

# Availability

geospatialsuite is available on the Comprehensive R Archive Network (CRAN) at https://cran.r-project.org/web/packages/geospatialsuite/ and can be installed using `install.packages("geospatialsuite")`. The source code is actively maintained on GitHub with comprehensive documentation, examples, and issue tracking to support the research community.

# Acknowledgements

This material is based upon financial support by the National Science Foundation, EEC Division of Engineering Education and Centers, NSF Engineering Research Center for Advancing Sustainable and Distributed Fertilizer production (CASFER), NSF 20-553 Gen-4 Engineering Research Centers award 2133576. The authors thank the broader Solar Durablity and Lifetime Extension (SDLE) research community for feedback and testing that improved the package's functionality and usability.

# References
