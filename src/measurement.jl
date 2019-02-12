# [1] Pratt, William K., Digital Image Processing, New York, John Wiley & Sons, Inc., 1991, p. 634.
function measure_feature(property::Measurement, t::IndexedTable, labels::AbstractArray, N::Int = 0)
    fill_properties(property, t)
end

function fill_properties(property::Measurement, t::IndexedTable)
    t = property.area ? compute_area(t) : t
    t = property.perimeter ? compute_perimeter(t) : t
end

function compute_area(t::IndexedTable)
    # Equation 18.2-8a
    # Pratt, William K., Digital Image Processing, New York, John Wiley & Sons, Inc., 1991, p. 629.
    @transform t {area = ((1/4)*:Q₁ + (1/2)*:Q₂ + (7/8)*:Q₃ + :Q₄ +(3/4)*:Qₓ) }
end

function compute_perimeter(t::IndexedTable)
    # perimiter₀ and perimter₁ are given by equations 18.2-8b and 18.2-7a in [1].
    # perimeter₂ is given by equation (32) in [2]
    # [1] Pratt, William K., Digital Image Processing, New York, John Wiley & Sons, Inc., 1991, p. 629.
    # [2] S. B. Gray, “Local Properties of Binary Images in Two Dimensions,” IEEE Transactions on Computers, vol. C–20, no. 5, pp. 551–561, May 1971. https://doi.org/10.1109/t-c.1971.223289
    @transform t {perimeter₀ = (:Q₂ + (1/sqrt(2))*(:Q₁ + :Q₃ + 2*:Qₓ)), perimeter₁ = (:Q₁ + :Q₂ + :Q₃ + 2*:Qₓ), perimeter₂ = (:Q₂ + (:Q₁ +:Q₃)/sqrt(2)) }
end
