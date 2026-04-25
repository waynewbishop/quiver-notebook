// Title: Exact Fractions from Floating-Point Math
//
// Floating-point arithmetic often produces results that look approximate
// in decimal — 0.7071... for √2/2, 0.6666... for 2/3 — but are actually
// exact rationals underneath. asFractions() reveals the rational form,
// which is useful for teaching, for audit trails, and for any setting
// where an exact representation matters more than fast arithmetic.

let v = [3.0, 4.0]
let unit = v.normalized

print("normalized (decimal): ", unit)
print("normalized (fractions):", unit.asFractions())

let ratios = [0.1, 0.2, 0.3, 0.5, 0.75]

print("decimals:  ", ratios)
print("fractions: ", ratios.asFractions())
