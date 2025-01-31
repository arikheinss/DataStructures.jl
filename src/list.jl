

struct Nil{T} end

struct Cons{T}
    head::T
    tail::Union{Nil{T}, Cons{T}}
end

const LinkedList{T} = Union{Nil{T}, Cons{T}}

Base.eltype(::Type{<:LinkedList{T}}) where T = T

cons(h, t::LinkedList{T}) where {T} = Cons{T}(h, t)

nil(T) = Nil{T}()
nil() = nil(Any)

head(x::Cons) = x.head
tail(x::Cons) = x.tail

Base.:(==)(x::Nil, y::Nil) = true
function Base.:(==)(x::LinkedList, y::LinkedList) 
    # can be changed to the more elegant
    # Base.:(==)(x::Cons, y::Cons) = (x.head == y.head) && (x.tail == y.tail)
    # once julia supports tail call recursions
    while x  isa Cons && y isa Cons
        x.head == y.head || return false
        x = x.tail
        y = y.tail
    end
    if x isa Cons || y isa Cons
        return false
    end
    return true
end

function Base.show(io::IO, l::LinkedList{T}) where T
    if isa(l,Nil)
        if T === Any
            print(io, "nil()")
        else
            print(io, "nil(", T, ")")
        end
    else
        print(io, "list(")
        show(io, head(l))
        for t in tail(l)
            print(io, ", ")
            show(io, t)
        end
        print(io, ")")
    end
end

list() = nil()

function list(elts...)
    l = nil(Base.promote_typeof(elts...))
    for i=length(elts):-1:1
        l = cons(elts[i],l)
    end
    return l
end

function list(elts::T...) where T
    l = nil(T)
    for i=length(elts):-1:1
        l = cons(elts[i],l)
    end
    return l
end

Base.length(l::Nil) = 0

function Base.length(l::Cons)
    n = 0
    for i in l
        n += 1
    end
    return n
end

Base.map(f::Base.Callable, l::Nil) = l

function Base.map(f::Base.Callable, l::Cons{T}) where T
    first = f(l.head)
    l2 = cons(first, nil(typeof(first) <: T ? T : typeof(first)))
    for h in l.tail
        l2 = cons(f(h), l2)
    end
    reverse(l2)
end

function Base.filter(f::Function, l::LinkedList{T}) where T
    l2 = nil(T)
    for h in l
        if f(h)
            l2 = cons(h, l2)
        end
    end
    reverse(l2)
end

function Base.reverse(l::LinkedList{T}) where T
    l2 = nil(T)
    for h in l
        l2 = cons(h, l2)
    end
    return l2
end

Base.copy(l::Nil) = l

function Base.copy(l::Cons)
    l2 = reverse(reverse(l))
end

Base.cat(lst::LinkedList) = lst

function Base.cat(lst::LinkedList, lsts::LinkedList...)
    T = typeof(lst).parameters[1]
    n = length(lsts)
    for i = 1:n
        T2 = typeof(lsts[i]).parameters[1]
        T = typejoin(T, T2)
    end

    l2 = nil(T)
    for h in lst
        l2 = cons(h, l2)
    end

    for i = 1:n
        for h in lsts[i]
            l2 = cons(h, l2)
        end
    end

    reverse(l2)
end

Base.iterate(l::LinkedList, ::Nil) = nothing
function Base.iterate(l::LinkedList, state::Cons = l)
    state.head, state.tail
end
