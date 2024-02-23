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
using ExtendableStruct

mutable struct BasicExample <: Extendable
	config::String
	fr::Int
	to::Int
	data::Vector{Float32}
end



ExtendableStruct.glob_pattern(obj::BasicExample) = "BasicExample_$(obj.config)_*_*"*".jld2"
ExtendableStruct.load_data(obj::BasicExample)     = begin
	obj.data=randn(Float32,obj.to-obj.fr)
	obj
end
ExtendableStruct.load_data(T::Type{BasicExample}, fr, to, conf) = T(conf,fr,to,randn(Float32,to-fr))
ExtendableStruct.append(cache::BasicExample,  after::BasicExample) = BasicExample(cache.config, cache.fr, after.to, vcat(cache.data,after.data)) 
ExtendableStruct.prepend(before::BasicExample,cache::BasicExample) = BasicExample(cache.config, before.fr, cache.to, vcat(before.data,cache.data)) 
ExtendableStruct.is_same(o1::BasicExample, o2::BasicExample) = return o1.config == o2.config && o1.fr == o2.fr && o1.to == o2.to



merge_load(BasicExample("test",30,43,Float32[]))
merge_load(BasicExample("test",30,48,Float32[]))
merge_load(BasicExample("test",21,48,Float32[]))
merge_load(BasicExample("test",2,48,Float32[]))
merge_load(BasicExample("test",5,45,Float32[]))
```
This very simple struct work nearly out of the box with minor extension of the core interface...

You can also check this Pkg's advanced usage in the CryptoOHLCV.jl

## Disadvantage
- Due to extending the data, we have to have the data continuous. So we cannot have 10:200 and 500:600 data separately, we have to have the data from 10:600 in this case. 

## TODO 
 - `@cache_persist T(args...; kw_args...)` would be nice to prepare the struct cacheing + persistance capabilities easily like this. So the struct would give a feeling of selfmanaged. Always updating itself based on the requirements and persiting itself simply when it is advised.

