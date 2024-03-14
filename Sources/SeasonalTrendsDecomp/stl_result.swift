//
//  File.swift
//  
//
//  Created by Aaron Beckley on 3/10/24.
//

import Foundation

func variation(series: Array<Double>) -> Double {
    //https://stackoverflow.com/questions/24795130/finding-sum-of-elements-in-swift-array
    let mean = series.reduce(0, +) / Double(series.count)
    var copySeries = series
    for i in 0..<copySeries.count {
        copySeries[i] = pow(copySeries[i] - mean, 2.0)
    }
    let value = copySeries.reduce(0, +) / (Double(copySeries.count) - 1.0)
    
    return value
}

public func strength(component: Array<Double>, remainder: Array<Double>) -> Double {
    let combined = zip(component, remainder)
    let sr = combined.map { (a, b) in a + b }
    return (1.0 - variation(series: remainder) / max(variation(series: sr), 0.0))
}


public struct StlResult {
    public var seasonal: Array<Double> = []
    public var trend: Array<Double> = []
    public var remainder: Array<Double> = []
    public var weights: Array<Double> = []
    
   public init(seasonal: Array<Double>, trend: Array<Double>, remainder: Array<Double>, weights: Array<Double>) {
        self.seasonal = seasonal
        self.trend = trend
        self.remainder = remainder
        self.weights = weights
    }
    
    
    
    public func seasonal_strength() -> Double {
        return strength(component: self.seasonal, remainder: self.remainder)
    }
    
    public func trend_strength() -> Double {
        return strength(component: self.trend, remainder: self.remainder)
    }
    
}
