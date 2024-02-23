module UniversalStruct


using PersistableStruct: Persistable

cached_load(t::Type{T}, args...; kw_args...)  where T <: InitableLoadable = @memoize_typed T load(t, args...; kw_args...)
load(t::Type{T}, args...; kw_args...) where T <: InitableLoadable = load_data!(init(t, args...; kw_args...))
load(t::Type{T}, args...; kw_args...) where T <: Persistable = begin
	obj=init(t, args...; kw_args...) 
	c = load_disk(obj)
	obj, needsave = !isa(c, Nothing) ? extend!(obj,c) : (load_data!(obj), true)
	needsave && save_disk(obj, !isa(c, Nothing))
	cut_requested!(obj)
end

cut_requested!(obj::T) where T <: Extendable = return obj
cut_requested!(obj, big_obj)                 = obj.data = big_obj.data[1+obj.fr-big_obj.fr:end-(big_obj.to-obj.to)]




end # module UniversalStruct
