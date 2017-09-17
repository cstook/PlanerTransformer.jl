using PlanerTransformer
using Plots

# define pcb
trace_edge_gap = 0.16e-3
trace_trace_gap = 0.13e-3
outer = copper_weight_to_meters(1.0)
inner = copper_weight_to_meters(1.0)
number_of_layers = 4
dielectric = (1.6e-3-2*outer-2*inner)/(number_of_layers-1)

stackup = Stackup([copper,fr408,copper,fr408,copper,fr408,copper],
                  [outer,dielectric,inner,dielectric,inner,dielectric,outer])
my_pcb = PCB_Specification(trace_edge_gap,
                        trace_trace_gap,
                        stackup)
turns_per_layer = 1:4
my_windings = [windings(my_pcb, core_geometry_dict["e32_plt"],
                        x,x,prisec"P-S-S-P",true,true) for x in turns_per_layer]
material = ferrite_dict["3f4"]
my_transformers = Transformer.(material,my_windings)

frequency = linspace(fmin(material),fmax(material),100)
v_in = 20.0
i_out = -0.5
my_converters = PushPull.(v_in, i_out, frequency)

my_analysis = [transformer_power_analysis.(t,c) for t in my_transformers, c in my_converters]
e = efficiency.(my_analysis)

p = plot()
xlabel!(p,"frequency")
ylabel!(p,"efficency")
for n in turns_per_layer
    plot!(p,frequency,e[n,:],label="$n turns per layer")
end
display(p)
