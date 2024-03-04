module UniversalStruct

using Unimplemented

using InitLoadableStruct: InitableLoadable
using ExtendableStruct: Extendable, extend!
using PersistableStruct: Persistable, load_disk, save_disk


# TO overload!
using InitLoadableStruct: init, load_data!
using ExtendableStruct: append, need_data_before, need_data_after, init_before_data, init_after_data
using PersistableStruct: folder, glob_pattern, unique_filename, parse_filename, parse_args, score,
sure_folder, unique_filename


export cached_load, load, Universal

abstract type Universal <: Persistable end

# cached_load(obj)  where T <: InitableLoadable = @memoize_typed T load(obj) unique_args(obj)
# cached_load(t::Type{T}, args...; kw_args...)  where T <: InitableLoadable = @memoize_typed T load(t, args...; kw_args...)
load(t::Type{T}, args...; kw_args...)   where T <: InitableLoadable = load_data!(init(t, args...; kw_args...))
load(t::Type{T}, args...; kw_args...)   where T <: Persistable      = load(init(t, args...; kw_args...))
load(t::Type{T}, args...; kw_args...)   where T <: Universal        = load(init(t, args...; kw_args...))
load(obj::T)                            where T <: Persistable      = isfile((file_name=sure_folder(obj) * unique_filename(obj);)) ? load_disk(file_name) : save_disk(load_data!(obj), false)
load(obj::T)                            where T <: Universal        = begin # we could pass args and kw_args too...
	c = load_disk(obj)
	c, needsave = !isa(c, Nothing) ? extend!(obj,c) : (load_data!(obj), true)
	needsave && save_disk(c, !isa(c, Nothing))
	cut_requested!(obj, c)
end

# cut_requested!(obj::T) where T <: Extendable = return obj
@interface cut_requested!(obj, big_obj)              #   = (obj.data = big_obj.data[1+obj.fr-big_obj.fr:end-(big_obj.to-obj.to)]; return obj)




end # module UniversalStruct
