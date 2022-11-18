
using Zygote: @adjoint
import Base: zero, one, convert, adjoint, promote_rule

export TaylorScalar

struct TaylorScalar{T<:Number,N}
    value::NTuple{N,T}
end

TaylorScalar(xs::Vararg{T,N}) where {T<:Number,N} = TaylorScalar(xs)
value(t::TaylorScalar) = t.value

zero(::TaylorScalar{T,N}) where {T, N} = TaylorScalar(zeros(T, N)...)
one(::TaylorScalar{T,N}) where {T, N} = TaylorScalar(one(T), zeros(T, N-1)...)

zero(::Type{TaylorScalar{T,N}}) where {T, N} = TaylorScalar(zeros(T, N)...)
one(::Type{TaylorScalar{T,N}}) where {T, N} = TaylorScalar(one(T), zeros(T, N-1)...)

adjoint(t::TaylorScalar) = t
promote_rule(::Type{TaylorScalar{T,N}}, ::Type{S}) where {T<:Number,S<:Number,N} = TaylorScalar{promote_type(T,S),N}
convert(::Type{TaylorScalar{T,N}}, x::T) where {T<:Number,N} = TaylorScalar(x, zeros(T, N - 1)...)
convert(::Type{TaylorScalar{T,N}}, x::S) where {T<:Number,S<:Number,N} = TaylorScalar(convert(T, x), zeros(T, N - 1)...)
convert(::Type{TaylorScalar{T,N}}, x::TaylorScalar{S,N}) where {T<:Number,S<:Number,N} = TaylorScalar([convert(T, v) for v in value(x)]...)

@adjoint value(t::TaylorScalar) = value(t), v̄ -> (TaylorScalar(v̄),)
@adjoint TaylorScalar(v) = TaylorScalar(v), t̄ -> (t̄.value,)
@adjoint getindex(t::NTuple{N,T}, i::Int) where {N, T<:Number} = getindex(t, i), v̄ -> (tuple(zeros(T,i-1)..., v̄, zeros(T, N-i)...), nothing)
