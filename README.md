# STL Swift
Work In Progress

# Seasonal-Trends-Decomposition-STL-Swift

## Getting Started

Decompose a time series

```swift
let Array = [
5.0, 9.0, 2.0, 9.0, 0.0, 6.0, 3.0, 8.0, 5.0, 8.0,
7.0, 8.0, 8.0, 0.0, 2.0, 5.0, 0.0, 5.0, 6.0, 7.0,
3.0, 6.0, 1.0, 4.0, 4.0, 4.0, 3.0, 7.0, 5.0, 8.0
        ]
        
        let period = 7; // period of the seasonal component
        do {
            let res = try StlParams().fit(series: Array, period: user_size_t(period))
        } catch {
            print("Could not resolve")
        }
```

Get the components

```swift
res.seasonal
res.trend
res.remainder
```

## Robustness

Use robustness iterations

```swift
let res = try StlParams(robust: true).fit(series: Array, period: user_size_t(period))
```

Get robustness weights

```swift
res.weights
```

## Multiple Seasonality

Work in Progress


## Parameters

Set STL parameters

```swift
StlParams(
        ns: 7,
        nt: 15,
        nl: 7,
        isdeg: 0,
        itdeg: 1,
        ildeg: 1,
        nsjump: 1,
        ntjump: 2,
        nljump: 1,
        ni: 2,
        no: 0,
        robust: false,
        debug: false
)
```

## Credits


This library was ported from the [Rust implementation](https://github.com/ankane/stl-rust/).
Which was ported from [Fortran implementation](https://www.netlib.org/a/stl).

## References

- [STL: A Seasonal-Trend Decomposition Procedure Based on Loess](https://www.scb.se/contentassets/ca21efb41fee47d293bbee5bf7be7fb3/stl-a-seasonal-trend-decomposition-procedure-based-on-loess.pdf)
- [MSTL: A Seasonal-Trend Decomposition Algorithm for Time Series with Multiple Seasonal Patterns](https://arxiv.org/pdf/2107.13462.pdf)
- [Measuring strength of trend and seasonality](https://otexts.com/fpp2/seasonal-strength.html)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ambeckley/Seasonal-Trends-Decomposition-STL-Swift/issues)
- Fix bugs and [submit pull requests](https://github.com/ambeckley/Seasonal-Trends-Decomposition-STL-Swift/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features





