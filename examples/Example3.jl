using ApproximatingMapsBetweenLinearSpaces
using Plots; pyplot()
using Random; Random.seed!(1)

m=4
Ns=2:2:26

function g(x)
    return exp(-sum([xi^2 for xi in x]))
end

Lambda(N) = (2 / pi) * log(N + 1) + 1 # Chebyshev interpolation operator norm
b(N) = minimum([ # Bound for |g - ghat|
    # 4 * V(nu) * (Lambda(N)^m - 1) / (pi * nu * big(N - nu)^nu * (Lambda(N) - 1))
    let
        rho = beta + sqrt(beta^2 + 1)
        C = exp(m - 1 + beta^2)
        4 * (Lambda(N)^m - 1) * C / ((rho - 1) * rho^N * (Lambda(N) - 1)) # TODO: reference the correct equation in the article
    end
    for beta in 0.0:.5:10.0])

# Loop over nbr of interpolation points
es = [NaN for _ in Ns]
bs = [NaN for _ in Ns]
for (i, N) = enumerate(Ns)
    local ghat = approximate_scalar(
        m,
        g;
        univariate_scheme=chebyshev(N),
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
plot!(p, Ns[1:end - 2], bs[1:end - 2]; label="error bound")
scatter!(p, Ns, es; label="measured error", color=2)

# # To save figure and data to file:
# using CSV
# using DataFrames: DataFrame
# savefig("Example3.png")
# CSV.write("Example3.csv", DataFrame([:Ns => Ns, :es => es, :bs => bs]))
