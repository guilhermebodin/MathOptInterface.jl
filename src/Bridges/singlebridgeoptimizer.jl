"""
    SingleBridgeOptimizer{BT<:AbstractBridge, OT<:MOI.ModelLike} <: AbstractBridgeOptimizer

The `SingleBridgeOptimizer` bridges any constraint supported by the bridge `BT`.
This is in contrast with the [`LazyBridgeOptimizer`](@ref) which only bridges the constraints that are unsupported by the internal model, even if they are supported by one of its bridges.
"""
mutable struct SingleBridgeOptimizer{BT<:AbstractBridge, OT<:MOI.ModelLike} <: AbstractBridgeOptimizer
    model::OT
    con_to_name::Dict{CI, String}
    name_to_con::Union{Dict{String, MOI.ConstraintIndex}, Nothing}
    # Constraint Index of bridged constraint -> Bridge.
    # It is set to `nothing` when the constraint is deleted.
    bridges::Vector{Union{Nothing, AbstractBridge}}
    # Constraint Index of bridged constraint -> Constraint type.
    constraint_types::Vector{Tuple{DataType, DataType}}
end
function SingleBridgeOptimizer{BT}(model::OT) where {BT, OT <: MOI.ModelLike}
    SingleBridgeOptimizer{BT, OT}(
        model, Dict{CI, String}(), nothing,
        Union{Nothing, AbstractBridge}[], Tuple{DataType, DataType}[])
end

function supports_bridging_constraint(b::SingleBridgeOptimizer{BT},
                                      F::Type{<:MOI.AbstractFunction},
                                      S::Type{<:MOI.AbstractSet}) where BT
    return MOI.supports_constraint(BT, F, S)
end
function is_bridged(b::SingleBridgeOptimizer, F::Type{<:MOI.AbstractFunction},
                    S::Type{<:MOI.AbstractSet})
    return supports_bridging_constraint(b, F, S)
end
bridge_type(b::SingleBridgeOptimizer{BT}, ::Type{<:MOI.AbstractFunction}, ::Type{<:MOI.AbstractSet}) where BT = BT
