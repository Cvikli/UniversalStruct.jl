# UniversalStruct.jl
Cacheable, Extendable, Persistable data structure

My favourite data processing pattern to keep everything clean and organized and *fast*! ;)

It uses: 
- [MemoizeTyped.jl](https://github.com/Cvikli/MemoizeTyped.jl)
- [InitLoadableStruct.jl](https://github.com/Cvikli/InitLoadableStruct.jl)
- [ExtendableStruct.jl](https://github.com/Cvikli/ExtendableStruct.jl)
- [PersistableStruct.jl](https://github.com/Cvikli/PersistableStruct.jl)

In short: We *cache* the return value per session, but we also *persist* the unio of the downloaded/loaded datasets on disk between runs. So whenever we need a new data we check the data on disk and if we need new data we only *extend* it and *persist* on the disk. Also we manage the data on the disk, so we don't keep the "older" file versions to take unnecessary spaces and complexity. 


## An example struct 
```julia

mutable struct BasicExample <: Universal
	config::String
	fr::Int
	to::Int
	data::Vector{Float32}
end

BasicExample(conf,fr,to) = BasicExample(conf,fr,to, Float32[])  # This is for init(...) function basically. We need constructor without data!
UniversalStruct.load_data!(obj::BasicExample) = (obj.data = randn(Float32,obj.to-obj.fr); return obj)

# The directory you want the object to persist.
# The default is okay for the folder function ----> folder(obj::T)              where T <: Persistable = mkfolder_if_not_exist("./data")
# The glob pattern that finds the files (You can use asterix to match custom fields)
UniversalStruct.glob_pattern(obj::BasicExample)              = "BasicExample_$(obj.config)_*_*.jld2" # throw("Unimplemented... So basically to get the files list it is advised for you to build this.") #"$(T)_$(obj.config)_*_*"*".jld2"
# The unqiue filename for your 
UniversalStruct.unique_filename(obj::BasicExample)           = "BasicExample_$(obj.config)_$(obj.fr)_$(obj.to).jld2" 
# Get config arguments
# The default is okay for the parse_filename function -----> parse_filename(fname::String)                = split(strip_jld2(fname),"_")
# Convert arguments to value
UniversalStruct.parse_args(args)                          = ((tipe, config, fr, to) = args; return String(tipe), String(config), parse(Int,fr), parse(Int,to))
# Score your files to find the best that should be kept
UniversalStruct.score(data)                               = begin 
	tipe, config, fr, to = data
	return to - fr
end

# Concat two data with same config.
UniversalStruct.append(before::BasicExample, after::BasicExample)    = BasicExample(before.config, before.fr, after.to, vcat(before.data,after.data))

# Do we need new data (in front/after) of our current data?
UniversalStruct.need_data_before(obj::BasicExample, c::BasicExample) = obj.fr < c.fr
UniversalStruct.need_data_after(obj::BasicExample,  c::BasicExample) = c.to < obj.to

# Configure and init the (before/after) object that is able to download the right data with load_data
UniversalStruct.init_before_data(obj::BasicExample, c::BasicExample) = init(T, obj.fr, c.fr, obj.config)
UniversalStruct.init_after_data(obj::BasicExample,  c::BasicExample) = init(T, c.to, obj.to, obj.config)



cached_load(BasicExample, "test",30,43)
cached_load(BasicExample, "test",30,48)
cached_load(BasicExample, "test",21,48)
cached_load(BasicExample, "test",2,48)
cached_load(BasicExample, "test",5,45)
cached_load(BasicExample, "test",9,13)
cached_load(BasicExample, "test",9,12)
```
This very simple struct work nearly out of the box with minor extension of the core interface...

You can also check this Pkg's advanced usage in the CryptoOHLCV.jl

## Disadvantage
- Due to extending the data, we have to have the data continuous. So we cannot have 10:200 and 500:600 data separately, we have to have the data from 10:600 in this case. 

## TODO 
 - `@cache_persist T(args...; kw_args...)` would be nice to prepare the struct cacheing + persistance capabilities easily like this. So the struct would give a feeling of selfmanaged. Always updating itself based on the requirements and persiting itself simply when it is advised.

