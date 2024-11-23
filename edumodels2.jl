### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ a3c707eb-2dbd-4ede-80e9-0e4c90e01154
using PlutoUI, Plots, Distributions, QuadGK, Printf, PGFPlotsX


# ╔═╡ 41571ca1-d1a0-4761-8672-c20d30e37786
pgfplotsx()
# plotly()
# pythonplot()
# gr()

# ╔═╡ fad8a8e2-141a-4f54-a822-150ecdcbde5a
md"# edumodels 2.0

this pluto.jl notebook provides a toy model of a system of education. 

edumodels 2.0 improves on edumodels 1.0 in various ways. additional features include: more control over distribution policies; proper modeling of the costs of provision; and a full array of functions for finding distributions with particular properies; better plotting. 
"

# ╔═╡ 7a83590e-488e-41b7-a4ed-303956cc0359
md"### model settings

here are the main settings we will want to play vary in our model. these variables can be modified by the user. other variables can be changed by changing the relevant code.
"

# ╔═╡ a3a348bf-6e2c-4775-b1c6-26fa602b319a
md"choose an ability setting for A:"

# ╔═╡ a8c8c80a-2e0f-4f34-92b5-3f872a4249c6
md"choose an ability setting for B:"

# ╔═╡ e7b6f564-a08e-43b1-b602-b10a935ad94a
md"choose a baseline distribution of opportunities for A and B. this is the baseline relative to which we assess our policies. we do not consider the cost of provision for the baseline distribution of opportunities. you will typically want to begin with an equal baseline. however unequal baselines are useful for modelling differences in social class background between A and B. 

choose a baseline distribution of opportunties for A (default=40):"

# ╔═╡ 22598207-1e0f-444b-9064-5cc818305d83
# set the baseline distribution of opportunities 
@bind baselineA_ NumberField(0:200, default=40)

# ╔═╡ 5cd30ea0-0bb9-4745-abb5-1d5c99f09507
md"choose a baseline distribution of opportunities for B (default=40):"

# ╔═╡ 6a48a6c4-a3cc-4d9f-9a5d-de72d8a1a306
# set the baseline distribution of opportunities 
@bind baselineB_ NumberField(0:200, default=40)

# ╔═╡ 8bcb854d-cb45-4ed4-bc0f-8e5d0c693d27
md"choose the total number of additional opportunities to distribute (default=20):"

# ╔═╡ 69b27cb2-720f-44bd-8cdf-b33bd1e0399f
# set the total opportunities available to distribute 
@bind totalopportunities_ NumberField(0:200, default=20)

# ╔═╡ 9c87ab70-aa58-4130-989d-363779557d2c
md"choose a discount rate on A's proportion of the opportunities (default=1):"

# ╔═╡ eb6dc23e-6307-4585-9010-5cc9efb582e9
@bind discountA_ NumberField(0:0.1:1, default=1)

# ╔═╡ 3fd76120-b631-4022-a6dd-6c9f4ec06aa3
md"scale up the benefits of education (default 1, higher numbers make education more important):" 

# ╔═╡ 2a873e8b-71d6-4e53-840b-f37c645f06d1
@bind eduscale_ NumberField(0:0.05:1, default=0.2)

# ╔═╡ 3168827b-1e31-408d-9ec3-53e725872e5e
md"choose the default life prospects for the top ranked (default=0.8):" 

# ╔═╡ 943a2a24-5ee7-42b9-bed3-868148d1781a
@bind toplifeprospects_ NumberField(0:0.05:1, default=0.8)

# ╔═╡ 24794095-f20d-4fe8-9aa9-e862d8d73786
md"choose the default life prospects for the top ranked (default=0.5):" 

# ╔═╡ 37e0d7dc-c92f-4163-a239-ef794cbefa3e
@bind bottomlifeprospects_ NumberField(0:0.05:1, default=0.5)

# ╔═╡ b7bd8235-5bf9-4bbc-ac30-07ef17bd9d8b
md"choose the cost of an opportunity (default=0):"

# ╔═╡ 7588880c-2c3a-4b19-950d-e21faf015105
@bind unitcost_ NumberField(0:20, default=0)

# ╔═╡ 8f7951a7-1fde-4783-8cf4-26412041fc77
md"choose the default life prospects for bystanders (default=0.5):" 

# ╔═╡ 53444608-183c-4bc4-a619-cf0704515a77
@bind bystanderlifeprospects_ NumberField(0:0.05:1, default=0.5)

# ╔═╡ 97bad24c-f88a-4709-9130-7187536fb99b
md"## trade-offs"

# ╔═╡ b00c0a99-fa37-4dd2-8c3b-aa1f63bb1066
md"the first thing we do is look at how a chosen policy stands in relation to alternative available policies. we choose a policy by choosing the proportion of opportunities taken from the total number of opportunities to distribute. we can then represent the opportunity costs (and benefits) of that policy by comparing it to alternative policies."

# ╔═╡ 33be0c01-b712-406e-8827-1c194f2fa863
md"choose a proportion of the total available opportunities to go to B on policy 1 (default=0.5):" 

# ╔═╡ e93e06f4-dd06-4a10-967d-9dab8d30e198
@bind proportiontoB1_ NumberField(0:0.01:1, default=0.5)

# ╔═╡ 3d595998-60e4-404e-94ed-1e89f6de26ae
md"choose a proportion of the total available opportunities to go to B on policy 2 (default=0.5):" 

# ╔═╡ a17bff12-2789-43f5-ab04-25e5e021fda4
@bind proportiontoB2_ NumberField(0:0.01:1, default=0.5)

# ╔═╡ b4b7e927-70e1-4be9-ac42-08ee0bbefd3b
md"## ability settings

here is where we can change the ability settings available for the model.

"

# ╔═╡ 6c731bce-6fef-4d69-a64c-65ecbb08eee9
@bind scaleall NumberField(0:0.1:10, default=1)

# ╔═╡ b706f625-6c87-4681-9cdf-172ca30255fc
@bind lowmax NumberField(0:200, default=55)

# ╔═╡ e6b9420a-5187-4cdf-9f15-a60fd6855a8f
@bind lowmid NumberField(0:200, default=50)

# ╔═╡ 0e097004-9b9c-4517-ad2f-aa6840226158
@bind lowsteep NumberField(0:0.01:2, default=0.1)

# ╔═╡ de1ac2da-61a5-49ff-a0be-e0d05ccfdf5f
@bind midmax NumberField(0:200, default=80)

# ╔═╡ b8fe0439-61fc-4634-93e8-d0aa05a87035
@bind midmid NumberField(0:200, default=50)

# ╔═╡ 52bc5a38-926b-4311-8868-1d32a6f21408
@bind midsteep NumberField(0:0.01:2, default=0.1)

# ╔═╡ d805916b-8c7a-47b4-8ea8-0ad782c3148d
@bind highmax NumberField(0:200, default=100)

# ╔═╡ 6c1a19b1-a66a-4b63-8413-063dc883537d
@bind highmid NumberField(0:200, default=50)

# ╔═╡ 053e5999-291d-4638-a066-942d2a61f0e9
@bind highsteep NumberField(0:0.01:2, default=0.1)

# ╔═╡ 1350ddba-a676-45c7-8552-d13b607610cd
md"## variables"

# ╔═╡ 65594757-7ded-4552-97cb-695eb82cf4c8
# total number of opportunities available to distribute
totalopportunities = totalopportunities_

# ╔═╡ e94755e2-b707-4a16-a751-9e5cc04f1b29
policy1_ = proportiontoB1_ * totalopportunities

# ╔═╡ 6128347f-8029-45ff-a47a-2ef21f090561
policy2_ = proportiontoB2_ * totalopportunities

# ╔═╡ d861ef63-4ac2-46dc-9c6f-7221393b7277
# distribution under policy 1
policy1 = ((totalopportunities - policy1_) * discountA_, policy1_ )

# ╔═╡ f84727eb-011d-4679-912a-beb99afb25bc
# distribution under policy 2
policy2 = ((totalopportunities - policy2_) * discountA_, policy2_)

# ╔═╡ 5f37b1e0-eb9a-4c06-90bb-f67bf0da1f2e
baseline = (baselineA_,baselineB_)

# ╔═╡ ec526f2a-a990-4ea5-b1ba-43a0c56cef60
totalops = totalopportunities + baseline[1] + baseline[2]

# ╔═╡ b1893f3e-6cd9-417b-96d7-5f53c0b3cca8
dt1 = (policy1[1] + baseline[1],policy1[2] + baseline[2])

# ╔═╡ 9ca98b60-7953-4bfa-86e0-b449d154b98d
dt2 = (policy2[1] + baseline[1],policy2[2] + baseline[2])

# ╔═╡ 2eed9e35-394a-4ad9-9c39-290065432cc2
function tr(t)
	round(t; digits=2)
end

# ╔═╡ 4f81db11-2811-4008-b09c-56335160d0c9
md"## pairwise comparison of policies"

# ╔═╡ c70a0cb0-0900-402b-90f4-c4e254e2f8d5
# we'll compare policies with a function 

# ╔═╡ 70b07da6-c0a6-4935-a9f9-7d06e2ff7ea0
md"### ... generalised 

we are now going to compare all policies at each available total level of opportunities. when we pick a policy, it will be a policy that distributes some total number of opportunities in some way. we will compare against policies that distribute different numbers of opportunities in different ways. our z axis in our plot is going to be the total number of opportunities distributed. our x axis will be the different chances for B for different distributions of the same total. and our y axis is going to be, for now, B's weighted interest in the alternative policy (relative to the policy chosen). "

# ╔═╡ 10bb2145-4069-4e88-8852-bd2d892a2627
md"## finding the fair policies

this is going to be computationally expensive, so I won't include it in the plot above, which is for playing with. this time, we compare every policy against every other policy and then filter out the results that meet two different standards of fairness: strict and loose. 

" 



# ╔═╡ 6d63ad59-4f9c-43be-80bf-4a1295a3d8c1
function split_into_groups(numbers, n)
    if isempty(numbers)
        return []
    end

    sorted_numbers = sort(unique(numbers))  # Sort and remove duplicates
    groups = []
    current_group = [sorted_numbers[1]]

    for i in 2:length(sorted_numbers)
        if isapprox(sorted_numbers[i],(sorted_numbers[i-1] + n))
            push!(current_group, sorted_numbers[i])
        else
            push!(groups, current_group)
            current_group = [sorted_numbers[i]]
        end
    end

    push!(groups, current_group)  # Add the last group
    return groups
end

# ╔═╡ 5ff56ae3-c8f4-4148-8ef9-b3032117c1c5
function looselyfairgrouped(xs)
    justthediffs = xs   # map(x -> x[3], xs)
    # filtered = filter(x -> (x[2] > 0.002), justthediffs)

    # Initialize variables to hold the result and the current group
    result = []
    current_group = []

    for value in justthediffs
        if isempty(filter(x -> (x > 0.002)), value)
            push!(current_group, value)  # Add to current group if it meets the condition
        else
            if !isempty(current_group)
                push!(result, current_group)  # Save the current group if it's not empty
                current_group = []  # Reset for the next group
            end
        end
    end

    # Add the last group if it exists
    if !isempty(current_group)
        push!(result, current_group)
    end

    return result
end



# ╔═╡ ef84633d-cc13-4573-9203-940fb2a14f35
md"## model engine"

# ╔═╡ 8b840cfb-c22e-498f-a052-8404ee68e153
function weighteddiff(x, y)
    if x == y
        return 0
    elseif x < y
        return (x - y) * ((1 - x) ^ 2)
    else  # This covers the case where y < x
        return (x - y) * ((1 - y) ^ 2)
    end
end

# ╔═╡ 6336fe43-a4e8-4d75-be6c-fbd9b6a6ba37
# ╠═╡ disabled = true
#=╠═╡
# using sampling
function probability_x_greater_than_y(d1, d2, num_samples)
    count = 0
    for _ in 1:num_samples
        x = rand(d1)  # Draw a sample from distribution d1
        y = rand(d2)  # Draw a sample from distribution d2
        if x > y
            count += 1
        end
    end
    return count / num_samples  # Calculate the probability
end
  ╠═╡ =#

# ╔═╡ 7374becb-cf8b-4416-8e4b-08fe2f62aceb
# using numerical integration
function probability_x_greater_than_y2(d1, d2)
    # Define the PDF of Y
    pdf_y(y) = pdf(d2, y)

    # Define the CDF of X
    cdf_x(y) = cdf(d1, y)

    # Calculate the integral
    integral = quadgk(y -> (1 - cdf_x(y)) * pdf_y(y), -Inf, Inf)[1]
    return integral
end

# ╔═╡ dfa36663-3f67-4809-9071-a68a0c985be1
# Logistic function
function logistic(n, L, k, x0)
    return L / (1 + exp(-k * (n - x0)))
end

# ╔═╡ cdd1fc12-2027-45df-8867-fe7fe3265999
function lowability(n)
	L = lowmax * scaleall # Maximum outcome
    k = lowsteep  # Steepness of the curve
    x0 = lowmid * scaleall  # Midpoint of the logistic function
	logistic(n, L, k, x0)
end

# ╔═╡ 02d51a56-26ea-423b-a60c-c50c75cec26c
function midability(n)
	L = midmax * scaleall  # Maximum outcome
    k = midsteep  # Steepness of the curve
    x0 = midmid * scaleall  # Midpoint of the logistic function
	logistic(n, L, k, x0)
end

# ╔═╡ b96458b3-6f68-4071-bb82-6b3e1dcff8f7
function highability(n)
	L = highmax * scaleall  # Maximum outcome
    k = highsteep  # Steepness of the curve
    x0 = highmid * scaleall  # Midpoint of the logistic function
	logistic(n, L, k, x0)
end

# ╔═╡ a7923940-392f-4ee5-a9a3-126c5b8ba9c3
@bind A Select([highability,midability,lowability])

# ╔═╡ 6a1a187e-2f6c-4acf-98e6-744cbb1f5873
@bind B Select([highability,midability,lowability], default=highability)

# ╔═╡ 965cfdc9-5e9f-4d4f-9ec3-0115dddc2e6d
# Function to model educational outcomes for high ability
function educational_outcome_high(n)
    # Get the logistic value
    logistic_value = A(n)

    # Create a normal distribution centered on the logistic value
    sigma = 20  # Standard deviation
    distribution = Truncated(Normal(logistic_value, sigma),0,Inf)

    return distribution
end

# ╔═╡ 6d00b682-dbf8-41ef-95f6-04c210f128a1
# Function to model educational outcomes for low ability
function educational_outcome_low(n)
    # Get the logistic value
    logistic_value = B(n)

    # Create a normal distribution centered on the logistic value
    sigma = 20  # Standard deviation
    distribution = Truncated(Normal(logistic_value, sigma),0,Inf)

    return distribution
end

# ╔═╡ 7c36cbdc-8181-4388-a679-5101da90bc71
oprange = 0:100

# ╔═╡ 778a0587-959b-4ced-baff-c95defa65a27
function ability()
	plot(oprange, [A(i) for i in oprange], label=false)
	plot!(oprange, [B(i) for i in oprange], label=false)
	# Add titles and labels
	title!("ability")
	xlabel!("opportunities")
	ylabel!("outcomes")
	vline!([policy1[1]+baseline[1]], label=false, color=:blue)
	vline!([policy1[2]+baseline[2]], label=false, color=:green)
end

# ╔═╡ 3803eba4-a40d-4849-888f-2f3cd0ecc7d1
begin
	plot(oprange, [highability(i) for i in oprange], label="high average")
	plot!(oprange, [midability(i) for i in oprange], label="mid average" )
	plot!(oprange, [lowability(i) for i in oprange], label="low average" )
	# Add titles and labels
	title!("ability")
	xlabel!("opportunities")
	ylabel!("outcomes")
	vline!([policy1[1]+baseline[1]], label="A's opportunities", color=:blue)
	vline!([policy1[2]+baseline[2]], label="B's opportunities", color=:green)
end

# ╔═╡ e552a0a9-0f56-4456-8395-f12ef677835c
# unit cost of an opportunity 
unitcost = unitcost_

# ╔═╡ 5ccfe20e-cf68-4413-a833-3154437a0a6f
function edubenefits(n)
	L = 200 # Maximum outcome
    k = 0.1  # Steepness of the curve
    x0 = 100  # Midpoint of the logistic function
	logistic(n, L, k, x0)
end

# ╔═╡ 895c3a3d-9769-4af4-aad5-c0fb14b6dd27
function benefits()
	plot(range(1,200), [edubenefits(i) for i in range(1,200)], label=false)
    vline!([currentavout], label=false, color=:blue)
	# Add titles and labels
	title!("benefits of education")
	xlabel!("total outcomes")
	ylabel!("benefits")

end

# ╔═╡ 1aea36b9-3736-442f-abf1-eeb5654b201e
# social baseline
sbl = 1000

# ╔═╡ 0cde042c-6e7a-4c7a-9f87-8146f0995eff
# proportion for top ranked (set above)
pptop = toplifeprospects_

# ╔═╡ 4e1cbb11-306a-4eda-8d06-d11f73ae162e
# proportion for bottom ranked (set above)
ppbot = bottomlifeprospects_

# ╔═╡ 500ea6f5-9e50-4a93-9832-dd48e3727eb0
# function to get the average outcomes on a distribution
function averagetotaloutcomes_(d)
	return(A(d[1]) + B(d[2]))
end


# ╔═╡ 24e949ba-9794-4bf2-8d36-19bbbf7c7087
# function to get the total costs of the additional opportunities 
function costofprovision(d) 
	return((d[1] * unitcost) + (d[2] * unitcost))
end

# ╔═╡ 0c5bd66f-3c6a-4c31-a889-ae07c58d0fdd
function scalebenefits(s,e) 
    scaledsbl = (1 - eduscale_) * s 
	scaledben = eduscale_ * (e / 200) * 1000
	return (scaledsbl + scaledben)
end
	

# ╔═╡ e90cd186-946e-4600-99bc-3c8628d5dc2c
scalebenefits(100,edubenefits(150))

# ╔═╡ dd77135b-c68d-486d-9333-249475176d11
# function for calculating life prospects given chances, average outcomes, and cost of provision 
function getlifeprospects(ch,avout,cp)
    total = ((scalebenefits(sbl,(edubenefits(avout)))) - cp) * 0.001 
	return ((ch * pptop * total) + ((1 - ch) * ppbot * total))
end

# ╔═╡ 5cef23cd-77bf-4c7f-9733-d1b415337b3b
# function for getting unweighted diffs 
function getuwdiffs(alp1,alp2,blp1,blp2) 
   return (alp2 - alp1, blp2 - blp1)
end

# ╔═╡ d4db49d9-ef20-4ab0-8d7a-ed05f0c06ac1
# function for getting weighted diffs 
function getwdiffs(alp1,alp2,blp1,blp2) 
   return (weighteddiff(alp2,alp1),weighteddiff(blp2,blp1))
end

# ╔═╡ 35587cb6-f68a-4423-b524-43bc2d1da908
# a record type for storing the results of running the model 
struct Report 
	policy_1::Tuple{Float64, Float64} # policy for additional opportunities
	policy_2::Tuple{Float64, Float64} # policy for additional opportunities
	ops_1::Tuple{Float64, Float64} # policy for total opportunities
	ops_2::Tuple{Float64, Float64} # policy for total opportunities
	chances_a_1::Float64 
	chances_a_2::Float64 
	chances_b_1::Float64 
	chances_b_2::Float64 
	prospects_a_1::Float64 
	prospects_a_2::Float64 
	prospects_b_1::Float64 
	prospects_b_2::Float64 
	av_out_1::Float64 
	av_out_2::Float64 
	av_out_1A::Float64 
	av_out_1B::Float64 
	av_out_2A::Float64 
	av_out_2B::Float64 
	cost_1::Float64 # cost of providing additional opportunities on 1
	cost_2::Float64 # cost of providing additional opportunities on 2
	uw_diffs::Tuple{Float64, Float64} # unweighted difference between 1 and 2 for A and B
	w_diffs::Tuple{Float64, Float64} # weighted difference between 1 and 2 for A and B
	w_sum::Float64 # sum of the weighted difference between 1 and 2 for A and B
	uw_sum::Float64 # sum of the unweighted difference between 1 and 2 for A and B
	a_claim::Float64
	b_claim::Float64
	v_add1::Float64
	v_add2::Float64 
	c_ben1::Float64 
	c_ben2::Float64
	tin1::Float64
	tain1::Float64 
	tin2::Float64 
	tain2::Float64 
	bystander1::Float64 
	bystander2::Float64
end
	

# ╔═╡ 14a6c1d8-48cf-4bfc-b7f9-f56fd0406ead
# this function calculates the unweighted difference between a pair of distributions
function runmodel(dt1,dt2) # d1 is the baseline
	d1 = policy1
	d2 = policy2
    d1chA = probability_x_greater_than_y2(educational_outcome_high(dt1[1]), educational_outcome_low(dt1[2])) # A's chances on d1
	d1chB = 1 - d1chA # B's chances on d1 
	d2chA = probability_x_greater_than_y2(educational_outcome_high(dt2[1]), educational_outcome_low(dt2[2])) # A's chances on d2
	d2chB = 1 - d2chA # B's chances on d2
	d1avoutA = A(dt1[1])
	d1avoutB = B(dt1[2])
	d2avoutA = A(dt2[1])
	d2avoutB = B(dt2[2])
	d1avout = d1avoutA + d1avoutB # average outcomes on d1
	d2avout = d2avoutA + d2avoutB # average outcomes on d2 
	d1cost = costofprovision(d1) 
	d2cost = costofprovision(d2) 
	d1lpA = getlifeprospects(d1chA,d1avout,d1cost)
	d1lpB = getlifeprospects(d1chB,d1avout,d1cost) 
	d2lpA = getlifeprospects(d2chA,d2avout,d2cost) 
	d2lpB = getlifeprospects(d2chB,d2avout,d2cost) 
	uwdiffs = getuwdiffs(d1lpA,d2lpA,d1lpB,d2lpB) 
	wdiffs = getwdiffs(d1lpA,d2lpA,d1lpB,d2lpB) 
	wsum =  wdiffs[2] + wdiffs[1]
	uwsum = uwdiffs[2] + uwdiffs[1]
	bclaim = if ((wdiffs[2] > 0) && ((wdiffs[2] + wdiffs[1]) > 0))
		(wdiffs[2] + wdiffs[1])
	    else 0
	end 
	aclaim = if ((wdiffs[1] > 0) && ((wdiffs[1] + wdiffs[2]) > 0 ))
		(wdiffs[1] + wdiffs[2])
	    else 0
	end 
	valueadd1 = ((scalebenefits(sbl,(edubenefits(d1avout))))) 
	valueadd2 = ((scalebenefits(sbl,(edubenefits(d2avout)))))
	costbenefit1 = ((scalebenefits(sbl,(edubenefits(d1avout)))) - d1cost) 
	costbenefit2 = ((scalebenefits(sbl,(edubenefits(d2avout)))) - d2cost) 
	bystander1 = bystanderlifeprospects_ * costbenefit1 * 0.001
	bystander2 = bystanderlifeprospects_ * costbenefit2 * 0.001
	totalinputs1 = dt1[1] + dt1[2]
	totaladditionalinputs1 = policy1[1] + policy1[2]
	totalinputs2 = dt2[1] + dt2[2]
	totaladditionalinputs2 = policy2[1] + policy2[2]
	return (Report(
		      d1 
		    , d2 
		    , dt1
		    , dt2
		    , d1chA
			, d2chA
			, d1chB
			, d2chB 
			, d1lpA 
			, d2lpA 
			, d1lpB
			, d2lpB 
			, d1avout
			, d2avout 
		    , d1avoutA
		    , d1avoutB
		    , d2avoutA
		    , d2avoutB
			, d1cost
			, d2cost 
		    , uwdiffs
		    , wdiffs
		    , wsum
		    , uwsum
		    , bclaim 
		    , aclaim
		    , valueadd1 
		    , valueadd2
		    , costbenefit1 
		    , costbenefit2
		    , totalinputs1
	        , totaladditionalinputs1 
	        , totalinputs2 
	        , totaladditionalinputs2 
		    , bystander1 
		    , bystander2
		)
	)
end

# ╔═╡ 99a7a989-c37b-46d8-9d72-87d67b9d5d9f
report1 = runmodel(dt1,dt2)

# ╔═╡ 722f971d-d8a7-4ea8-81e9-09bba8db8a90
md"## report 

the following is a report comparing policy 1 and policy 2

* policy 1, $(report1.policy_1)
   * A: 
      * additional opportunities: $(report1.policy_1[1])
      * total opportunities: $(report1.ops_1[1])
      * chances: $(report1.chances_a_1) 
      * prospects: $(report1.prospects_a_1)
   * B: 
      * additional opportunities: $(report1.policy_1[2])
      * total opportunities: $(report1.ops_1[2])
      * chances: $(report1.chances_b_1) 
      * prospects: $(report1.prospects_b_1) 
   * C: 
      * prospects: $(report1.bystander1)
* policy 2 $(report1.policy_2)
   * A: 
       * additional opportunities: $(report1.policy_2[1])
       * total opportunities: $(report1.ops_2[1])
       * chances: $(report1.chances_a_2) 
       * prospects: $(report1.prospects_a_2)
   * B: 
       * additional opportunities: $(report1.policy_2[2])
       * total opportunities: $(report1.ops_2[2])
       * chances: $(report1.chances_b_2) 
       * prospects: $(report1.prospects_b_2) 
   * C: 
       * prospects: $(report1.bystander2)

some important comparisons: 

* unweighted interests 
    * A's unweighted interest in policy 2 over policy 1: $(report1.uw_diffs[1])
    * B's unweighted interest in policy 2 over policy 1: $(report1.uw_diffs[2])
    * the sum of A and B's unweighted interests: $(report1.uw_sum)
* weighted interests 
    * A's weighted interest in policy 2 over policy 1: $(report1.w_diffs[1])
    * B's weighted interest in policy 2 over policy 1: $(report1.w_diffs[2])
    * the sum of A and B's weighted interests: $(report1.w_sum) 
    * A's claim: $(report1.a_claim)
    * B's claim: $(report1.b_claim)

here is an extended report:

* policy 1 
   * total opportunities: $(report1.tin1)
   * total additional opportunities: $(report1.tain1)
   * total average outcomes: $(report1.av_out_1)
   * average outcomes for A: $(report1.av_out_1A)
   * average outcomes for B: $(report1.av_out_1B)
   * educational value-add: $(report1.v_add1)
   * total cost: $(report1.cost_1)
   * cost benefits: $(report1.c_ben1)

* policy 2 
   * total opportunities: $(report1.tin2)
   * total additional opportunities: $(report1.tain2)
   * total average outcomes: $(report1.av_out_2)
   * average outcomes for A: $(report1.av_out_2A)
   * average outcomes for B: $(report1.av_out_2B)
   * educational value-add: $(report1.v_add2) 
   * total cost: $(report1.cost_2)
   * cost benefits: $(report1.c_ben2)

" 


# ╔═╡ 2751cd9d-358f-4bf4-a8c2-bcdddeceabb7
function getreporthelper(x) 
   proportiontoB = x * totalopportunities 
   proportiontoA = ((1 - x) * discountA_) * totalopportunities
   totaltoA = proportiontoA + baseline[1] 
   totaltoB = proportiontoB + baseline[2] 
   report = runmodel(dt1,(totaltoA,totaltoB))
   return (report) 
end

# ╔═╡ acf6e66a-79c6-4e29-9890-edc2c8b5adc5
function getwsum2D(x) 
   report = getreporthelper(x)
   return report.w_sum
end

# ╔═╡ 5808ab27-f325-402a-9859-7a985c557ace
# this one just works out what the 
sum0 = [getreporthelper(i) for i in range(0, 1, length=101) if isapprox(getwsum2D(i),0, atol=0.00001)] 

# ╔═╡ 1cb27925-26f4-44e6-ad00-05ddf647088e
function getuwsum2D(x) 
   report = getreporthelper(x)
   return report.uw_sum
end

# ╔═╡ 88306a77-c85c-4dde-861e-f7ace7c0115c
function getuwdiffsA(x) 
   report = getreporthelper(x)
   return report.uw_diffs[1]
end

# ╔═╡ 92f08b2f-632a-4c2d-bbb0-2058d4dcf923
function getuwdiffsB(x) 
   report = getreporthelper(x)
   return report.uw_diffs[2]
end

# ╔═╡ a7db1f6f-4350-4fef-bd5b-fae0de2421bf
function getwdiffsA(x) 
   report = getreporthelper(x)
   return report.w_diffs[1]
end

# ╔═╡ 8c88a658-512c-4a72-a252-5a245b3e791d
function getwdiffsB(x) 
   report = getreporthelper(x)
   return report.w_diffs[2]
end

# ╔═╡ 7d10e574-c928-4104-9d18-b897021d7a5f
# we need a function from x and y where x is the % of the total B gets and y is total number of opportunities to be distributed. it returns the sum diff 

function getwsum3Dvar(x,y) 
   proportiontoB = x * y 
   proportiontoA = ((1 - x) * discountA_) * y 
   totaltoA = proportiontoA + baseline[1] 
   totaltoB = proportiontoB + baseline[2] 
   report = runmodel(dt1,(totaltoA,totaltoB))
   return report.w_sum
end

# ╔═╡ a328a25e-c9aa-4dd0-8b24-b7ff2c642eb2
begin 

# Step 1: Extract x, y, z values
x_vals = range(0, 1, length=100)
y_vals = range(0, totalopportunities, length=100)

# scatter(x_vals, y_vals, z_vals, xlabel="X-axis", ylabel="Y-axis", zlabel="Z-axis", camera=(45, 25))
plot(x_vals, y_vals, getwsum3Dvar, label="Smoothed Surface", st=:surface, c=:viridis, opacity=0.8, zlim=(-0.04, 0.04))
plot!(x_vals, y_vals, getwsum3Dvar, label="Smoothed Surface", st=:wireframe, zlim=(-0.04, 0.04))
end

# ╔═╡ d342d102-da15-4e0f-8054-bd54d2def8e8
function getreporthelper3D(x,y) 
   proportiontoB = x * totalopportunities 
   proportiontoA = ((1 - x) * discountA_) * totalopportunities
   totaltoA = proportiontoA + baseline[1] 
   totaltoB = proportiontoB + baseline[2]  
   proportiontoBy = y * totalopportunities 
   proportiontoAy = ((1 - y) * discountA_) * totalopportunities
   totaltoAy = proportiontoAy + baseline[1] 
   totaltoBy = proportiontoBy + baseline[2] 
   report = runmodel((totaltoAy,totaltoBy),(totaltoA,totaltoB))
   return (report) 
end

# ╔═╡ 2c4779c5-238d-4328-aac6-cc5fcbe8f6b3
function getwsum3D(x,y) 
   report = getreporthelper3D(x,y)
   return report.w_sum
end

# ╔═╡ fcd7edcf-4df1-47cf-98f2-190a921c3606
begin 
plot(range(0, 1, length=20), range(0, 1, length=20), getwsum3D, label="Smoothed Surface", st=:wireframe)
plot!(range(0, 1, length=20), range(0, 1, length=20), getwsum3D, label="Smoothed Surface", st=:surface, c=:viridis, opacity=0.8, legend=false)
end

# ╔═╡ 97d1e787-cf26-451b-a027-4eefe916a795
## this function gets the strictly fair policies

getstrictlyfair = [x for x in range(0, 1, length=101) if all(z -> z < 0.0000001, map(z -> getwsum3D(z,x),range(0, 1, length=101)))]

# ╔═╡ f45d9483-ac5e-4731-a2c1-acb34a8c3d7b
## this function gets the loosely fair policies

getlooselyfair = [x for x in range(0, 1, step=0.01) if all(z -> z < 0.002, map(z -> getwsum3D(z,x),range(0, 1, step=0.01)))]

# ╔═╡ a1d54e9b-9af6-4a1d-8b88-7beb098e5df9
glfgroups = split_into_groups(getlooselyfair,0.01)

# ╔═╡ e82b4050-8a19-4dcf-bd9f-32b19971458f
begin
	plot(range(0, 1, length=100), getuwdiffsA, title="unweighted interests", label="A's interests", palette = :Dark2_5)
	plot!(range(0, 1, length=100), getuwdiffsB, label="B's interests")
	plot!(range(0, 1, length=100), getwsum2D, label="balance")
	vline!([proportiontoB1_], label="current policy", color=:grey)
	vspan!([[minimum(i),maximum(i)] for i in glfgroups], label=false, color="light blue", opacity=0.2)
end

# ╔═╡ 716e0ea5-1097-4e93-bbe6-f7a0a72491a2
begin
	plot(range(0, 1, length=100), getwdiffsA, title="weighted interests", label="A's interests", palette = :Dark2_5)
	plot!(range(0, 1, length=100), getwdiffsB, label="B's interests")
	plot!(range(0, 1, length=100), getwsum2D, label="balance")
	vline!([proportiontoB1_], label="current policy", color=:grey)
	vspan!([[minimum(i),maximum(i)] for i in glfgroups], label=false, color="light blue", opacity=0.2)
end

# ╔═╡ fa988726-e491-46e9-9478-92621ff30e77
function getwdiffsB3D(x,y) 
   report = getreporthelper3D(x,y)
   return report.w_diffs[2]
end

# ╔═╡ fa934ffa-a874-49df-a785-34354d26f2b0
begin 
plot(range(0, 1, length=20), range(0, 1, length=20), getwdiffsB3D, label="Smoothed Surface", st=:wireframe)
plot!(range(0, 1, length=20), range(0, 1, length=20), getwdiffsB3D, label="Smoothed Surface", st=:surface, c=:viridis, opacity=0.8, legend=false)
end

# ╔═╡ fe3dcaee-a713-4aab-bfee-a41573c1291f
# this one just works out what the 
sum03D = [getreporthelper3D(x,y) for x in range(0, 1, length=101), y in range(0, 1, length=101) if isapprox(getwsum3D(x,y),0, atol=0.00001)] 

# ╔═╡ cf430baf-e199-4060-9128-ccc359783e58
# this is the mother of all functions 
# it compares policies considered as proportion/total pairs 
# it compares one such against another such 

function getreporthelper3DALL((x1,x2),(y1,y2)) 
   proportiontoB = x1 * x2
   proportiontoA = ((1 - x1) * discountA_) * x2
   totaltoA = proportiontoA + baseline[1] 
   totaltoB = proportiontoB + baseline[2]  
   proportiontoBy = y1 * y2
   proportiontoAy = ((1 - y1) * discountA_) * y2
   totaltoAy = proportiontoAy + baseline[1] 
   totaltoBy = proportiontoBy + baseline[2] 
   report = runmodel((totaltoAy,totaltoBy),(totaltoA,totaltoB))
   return (report) 
end

# ╔═╡ 1d4d1957-c620-4150-8250-f886e5beb2be
function getwsum3DALL((x1,x2),(y1,y2))
   report = getreporthelper3DALL((x1,x2),(y1,y2))
   return report.w_sum
end

# ╔═╡ 2a9cd28b-a55e-4db3-b472-ea536da0213b
function getstrictlyfairALL()
	thexs1 = range(0, 1, step=0.05)
    thexs2 = range(0,totalopportunities)
    theys = [(y1,y2) for y1 in range(0, 1, step=0.05), y2 in range(0,totalopportunities)] 
    return([(x1,x2) for x1 in thexs1, x2 in thexs2 if all(y -> y < 0.0000001,(map(z -> getwsum3DALL(z,(x1,x2)),theys)))])
end

# ╔═╡ 7a1229ba-67b8-49af-9392-e7ec384068ba
getstrictlyfairALL()

# ╔═╡ 60c5173d-efa0-40c1-8afc-bb189a6ae7de
function getlooselyfairALL()
	thexs1 = range(0, 1, step=0.05)
    thexs2 = range(0,totalopportunities)
    theys = [(y1,y2) for y1 in range(0, 1, step=0.05), y2 in range(0,totalopportunities)] 
    return([(x1,x2) for x1 in thexs1, x2 in thexs2 if all(y -> y < 0.002,(map(z -> getwsum3DALL(z,(x1,x2)),theys)))])
end

# ╔═╡ 60e940d8-df1e-4d4b-b894-9c6897479bac
getlooselyfairALL()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
PGFPlotsX = "8314cec4-20b6-5062-9cdb-752b83310925"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
QuadGK = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"

[compat]
Distributions = "~0.25.113"
PGFPlotsX = "~1.6.2"
Plots = "~1.40.8"
PlutoUI = "~0.7.60"
QuadGK = "~2.11.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "24489e1ff85e1f16b014e9e71addcbc8de285c14"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8873e196c2eb87962a2048b3b8e08946535864a1"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "c785dfb1b3bfddd1da557e861b919819b82bbe5b"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.27.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "64e15186f0aa277e174aa81798f7eb8598e0157e"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DefaultApplication]]
deps = ["InteractiveUtils"]
git-tree-sha1 = "c0dfa5a35710a193d83f03124356eef3386688fc"
uuid = "3f0dd361-4fe0-5fc6-8523-80b14ec94d85"
version = "1.1.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3101c32aab536e7a27b1763c0797dba151b899ad"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.113"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc5231d52eb1771251fbd37171dbc408bcc8a1b6"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.4+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "5c1d8ae0efc6c2e7b1fc502cbe25def8f661b7bc"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.2+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "532f9126ad901533af1d4f5c198867227a7bb077"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+1"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "ee28ddcd5517d54e417182fec3886e7412d3926f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f31929b9e67066bee48eec8b03c0df47d31a74b3"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "674ff0db93fffcd11a3573986e550d66cd4fd71f"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "1336e07ba2eb75614c99496501a8f4b233e9fafe"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.10"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "401e4f3f30f43af2c8478fc008da50096ea5240f"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.3.1+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "b1c2585431c382e3fe5805874bda6aea90a95de9"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.25"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "39d64b09147620f5ffbf6b2d3255be3c901bec63"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.8"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "25ee0be4d43d0269027024d75a24c24d6c6e590c"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.4+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "36bdbc52f13a7d1dcb0f3cd694e01677a515655b"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "854a9c268c43b77b0a27f22d7fab8d33cdb3a731"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c6ce1e19f3aec9b59186bdf06cdf3c4fc5f5f3e6"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.50.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "61dfdba58e585066d8bce214c5a51eaa0539f269"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0c4f9c4f1a50d8f35048fa0532dabbadf702f81e"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.1+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "b404131d06f7886402758c9ce2214b636eb4d54a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5ee6203157c120d79034c748a2acba45b82b8807"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+1"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.PGFPlotsX]]
deps = ["ArgCheck", "Dates", "DefaultApplication", "DocStringExtensions", "MacroTools", "OrderedCollections", "Parameters", "Requires", "Tables"]
git-tree-sha1 = "e5df51ffc01f8771d94c8db2d164be1f6927849c"
uuid = "8314cec4-20b6-5062-9cdb-752b83310925"
version = "1.6.2"

    [deps.PGFPlotsX.extensions]
    ColorsExt = "Colors"
    ContourExt = "Contour"
    MeasurementsExt = "Measurements"
    StatsBaseExt = "StatsBase"

    [deps.PGFPlotsX.weakdeps]
    Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
    Contour = "d38c429a-6771-53c6-b99e-75d170b6e991"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e127b609fb9ecba6f201ba7ab753d5a605d53801"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.54.1+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "dae01f8c2e069a683d3a6e17bbae5070ab94786f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.9"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "cda3b045cf9ef07a08ad46731f5a3165e56cf3da"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.1"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2f5d4697f21388cbe1ff299430dd169ef97d7e14"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.4.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "d95fe458f26209c66a187b1114df96fd70839efd"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "a2fccc6559132927d4c5dc183e3e01048c6dcbd6"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "a54ee957f4c86b526460a720dbc882fa5edcbefc"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.41+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "15e637a697345f6743674f1322beefbc5dcd5cfc"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.3+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "bcd466676fef0878338c61e655629fa7bbc69d8e"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "555d1076590a6cc2fdee2ef1469451f872d8b41b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "936081b536ae4aa65415d869287d43ef3cb576b2"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.53.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "b70c870239dc3d7bc094eb2d6be9b73d27bef280"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╠═a3c707eb-2dbd-4ede-80e9-0e4c90e01154
# ╠═41571ca1-d1a0-4761-8672-c20d30e37786
# ╟─fad8a8e2-141a-4f54-a822-150ecdcbde5a
# ╟─7a83590e-488e-41b7-a4ed-303956cc0359
# ╟─a3a348bf-6e2c-4775-b1c6-26fa602b319a
# ╟─a7923940-392f-4ee5-a9a3-126c5b8ba9c3
# ╟─a8c8c80a-2e0f-4f34-92b5-3f872a4249c6
# ╟─6a1a187e-2f6c-4acf-98e6-744cbb1f5873
# ╟─e7b6f564-a08e-43b1-b602-b10a935ad94a
# ╟─22598207-1e0f-444b-9064-5cc818305d83
# ╟─5cd30ea0-0bb9-4745-abb5-1d5c99f09507
# ╟─6a48a6c4-a3cc-4d9f-9a5d-de72d8a1a306
# ╟─8bcb854d-cb45-4ed4-bc0f-8e5d0c693d27
# ╟─69b27cb2-720f-44bd-8cdf-b33bd1e0399f
# ╟─9c87ab70-aa58-4130-989d-363779557d2c
# ╟─eb6dc23e-6307-4585-9010-5cc9efb582e9
# ╟─3fd76120-b631-4022-a6dd-6c9f4ec06aa3
# ╟─2a873e8b-71d6-4e53-840b-f37c645f06d1
# ╟─3168827b-1e31-408d-9ec3-53e725872e5e
# ╟─943a2a24-5ee7-42b9-bed3-868148d1781a
# ╟─24794095-f20d-4fe8-9aa9-e862d8d73786
# ╟─37e0d7dc-c92f-4163-a239-ef794cbefa3e
# ╟─b7bd8235-5bf9-4bbc-ac30-07ef17bd9d8b
# ╟─7588880c-2c3a-4b19-950d-e21faf015105
# ╟─8f7951a7-1fde-4783-8cf4-26412041fc77
# ╟─53444608-183c-4bc4-a619-cf0704515a77
# ╟─97bad24c-f88a-4709-9130-7187536fb99b
# ╟─b00c0a99-fa37-4dd2-8c3b-aa1f63bb1066
# ╠═33be0c01-b712-406e-8827-1c194f2fa863
# ╠═e93e06f4-dd06-4a10-967d-9dab8d30e198
# ╠═e94755e2-b707-4a16-a751-9e5cc04f1b29
# ╠═3d595998-60e4-404e-94ed-1e89f6de26ae
# ╠═a17bff12-2789-43f5-ab04-25e5e021fda4
# ╠═6128347f-8029-45ff-a47a-2ef21f090561
# ╟─722f971d-d8a7-4ea8-81e9-09bba8db8a90
# ╠═99a7a989-c37b-46d8-9d72-87d67b9d5d9f
# ╟─b4b7e927-70e1-4be9-ac42-08ee0bbefd3b
# ╟─778a0587-959b-4ced-baff-c95defa65a27
# ╟─3803eba4-a40d-4849-888f-2f3cd0ecc7d1
# ╠═6c731bce-6fef-4d69-a64c-65ecbb08eee9
# ╠═b706f625-6c87-4681-9cdf-172ca30255fc
# ╠═e6b9420a-5187-4cdf-9f15-a60fd6855a8f
# ╠═0e097004-9b9c-4517-ad2f-aa6840226158
# ╟─cdd1fc12-2027-45df-8867-fe7fe3265999
# ╠═de1ac2da-61a5-49ff-a0be-e0d05ccfdf5f
# ╠═b8fe0439-61fc-4634-93e8-d0aa05a87035
# ╠═52bc5a38-926b-4311-8868-1d32a6f21408
# ╟─02d51a56-26ea-423b-a60c-c50c75cec26c
# ╠═d805916b-8c7a-47b4-8ea8-0ad782c3148d
# ╠═6c1a19b1-a66a-4b63-8413-063dc883537d
# ╠═053e5999-291d-4638-a066-942d2a61f0e9
# ╟─b96458b3-6f68-4071-bb82-6b3e1dcff8f7
# ╟─ec526f2a-a990-4ea5-b1ba-43a0c56cef60
# ╟─1350ddba-a676-45c7-8552-d13b607610cd
# ╠═d861ef63-4ac2-46dc-9c6f-7221393b7277
# ╠═f84727eb-011d-4679-912a-beb99afb25bc
# ╠═65594757-7ded-4552-97cb-695eb82cf4c8
# ╠═5f37b1e0-eb9a-4c06-90bb-f67bf0da1f2e
# ╠═b1893f3e-6cd9-417b-96d7-5f53c0b3cca8
# ╠═9ca98b60-7953-4bfa-86e0-b449d154b98d
# ╠═2eed9e35-394a-4ad9-9c39-290065432cc2
# ╟─4f81db11-2811-4008-b09c-56335160d0c9
# ╠═c70a0cb0-0900-402b-90f4-c4e254e2f8d5
# ╠═2751cd9d-358f-4bf4-a8c2-bcdddeceabb7
# ╠═acf6e66a-79c6-4e29-9890-edc2c8b5adc5
# ╠═5808ab27-f325-402a-9859-7a985c557ace
# ╠═1cb27925-26f4-44e6-ad00-05ddf647088e
# ╠═88306a77-c85c-4dde-861e-f7ace7c0115c
# ╠═92f08b2f-632a-4c2d-bbb0-2058d4dcf923
# ╠═e82b4050-8a19-4dcf-bd9f-32b19971458f
# ╠═a7db1f6f-4350-4fef-bd5b-fae0de2421bf
# ╠═8c88a658-512c-4a72-a252-5a245b3e791d
# ╠═716e0ea5-1097-4e93-bbe6-f7a0a72491a2
# ╟─70b07da6-c0a6-4935-a9f9-7d06e2ff7ea0
# ╠═a328a25e-c9aa-4dd0-8b24-b7ff2c642eb2
# ╠═7d10e574-c928-4104-9d18-b897021d7a5f
# ╠═fcd7edcf-4df1-47cf-98f2-190a921c3606
# ╠═d342d102-da15-4e0f-8054-bd54d2def8e8
# ╠═2c4779c5-238d-4328-aac6-cc5fcbe8f6b3
# ╠═fa934ffa-a874-49df-a785-34354d26f2b0
# ╠═fa988726-e491-46e9-9478-92621ff30e77
# ╠═fe3dcaee-a713-4aab-bfee-a41573c1291f
# ╟─10bb2145-4069-4e88-8852-bd2d892a2627
# ╠═97d1e787-cf26-451b-a027-4eefe916a795
# ╠═f45d9483-ac5e-4731-a2c1-acb34a8c3d7b
# ╠═a1d54e9b-9af6-4a1d-8b88-7beb098e5df9
# ╠═6d63ad59-4f9c-43be-80bf-4a1295a3d8c1
# ╠═5ff56ae3-c8f4-4148-8ef9-b3032117c1c5
# ╠═cf430baf-e199-4060-9128-ccc359783e58
# ╠═1d4d1957-c620-4150-8250-f886e5beb2be
# ╠═2a9cd28b-a55e-4db3-b472-ea536da0213b
# ╠═7a1229ba-67b8-49af-9392-e7ec384068ba
# ╠═60c5173d-efa0-40c1-8afc-bb189a6ae7de
# ╠═60e940d8-df1e-4d4b-b894-9c6897479bac
# ╟─ef84633d-cc13-4573-9203-940fb2a14f35
# ╠═8b840cfb-c22e-498f-a052-8404ee68e153
# ╟─6336fe43-a4e8-4d75-be6c-fbd9b6a6ba37
# ╠═7374becb-cf8b-4416-8e4b-08fe2f62aceb
# ╠═dfa36663-3f67-4809-9071-a68a0c985be1
# ╠═965cfdc9-5e9f-4d4f-9ec3-0115dddc2e6d
# ╠═6d00b682-dbf8-41ef-95f6-04c210f128a1
# ╟─7c36cbdc-8181-4388-a679-5101da90bc71
# ╠═e552a0a9-0f56-4456-8395-f12ef677835c
# ╠═5ccfe20e-cf68-4413-a833-3154437a0a6f
# ╠═895c3a3d-9769-4af4-aad5-c0fb14b6dd27
# ╠═1aea36b9-3736-442f-abf1-eeb5654b201e
# ╠═0cde042c-6e7a-4c7a-9f87-8146f0995eff
# ╠═4e1cbb11-306a-4eda-8d06-d11f73ae162e
# ╠═500ea6f5-9e50-4a93-9832-dd48e3727eb0
# ╠═24e949ba-9794-4bf2-8d36-19bbbf7c7087
# ╠═0c5bd66f-3c6a-4c31-a889-ae07c58d0fdd
# ╠═e90cd186-946e-4600-99bc-3c8628d5dc2c
# ╠═dd77135b-c68d-486d-9333-249475176d11
# ╠═5cef23cd-77bf-4c7f-9733-d1b415337b3b
# ╠═d4db49d9-ef20-4ab0-8d7a-ed05f0c06ac1
# ╠═14a6c1d8-48cf-4bfc-b7f9-f56fd0406ead
# ╠═35587cb6-f68a-4423-b524-43bc2d1da908
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
