using Test: @test, @testset, @test_throws
using PowerDynamics: SlackAlgebraic,StaticLine, SwingEqLVS, PowerGrid, systemsize, rhs,PiModelLine,find_operationpoint
using LightGraphs: edges, Edge, nv, ne
using OrdinaryDiffEq: ODEFunction
using OrderedCollections: OrderedDict


#test whether order of node or lines construction changes the power grid graph or operation point

nodes_1 = [SlackAlgebraic(U=1), SwingEqLVS(H=1, P=-1, D=1, Ω=50, Γ=20, V=1), SwingEqLVS(H=1, P=1, D=1, Ω=50, Γ=20, V=1)]
lines_1 = [StaticLine(from=1, to=2, Y=0*5im),PiModelLine(;from=2, to=3, y = 1/(0.1152 + im*0.0458), y_shunt_km = 0.,  y_shunt_mk = 0.)]
power_grid_1 = PowerGrid(nodes_1,lines_1)

nodes_2 = [SlackAlgebraic(U=1), SwingEqLVS(H=1, P=-1, D=1, Ω=50, Γ=20, V=1),SwingEqLVS(H=1, P=1, D=1, Ω=50, Γ=20, V=1)]
lines_2 = [PiModelLine(;from=2, to=3, y = 1/(0.1152 + im*0.0458), y_shunt_km = 0.,  y_shunt_mk = 0.),StaticLine(from=1, to=2, Y=0*5im)]
power_grid_2 = PowerGrid(nodes_2,lines_2)

@test collect(edges(power_grid_1.graph))[1]==collect(edges(power_grid_2.graph))[1]
@test collect(edges(power_grid_1.graph))[2]==collect(edges(power_grid_2.graph))[2]

# nodes_3 = [SwingEqLVS(H=1, P=-1, D=1, Ω=50, Γ=20, V=1),SlackAlgebraic(U=1), SwingEqLVS(H=1, P=1, D=1, Ω=50, Γ=20, V=1)]
# lines_3 = [PiModelLine(;from=1, to=3, y = 1/(0.1152 + im*0.0458), y_shunt_km = 0.,  y_shunt_mk = 0.),StaticLine(from=2, to=1, Y=0*5im)]
# power_grid_3 = PowerGrid(nodes_3,lines_3)
# op2 = find_operationpoint(power_grid_2)
# op3 = find_operationpoint(power_grid_3)
# @test op2[3]-op3[1]<=1*10^-3
# @test op2[1]-op3[4]<=1*10^-3


##

nodes = [SlackAlgebraic(U=1), SwingEqLVS(H=1, P=-1, D=1, Ω=50, Γ=20, V=1)]
dnodes = ["bus$i" => nodes[i] for i in 1:length(nodes)]
lines = [StaticLine(from=1, to=2, Y=0*5im)]
dlines = ["line$i" => lines[i] for i in 1:length(lines)]
lines_string = [StaticLine(from="bus1", to="bus2", Y=0*5im)]
dlines_string = ["line$i" => lines_string[i] for i in 1:length(lines_string)]

##

# test array constructor
power_grid = PowerGrid(nodes, lines)
@test power_grid isa PowerGrid

@test_throws AssertionError PowerGrid(nodes, lines_string)

##

# test dict constructor
power_grid_fromdict = PowerGrid(OrderedDict(dnodes), OrderedDict(dlines_string))
@test power_grid_fromdict isa PowerGrid

@test_throws AssertionError PowerGrid(OrderedDict(dnodes), OrderedDict(dlines))

## test invalid input

@test_throws ErrorException PowerGrid(Dict(dnodes), Dict(dlines_string))
@test_throws ErrorException PowerGrid(OrderedDict(dnodes), lines_string)
@test_throws ErrorException PowerGrid(nodes, OrderedDict(dlines))

##
@test systemsize(power_grid) == 5 # -> u_r_sl, u_i_sl, u_r_sw, u_i_sw, omega_sw
@test systemsize(power_grid_fromdict) == 5 # -> u_r_sl, u_i_sl, u_r_sw, u_i_sw, omega_sw

@test nv(power_grid.graph) == 2
@test nv(power_grid_fromdict.graph) == 2

@test ne(power_grid.graph) == 1
@test ne(power_grid_fromdict.graph) == 1

@test collect(edges(power_grid.graph)) == [Edge(1,2)]
@test collect(edges(power_grid_fromdict.graph)) == [Edge(1,2)]

@test rhs(power_grid) isa(ODEFunction)
@test rhs(power_grid_fromdict) isa(ODEFunction)
