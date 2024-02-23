module UniversalStruct


using InitLoadableStruct: InitableLoadable, init
using ExtendableStruct: Extendable, extend!
using PersistableStruct: Persistable, load_disk, save_disk
using MemoizeTyped


# TO overload!
using InitLoadableStruct: load_data!
using ExtendableStruct: append, need_data_before, need_data_after, init_before_data, init_after_data
using PersistableStruct: folder, glob_pattern, unique_filename, parse_filename, parse_args, score

export cached_load, Universal

abstract type Universal <: InitableLoadable end

# cached_load(obj)  where T <: InitableLoadable = @memoize_typed T load(obj) unique_args(obj)
cached_load(t::Type{T}, args...; kw_args...)  where T <: InitableLoadable = @memoize_typed T load(t, args...; kw_args...)
load(t::Type{T}, args...; kw_args...)         where T <: InitableLoadable = load_data!(init(t, args...; kw_args...))
load(t::Type{T}, args...; kw_args...)         where T <: Persistable      = load(init(t, args...; kw_args...))
load(obj::T)                                  where T <: Persistable      = begin
	c = load_disk(obj)

	c, needsave = !isa(c, Nothing) ? extend!(obj,c) : (load_data!(obj), true)
	needsave && save_disk(c, !isa(c, Nothing))
	cut_requested!(obj, c)
end

# cut_requested!(obj::T) where T <: Extendable = return obj
cut_requested!(obj, big_obj)                 = (obj.data = big_obj.data[1+obj.fr-big_obj.fr:end-(big_obj.to-obj.to)]; return obj)




end # module UniversalStruct
