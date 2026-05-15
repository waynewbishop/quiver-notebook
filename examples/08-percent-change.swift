// Title: Percent Change Over Time
//
// percentChange computes period-over-period change on a time series.
// Default lag is 1 (e.g. day-over-day). Use lag: 7 for week-over-week,
// lag: 365 for year-over-year on daily data. rollingMean smooths the
// same series over a sliding window so trend reads through the noise.
//
// The bikeSharing dataset is 731 daily rider counts from a real
// bike-share system — exactly the shape of an on-device time series
// an app would produce from its own usage data.

guard let bikes = Dataset.bikeSharing,
      let cnt = bikes["cnt"] else {
    exit(0)
}

// First three weeks of daily counts.
let firstThreeWeeks = Array(cnt.prefix(21))
print("first 21 daily counts:", firstThreeWeeks.map { Int($0) })
print()

// Day-over-day change in ridership.
let dayOverDay = firstThreeWeeks.percentChange()
print("day-over-day %:", dayOverDay.map { String(format: "%+.1f", $0) })
print()

// Week-over-week — same shape, different lag.
let weekOverWeek = firstThreeWeeks.percentChange(lag: 7)
print("week-over-week %:", weekOverWeek.map { String(format: "%+.1f", $0) })
print()

// A 7-day rolling mean smooths the weekday/weekend swing.
let weeklyTrend = firstThreeWeeks.rollingMean(window: 7)
print("7-day rolling mean:", weeklyTrend.map { String(format: "%.0f", $0) })
