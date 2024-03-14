//
//  File.swift
//  
//
//  Created by Aaron Beckley on 3/10/24.
//

import Foundation

func stl(y: Array<Double>, n: user_size_t, np: user_size_t, ns: user_size_t, nt: user_size_t, nl: user_size_t, isdeg: Int32, itdeg: Int32, ildeg: Int32, nsjump: user_size_t, ntjump: user_size_t, nljump: user_size_t, ni: user_size_t, no: user_size_t, rw: inout Array<Double>, season: inout Array<Double>, trend: inout Array<Double>) {
    var work1 = [Double](repeating: 0.0, count: Int(n + 2 * np))
    var work2 = [Double](repeating: 0.0, count: Int(n + 2 * np))
    var work3 = [Double](repeating: 0.0, count: Int(n + 2 * np))
    var work4 = [Double](repeating: 0.0, count: Int(n + 2 * np))
    var work5 = [Double](repeating: 0.0, count: Int(n + 2 * np))
    
    
    var userw = false
    var k = 0
    

    while true {
        /*
        print("Inside STL FUNC\n")
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
        print("The work1 is: \(work1)\n")
        print("The work2 is: \(work2)\n")
        print("The work3 is: \(work3)\n")
        print("The work4 is: \(work4)\n")
        print("The work5 is: \(work5)\n")
        */
        onestp(y: y, n: n, np: np, ns: ns, nt: nt, nl: nl, isdeg: isdeg, itdeg: itdeg, ildeg: ildeg, nsjump: nsjump, ntjump: ntjump, nljump: nljump, ni: ni, userw: userw, rw: &rw, season: &season, trend: &trend, work1: &work1, work2: &work2, work3: &work3, work4: &work4, work5: &work5)
        k += 1
        if k > no {
            break
        }
        for i in 0..<n {
            work1[Int(i)] = trend[Int(i)] + season[Int(i)]
        }
        rwts(y: y, n: n, fit: work1, rw: &rw)
        userw = true
    }
    
    if no == 0 {
        for i in rw.indices {
            rw[i] = 1.0
        }
    }
    
    
    
}

func rwts(y: Array<Double>, n: user_size_t, fit: Array<Double>, rw: inout Array<Double>) {
    for i in 0..<n {
        rw[Int(i)] = abs((y[Int(i)] - fit[Int(i)]))
    }
    let mid1 = (n - 1) / 2
    let mid2 = n / 2
    
    
    //https://play.rust-lang.org/?version=stable&mode=debug&edition=2021
    //https://doc.rust-lang.org/std/primitive.slice.html#method.sort_unstable_by
    //https://stackoverflow.com/questions/27436057/how-to-arrange-a-double-array-from-biggest-to-smallest-in-swift
    rw.sort(by: <)
    
    let cmad = 3.0 * (rw[Int(mid1)] + rw[Int(mid2)])
    let c9 = 0.999 * cmad
    let c1 = 0.001 * cmad
    
    for i in 0..<n {
        let r = abs(y[Int(i)] - fit[Int(i)])
        if r <= c1 {
            rw[Int(i)] = 1.0
            
        } else if r <= c9 {
            rw[Int(i)] = pow(1.0 - pow(r/cmad, 2), 2)
        } else {
            rw[Int(i)] = 0.0
        }
        
        
    }
    
    
    
}


func ess(y: Array<Double>, n: user_size_t, len: user_size_t, ideg: Int32, njump: user_size_t, userw: Bool, rw: inout Array<Double>, ys: inout Array<Double>, res: inout Array<Double>) {
    if n < 2 {
        ys[0] = y[0]
        return
    }
    /*
    print("INSIDE ESS FUNC\n")
    print("y Value (): \(y)\n")
    print("ys Value (): \(ys)\n")
     */
    
    
    var nleft = 0
    var nright = 0
    
    let newnj = min(njump, n-1)
    
    if len >= n {
        nleft = 1
        nright = Int(n)
        var i = 1
        while i <= n {
           
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(i), ys: &ys[i - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[i - 1] = y[i - 1]
            }
            i += Int(newnj)
        }
        
        
    } else if newnj == 1 {
        let nsh = (len + 1)/2
        nleft = 1
        nright = Int(len)
        for i in 1...n {
            if i > nsh && nright != n {
                nleft += 1
                nright += 1
            }
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(i), ys: &ys[Int(i) - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[Int(i) - 1] = y[Int(i) - 1]
            }
        }
    } else {
        let nsh = (len + 1) / 2
        var i = 1
        while i <= n {
            if i < nsh {
                nleft = 1
                nright = Int(len)
            } else if i > n - nsh {
                nleft = Int(n - len + 1)
                nright = Int(n)
            } else {
                nleft = i - Int(nsh) + 1
                nright = Int(len + UInt64(i) - nsh)
            }
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(i), ys: &ys[i - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[i - 1] = y[i - 1]
            }
            i += Int(newnj)
        }
    }
    
    if newnj != 1 {
        var i = 1
        while i <= n - newnj {
            let delta = (ys[i + Int(newnj) - 1] - ys[i - 1]) / (Double(newnj))
            for j in i + 1...i + Int(newnj) - 1{
                ys[j - 1] = ys[i - 1] + delta * Double((j - i))
            }
            i += Int(newnj)
        }
        let k = ((n - 1) / newnj) * newnj + 1
        if k != n {
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(n), ys: &ys[Int(n) - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[Int(n) - 1] = y[Int(n) - 1]
            }
            if k != n - 1 {
                let delta = (ys[Int(n) - 1] - ys[Int(k) - 1]) / Double((n - k))
                for j in k + 1...n - 1 {
                    ys[Int(j) - 1] = ys[Int(k) - 1] + delta * Double(j - k)
                }
            }
        }
    }
}

func est(y: Array<Double>, n: user_size_t, len: user_size_t, ideg: Int32, xs: Double, ys: inout Double, nleft: user_size_t, nright: user_size_t, w: inout Array<Double>, userw: Bool, rw: inout Array<Double>) -> Bool {
    //print("Entering EST Funct\n")
    //print("w just before anything happens:  \(w)")
    let range = Double(n) - 1.0
    var h = max(xs - Double(nleft), Double(nright) - xs)
    
    if len > n {
        h += Double((len - n) / 2)
    }
    let h9 = 0.999 * h
    let h1 = 0.001 * h
    
    var a = 0.0;

    //this good now
    for j in nleft...nright {
        w[Int(j)-1] = 0.0
        let r = abs(Double(j) - xs)
        if r <= h9 {
            if r <= h1 {
                w[Int(j) - 1] = 1.0
            } else {
                let power1 = 1.0 - pow((r / h), 3)
                w[Int(j) - 1] = pow(power1, 3)
            }
            if userw {
                w[Int(j) - 1] *= rw[Int(j) - 1]
            }
            a += w[Int(j) - 1]
            
        }
    }
   
    
    
    if a <= 0.0 {
        return false
    }
    else { // weighted least squares
        for j in nleft...nright {
            w[Int(j) - 1] /= a
        }
        if h > 0.0 && ideg > 0 { // use linear fit //make sure && in swift does same thing as && in rust
            var a = 0.0
            for j in nleft...nright {
                a += w[Int(j) - 1] * Double(j)
            }
            var b = xs - a
            var c = 0.0
            for j in nleft...nright {
                c += w[Int(j) - 1] * pow(Double(j) - a, 2)
            }
            if sqrt(c) > 0.001 * range {
                b /= c
                for j in nleft...nright {
                    w[Int(j) - 1] *= b * (Double(j) - a) + 1.0
                }
            }
        }
        //print("ys before: \(ys)")
        ys = 0.0 //This is a pointer in original rust code so gonna wanna make sure works
        for j in nleft...nright {
            //print("y: \(y[Int(j) - 1])")
            //print("w: \(w[Int(j) - 1])")
            ys += w[Int(j) - 1] * y[Int(j) - 1]
        }
        //print("ys after: \(ys)")
        return true
    }
}

func fts(x: Array<Double>, n: user_size_t, np: user_size_t, trend: inout Array<Double>, work: inout Array<Double>) {
    /*
    print("Inside FTS func\n")
    print("x before anything: \(x)\n")
    print("n before anything: \(n)\n")
    print("np before anything: \(np)\n")
    print("trend before anything: \(trend)\n")
    print("work before anything: \(work)\n")
    print("The ma inside fts start\n")
    */
    ma(x: x, n: n, len: np, ave: &trend)
    ma(x: trend, n: n - np + 1, len: np, ave: &work)
    ma(x: work, n: n - 2 * np + 2, len: 3, ave: &trend)

}

func ma(x: Array<Double>, n: user_size_t, len: user_size_t, ave: inout Array<Double>) {
    let newn = n - len + 1
    //print(newn)
    let flen = Double(len)
    //print("Inside ma func")
    
    

    var v: Double = x.prefix(Int(len)).reduce(0, +)
    ave[0] = v / flen
    //print("This is ave[0]: \(ave[0])")
    //https://stackoverflow.com/questions/9271970/how-do-you-make-a-range-in-rust
    if newn > 1 {
        var k = len
        //print("This is len: \(len)")

        for i in 0..<(ave.prefix(Int(newn)).count - 1) {
            v = v - x[i] + x[Int(k)]
            ave[i+1] = v / Double(flen)
            k += 1
           /* print("This is k: \(k)")
            print("This is m: \(i)")
            print("This is aj: \(ave[i+1])") */
        }
    }
}
                
                

func onestp(y: Array<Double>, n: user_size_t, np: user_size_t, ns: user_size_t, nt: user_size_t, nl: user_size_t, isdeg: Int32, itdeg: Int32, ildeg: Int32, nsjump: user_size_t, ntjump: user_size_t, nljump: user_size_t, ni: user_size_t, userw: Bool, rw: inout Array<Double>, season: inout Array<Double>, trend: inout Array<Double>, work1: inout Array<Double>, work2: inout Array<Double>, work3: inout Array<Double>, work4: inout Array<Double>, work5: inout Array<Double>) {
    //This works
    for _ in 0..<ni {
        for i in 0..<n {
            work1[Int(i)] = y[Int(i)] - trend[Int(i)];
        }
        //
        /*
        print("INSIDE ONESTP\n")
        print("work1 is \(work1)\n")
        print("before SS\n")
        */
        ss(y: work1, n: n, np: np, ns: ns, isdeg: isdeg, nsjump: nsjump, userw: userw, rw: rw, season: &work2, work1: &work3, work2: &work4, work3: &work5, work4: &season)
        //print("before fts\n")
        fts(x: work2, n: n + 2 * np, np: np, trend: &work3, work: &work1)
        //print("before ess\n")
        ess(y: work3, n: n, len: nl, ideg: ildeg, njump: nljump, userw: false, rw: &work4, ys: &work1, res: &work5)
        for i in 0..<n {
            season[Int(i)] = work2[Int(np + i)] - work1[Int(i)]
        }
        for i in 0..<n {
            work1[Int(i)] = y[Int(i)] - season[Int(i)]
        }
        ess(y: work1, n: n, len: nt, ideg: itdeg, njump: ntjump, userw: userw, rw: &rw, ys: &trend, res: &work3)
    }
    
    
}





func ss(y: Array<Double>, n: user_size_t, np: user_size_t, ns: user_size_t, isdeg: Int32, nsjump: user_size_t, userw: Bool, rw: Array<Double>, season: inout Array<Double>, work1: inout Array<Double>, work2: inout Array<Double>, work3: inout Array<Double>, work4: inout Array<Double>) {
    
    for j in 1...np {
        let k = (n - j) / np + 1;
        for i in 1...k {
                    //let locationRight = np + j - 1
                    //let location = (Int(i) - 1) * Int(locationRight)
                    //let worker = y[location]
                    let worker = y[(Int(i) - 1) * Int(np) + Int(j) - 1]
                    work1[Int(i) - 1] = worker
                }
      /*
        print("INSIDE SS FUNC\n")
        print("work1 is \(work1)\n")
        print("Userw is set to: \(userw)\n")
        */
        if userw {
            for i in 1...k {
                //let locationRight = np + j - 1
                //let location = (Int(i) - 1) * Int(locationRight)
                let location = (Int(i) - 1) * Int(np) + Int(j) - 1
                work3[Int(i) - 1] = rw[location]
            }
        }
        //This needs a slice passed for the ys array, so I made a sep function for it
        //ys aka work2 is used as a slice work2[1..] in rust, so created func to try to emulate that without types
        //print("work2 before essButWithPlusOne Work2 is: \(work2)\n")
        essButWithPlusOne(y: work1, n: k, len: ns, ideg: isdeg, njump: nsjump, userw: userw, rw: &work3, ys: &work2, res: &work4)
        var xs = 0.0
        let nright = min(ns, k)
        //print("work2 after essButWithPlusOne Work2 is: \(work2)\n")
        var ok = est(y: work1, n: k, len: ns, ideg: isdeg, xs: xs, ys: &work2[0], nleft: 1, nright: nright, w: &work4, userw: userw, rw: &work3)
        //print("First OK: \(ok)\n")
        if !ok {
            work2[0] = work2[1]
        }
        xs = Double(k + 1)
        let nleft = max(1, Int(k) - Int(ns) + 1)
        //print("Work2 is: \(work2)\n")
        ok = est(y: work1, n: k, len: ns, ideg: isdeg, xs: xs, ys: &work2[Int(k) + 1], nleft: user_size_t(nleft), nright: k, w: &work4, userw: userw, rw: &work3)
        //print("Second OK: \(ok)\n")
        if !ok {
            work2[Int(k) + 1] = work2[Int(k)]
        }
        for m in 1...k + 2{ //clean this up
            //let partone = ((Int(m) - 1) * Int(np))
            //let parttwo = (Int(j) - 1)
            //print(k+2)
            //print(m)
            //print(partone + parttwo)
            let array1 = work2[Int(m) - 1]
            season[(Int(m) - 1) * Int(np) + Int(j) - 1] = array1
        }
    }
}


func essButWithPlusOne(y: Array<Double>, n: user_size_t, len: user_size_t, ideg: Int32, njump: user_size_t, userw: Bool, rw: inout Array<Double>, ys: inout Array<Double>, res: inout Array<Double>) {
    if n < 2 {
        ys[1] = y[0]
        return
    }
    /*
    print("INSIDE essButWithPlusOne FUNC\n")
    print("y is \(y)\n")
    print("ys us: \(ys)\n") */
    var nleft = 0
    var nright = 0
    
    let newnj = min(njump, n-1)
    
    if len >= n {
        nleft = 1
        nright = Int(n)
        var i = 1
        while i <= n {
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(i), ys: &ys[i+1 - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[i+1 - 1] = y[i - 1]
            }
            i += Int(newnj)
        }
        //print("ys after if len \(ys)")
        
    } else if newnj == 1 {
        let nsh = (len + 1)/2
        nleft = 1
        nright = Int(len)
        for i in 1...n {
            if i > nsh && nright != n {
                nleft += 1
                nright += 1
            }
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(i), ys: &ys[Int(i+1) - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[Int(i+1) - 1] = y[Int(i) - 1]
            }
        }
    } else {
        let nsh = (len + 1) / 2
        var i = 1
        while i <= n {
            if i < nsh {
                nleft = 1
                nright = Int(len)
            } else if i > n - nsh {
                nleft = Int(n - len + 1)
                nright = Int(n)
            } else {
                nleft = i - Int(nsh) + 1
                nright = Int(len + UInt64(i) - nsh)
            }
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(i), ys: &ys[i+1 - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[i+1 - 1] = y[i - 1]
            }
            i += Int(newnj)
        }
    }
    
    if newnj != 1 {
        var i = 1
        while i <= n - newnj {
            let delta = (ys[i+1 + Int(newnj) - 1] - ys[i+1 - 1]) / (Double(newnj))
            //print("This is delta: \(delta)")
            for j in i + 1...i + Int(newnj) - 1{
                ys[j+1 - 1] = ys[i+1 - 1] + delta * Double((j - i))
            }
            i += Int(newnj)
        }
        let k = ((n - 1) / newnj) * newnj + 1
        if k != n {
            let ok = est(y: y, n: n, len: len, ideg: ideg, xs: Double(n), ys: &ys[1 + Int(n) - 1], nleft: user_size_t(nleft), nright: user_size_t(nright), w: &res, userw: userw, rw: &rw)
            if !ok {
                ys[1 + Int(n) - 1] = y[Int(n) - 1]
            }
            if k != n - 1 {
                let delta = (ys[1 + Int(n) - 1] - ys[1 + Int(k) - 1]) / Double((n - k))
                for j in k + 1...n - 1 {
                    ys[1 + Int(j) - 1] = ys[1 + Int(k) - 1] + delta * Double(j - k)
                }
            }
        }
    }
}
