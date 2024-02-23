


using UniversalStruct

mutable struct BasicExample <: Persistable
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

