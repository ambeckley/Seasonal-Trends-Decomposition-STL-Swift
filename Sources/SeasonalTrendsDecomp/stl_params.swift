//
//  File.swift
//  
//
//  Created by Aaron Beckley on 3/10/24.
//

import Foundation

public struct StlParams {
    var ns: user_size_t?
    var nt: user_size_t?
    var nl: user_size_t?
    var isdeg = 0
    var itdeg = 1
    var ildeg: Int32?
    var nsjump: user_size_t?
    var ntjump: user_size_t?
    var nljump: user_size_t?
    var ni: user_size_t?
    var no: user_size_t?
    var robust = false
    var debug = false
   //https://stackoverflow.com/questions/65659207/how-to-define-and-use-a-struct-with-an-optional-property-in-swift
    public init(ns: user_size_t? = nil, nt: user_size_t? = nil, nl: user_size_t? = nil, isdeg: Int = 0, itdeg: Int = 1, ildeg: Int32? = nil, nsjump: user_size_t? = nil, ntjump: user_size_t? = nil, nljump: user_size_t? = nil, ni: user_size_t? = nil, no: user_size_t? = nil, robust: Bool = false, debug: Bool = false) {
        self.ns = ns
        self.nt = nt
        self.nl = nl
        self.isdeg = isdeg
        self.itdeg = itdeg
        self.ildeg = ildeg
        self.nsjump = nsjump
        self.ntjump = ntjump
        self.nljump = nljump
        self.ni = ni
        self.no = no
        self.robust = robust
        self.debug = debug
    }
    /*
    // Sets the length of the seasonal smoother.
    public mutating func seasonal_length(length: user_size_t) {
        self.ns = length
    }
    // Sets the length of the trend smoother.
    public mutating func trend_length(length: user_size_t) {
        self.nt = length
    }
    // Sets the length of the low-pass filter.
    public mutating func low_pass_length(length: user_size_t) {
        self.nl = length
    }
    // Sets the degree of locally-fitted polynomial in seasonal smoothing.
    public mutating func seasonal_degree(degree: Int) {
        self.isdeg = degree
    }
    // Sets the degree of locally-fitted polynomial in trend smoothing.
    public mutating func trend_degree(degree: Int) {
        self.itdeg = degree
    }
    // Sets the degree of locally-fitted polynomial in low-pass smoothing.
    public mutating func low_pass_degree(degree: Int) {
        self.ildeg = Int32(degree)
    }
    // Sets the skipping value for seasonal smoothing.
    public mutating func seasonal_jump(jump: user_size_t) {
        self.nsjump = jump
    }
    // Sets the skipping value for trend smoothing.
    public mutating func trend_jump(jump: user_size_t) {
        self.ntjump = jump
    }
    // Sets the skipping value for low-pass smoothing.
    public mutating func low_pass_jump(jump: user_size_t) {
        self.nljump = jump
    }
    
    // Sets the number of loops for updating the seasonal and trend components.
    public mutating func inner_loops(loops: user_size_t) {
        self.ni = loops
    }
    // Sets the number of iterations of robust fitting.
    public mutating func outer_loops(loops: user_size_t) {
        self.no = loops
    }
    // Sets whether robustness iterations are to be used.
    public mutating func robust(robust: Bool) {
        self.robust = robust
    }
    public mutating func debug(debug: Bool) {
        self.debug = debug
    }
    */
    
    //error codes
    enum codeError: Error {
        case errorFromFit
    }
    
    //Decompose a time series
    public func fit(series: Array<Double>, period: user_size_t) throws -> StlResult {
    
    
    let y = series
    let np = period
    let n = y.count
    
    
    
    
    //need proper error handling
        guard !(n < np * 2) else {
        print("series has less than two periods")
        throw codeError.errorFromFit
    //way to handle errors
    //abort()
    }
        let ns = self.ns ?? np
       
        let isdeg = self.isdeg
        let itdeg = self.itdeg
        var rw = [Double](repeating: 0.0, count: n)
        var season = [Double](repeating: 0.0, count: n)
        var trend = [Double](repeating: 0.0, count: n)
        
        
        let ildeg = self.ildeg ?? Int32(itdeg)
        
        var newns = max(ns, 3)
        if newns % 2 == 0 {
            newns += 1
        }
        let newnp = max(np, 2)
        
        let part1 = 1.5 * Double(newnp)
        let part2 = 1.0 - 1.5 / Double(newns)
        let partdivision = part1/part2
        var nt = user_size_t(ceil(partdivision))
        
        nt = self.nt ?? nt
        nt = max(nt, 3)
        if nt % 2 == 0 {
            nt += 1
        }
        
        var nl = self.nl ?? newnp
        if nl % 2 == 0 && (self.nl == nil) {
            nl += 1
        }
        
        
        let ni = self.ni ?? {if self.robust {return 1} else { return 2}}()
        let no = self.no ?? {if self.robust {return 15} else { return 0}}()
        
        let nsjump = self.nsjump ?? {return user_size_t(ceil(Double(newns)/10.0))}()
        let ntjump = self.ntjump ?? {return user_size_t(ceil(Double(nt)/10.0))}()
        let nljump = self.nljump ?? {return user_size_t(ceil(Double(nl)/10.0))}()
        
        
        guard !(newns < 3) else {
        print("seasonal_length must be at least 3")
        throw codeError.errorFromFit
    }
        guard !(nt < 3) else {
        print("trend_length must be at least 3")
        throw codeError.errorFromFit
    }
        guard !(nl < 3) else {
        print("low_pass_length must be at least 3")
        throw codeError.errorFromFit
    }
        guard !(newnp < 3) else {
        print("period must be at least 2")
        throw codeError.errorFromFit
    }
        guard !((isdeg != 0) && (isdeg != 1)) else {
        print("seasonal_degree must be 0 or 1")
        throw codeError.errorFromFit
    }
        guard !((itdeg != 0) && (itdeg != 1)) else {
        print("trend_degree must be 0 or 1")
        throw codeError.errorFromFit
    }
        guard !((ildeg != 0) && (ildeg != 1)) else {
        print("low_pass_degree must be 0 or 1")
        throw codeError.errorFromFit
    }
        guard !((newns % 2) != 1) else {
        print("seasonal_length must be odd")
        throw codeError.errorFromFit
    }
        guard !((nt % 2) != 1) else {
        print("trend_length must be odd")
        throw codeError.errorFromFit
    }
        guard !((nl % 2) != 1) else {
        print("low_pass_length must be odd")
        throw codeError.errorFromFit
    }
        if debug {
            print("The series is: \(series)\n")
            print("The y is: \(y)\n")
            print("The n is: \(n)\n")
            print("The np is: \(np)\n")
            print("The ns is: \(ns)\n")
            print("The nt is: \(nt)\n")
            print("The nl is: \(nl)\n")
            print("The isdeg is: \(isdeg)\n")
            print("The itdeg is: \(itdeg)\n")
            print("The ildeg is: \(ildeg)\n")
            print("The nsjump is: \(nsjump)\n")
            print("The ntjump is: \(ntjump)\n")
            print("The nljump is: \(nljump)\n")
            print("The ni is: \(ni)\n")
            print("The no is: \(no)\n")
            print("The rw is: \(rw)\n")
            print("The season is: \(season)\n")
            print("The trend is: \(trend)\n")
        }
        
        
        
        stl(y: y, n: user_size_t(n), np: newnp, ns: newns, nt: nt, nl: nl, isdeg: Int32(isdeg), itdeg: Int32(itdeg), ildeg: ildeg, nsjump: nsjump, ntjump: ntjump, nljump: nljump, ni: ni, no: no, rw: &rw, season: &season, trend: &trend)
    
        var remainder = [Double]()
        for i in 0..<n {
            remainder.append(y[i] - season[i] - trend[i])
        }
    
        
    
    let result = StlResult(seasonal: season, trend: trend, remainder: remainder, weights: rw)
    
    return result
    }
    
    
}
