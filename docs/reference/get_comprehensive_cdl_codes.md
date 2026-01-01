# Get comprehensive CDL crop codes

Get USDA Cropland Data Layer (CDL) codes for specific crops or crop
categories. Supports all major crops and predefined categories.

## Usage

``` r
get_comprehensive_cdl_codes(crop_type = "all")
```

## Arguments

- crop_type:

  Crop type or category name. Options include:

  - Individual crops: "corn", "soybeans", "wheat", etc.

  - Categories: "grains", "oilseeds", "fruits", "vegetables", etc.

  - "all" for all available codes

## Value

Vector of CDL codes

## Examples

``` r
# \donttest{
# Get corn code
corn_codes <- get_comprehensive_cdl_codes("corn")
print(corn_codes)  # Should be 1
#> [1] 1

# Get all grain crop codes
grain_codes <- get_comprehensive_cdl_codes("grains")
print(grain_codes)  # Should be vector of grain codes
#>  [1]  1  4 21 22 23 24 25 27 28 29 30

# See available crop types (this will print to console)
get_comprehensive_cdl_codes("help")
#> Available crop types and categories:
#> 
#> Individual crops:
#>  [1] "corn"                     "cotton"                  
#>  [3] "rice"                     "sorghum"                 
#>  [5] "soybeans"                 "sunflower"               
#>  [7] "peanuts"                  "tobacco"                 
#>  [9] "sweet_corn"               "pop_or_orn_corn"         
#> [11] "mint"                     "barley"                  
#> [13] "durum_wheat"              "spring_wheat"            
#> [15] "winter_wheat"             "other_small_grains"      
#> [17] "dbl_crop_winwht_soybeans" "rye"                     
#> [19] "oats"                     "millet"                  
#> [21] "speltz"                   "canola"                  
#> [23] "flaxseed"                 "safflower"               
#> [25] "rape_seed"                "mustard"                 
#> [27] "alfalfa"                  "other_hay_non_alfalfa"   
#> [29] "camelina"                 "buckwheat"               
#> [31] "sugarbeets"               "dry_beans"               
#> [33] "potatoes"                 "other_crops"             
#> [35] "sugarcane"                "sweet_potatoes"          
#> [37] "misc_vegs_fruits"         "watermelons"             
#> [39] "onions"                   "cucumbers"               
#> [41] "chick_peas"               "lentils"                 
#> [43] "peas"                     "tomatoes"                
#> [45] "caneberries"              "hops"                    
#> [47] "herbs"                    "clover_wildflowers"      
#> [49] "sod_grass_seed"           "switchgrass"             
#> [51] "fallow_idle_cropland"     "cherries"                
#> [53] "peaches"                  "apples"                  
#> [55] "grapes"                   "christmas_trees"         
#> [57] "other_tree_crops"         "citrus"                  
#> [59] "pecans"                   "almonds"                 
#> [61] "walnuts"                  "pears"                   
#> [63] "carrots"                  "asparagus"               
#> [65] "garlic"                   "cantaloupes"             
#> [67] "prunes"                   "olives"                  
#> [69] "oranges"                  "honeydew_melons"         
#> [71] "broccoli"                 "avocados"                
#> [73] "peppers"                  "pomegranates"            
#> [75] "nectarines"               "greens"                  
#> [77] "plums"                    "strawberries"            
#> [79] "squash"                   "apricots"                
#> [81] "vetch"                    "dbl_crop_oats_corn"      
#> [83] "lettuce"                  "pasture_grass"           
#> [85] "grassland_pasture"        "deciduous_forest"        
#> [87] "evergreen_forest"         "mixed_forest"            
#> [89] "water"                    "perennial_ice_snow"      
#> [91] "herbaceous_wetlands"      "woody_wetlands"          
#> [93] "developed_open_space"     "developed_low_intensity" 
#> [95] "developed_med_intensity"  "developed_high_intensity"
#> [97] "barren"                   "shrubland"               
#> [99] "grassland_herbaceous"    
#> 
#> Crop categories:
#>  [1] "grains"           "oilseeds"         "fruits"           "vegetables"      
#>  [5] "legumes"          "forage"           "specialty"        "food_crops"      
#>  [9] "feed_crops"       "industrial_crops" "all_crops"       
# }
```
