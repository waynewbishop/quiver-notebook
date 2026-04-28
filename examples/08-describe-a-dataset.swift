// Title: Describe a Dataset with Panel
//
// A Panel is a named-column container for numerical data. Think of it as
// a tiny, typed dataframe: columns are [Double], rows align across columns,
// and head() + summary() give an instant feel for the data.

let data = Panel([
    ("height", [172.0, 168.0, 181.0, 175.0, 160.0, 178.0]),
    ("weight", [70.0, 65.0, 82.0, 74.0, 55.0, 78.0]),
    ("age",    [28.0, 34.0, 42.0, 31.0, 25.0, 38.0])
])

print("shape:", data.shape)
print()
print(data.head(n: 3))
print()
print(data.summary())
