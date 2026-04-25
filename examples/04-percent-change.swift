// Title: Percent Change Over Time
//
// percentChange computes period-over-period change on a time series.
// Default lag is 1 (e.g. day-over-day). Use lag: 7 for week-over-week,
// lag: 12 for year-over-year on monthly data.

let monthlyRevenue = [100.0, 105.0, 102.0, 110.0, 115.0, 108.0]

let monthOverMonth = monthlyRevenue.percentChange()
print("month-over-month %:", monthOverMonth)

let quarterOverQuarter = monthlyRevenue.percentChange(lag: 3)
print("quarter-over-quarter %:", quarterOverQuarter)
