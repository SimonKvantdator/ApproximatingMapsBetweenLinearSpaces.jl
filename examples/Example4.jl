using ApproximatingMapsBetweenLinearSpaces
using Plots; pyplot()

m=4
Ns=2:2:26

function g(x)
    return exp(-sum([sign(xi) * xi^2 for xi in x]))
end

V2_ = 4 * exp(m) # Bound for |(d/dxi)^1 g(x)|
Lambda(N) = (2 / pi) * log(N + 1) + 1 # Chebyshev interpolation operator norm
b(N) = 4 * V2_ * (Lambda(N)^m - 1) / (pi * 2 * big(N - 2)^2 * (Lambda(N) - 1))

# Loop over nbr of interpolation points
es = [NaN for _ in Ns]
bs = [NaN for _ in Ns]
for (i, N) = enumerate(Ns)
    local ghat = approximate_scalar(
        m,
        g;
        univariate_scheme=chebfun(N),
        eps_rel=1e-15
        )

    # e = max(|g - ghat|)
    es[i] = maximum([
        abs(g(x) - ghat(x))
        for x in [2 * rand(m) .- 1.0 for _ in 1:1000]])
    bs[i] = b(N)
end

p = plot(;
    xlabel="N",
    xticks=Ns,
    yaxis=:log,
    ylims=(1e-16, 2 * maximum([es..., bs...])),
    yticks=([1e0, 1e-5, 1e-10, 1e-15]),
    legend=:topright,
    )
plot!(p, Ns, bs; label="error bound")
scatter!(p, Ns, es; label="measured error")

# # To save figure and data to file:
# using CSV
# using DataFrames: DataFrame
# savefig("Example4.png")
# CSV.write("Example4.csv", DataFrame([:Ns => Ns, :es => es, :bs => bs]))
