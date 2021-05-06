//
//  Action.swift
//  Mandelbrot
//
//  Created by Marcus Rossel on 20.02.21.
//

import Foundation

protocol Action: AnyObject {
    
    func next(imageSize: Int, center: Complex, iterations: Int, depth: Double) -> (imageSize: Int, center: Complex, iterations: Int, depth: Double)?
}   

final class Zoom: Action {
    
    enum Method {
        case target(Double)
        case factor(Double)
    }
    
    private let method: Method
    private var steps: Int
    
    init(method: Method, steps: Int) {
        self.method = method
        self.steps = steps
    }
    
    func next(imageSize: Int, center: Complex, iterations: Int, depth: Double) -> (imageSize: Int, center: Complex, iterations: Int, depth: Double)? {
        guard steps > 0 else { return nil }
        defer { steps -= 1 }

        let newDepth: Double
        
        switch method {
        case .target(let target):
            // https://math.stackexchange.com/q/4033025/889986
            // Method for segmenting a line (A,Z) into N logarithmic pieces:
            // 1) R = Z / A
            // 2) F = Nth root of R.
            // 3) Point[0] = A
            // 4) Point[x] = Point[x - 1] * F
            //
            // Here we only ever calculate Point[1],
            // because in the next iteration Point[1] becomes Point[0] aka A.
            // Hence we just recalculate R and F with the A and new number of steps (N - 1)
            // and apply that factor to A.
            let ratio = target / depth
            let factor = pow(ratio, 1.0 / Double(steps))
            newDepth = depth * factor
        case .factor(let factor):
            newDepth = depth * factor
        }
        
        return (imageSize: imageSize, center: center, iterations: iterations, depth: newDepth)
    }
}

final class Pan: Action {
    
    enum Method {
        case linear
        case logarithmic
    }
    
    private let target: Complex
    private var steps: Int
    private let method: Method = .linear
    
    init(target: Complex, steps: Int) {
        self.target = target
        self.steps = steps
    }
    
    func next(imageSize: Int, center: Complex, iterations: Int, depth: Double) -> (imageSize: Int, center: Complex, iterations: Int, depth: Double)? {
        guard steps > 0 else { return nil }
        defer { steps -= 1 }
        
        let newCenter: Complex
        
        switch method {
        case .linear:
            newCenter = center + (target - center) / Complex(real: Double(steps), imaginary: 0)
        case .logarithmic:
            // This can't be implemented as trivially as logarithmic zooming, because there are negative
            // and 0 values involved.
            fatalError()    
        }
        
        return (imageSize: imageSize, center: newCenter, iterations: iterations, depth: depth)
    }
}

final class Iterate: Action {
    
    private let target: Int
    private var steps: Int
    
    init(target: Int, steps: Int) {
        self.target = target
        self.steps = steps
    }
    
    func next(imageSize: Int, center: Complex, iterations: Int, depth: Double) -> (imageSize: Int, center: Complex, iterations: Int, depth: Double)? {
        guard steps > 0 else { return nil }
        defer { steps -= 1 }
        
        let newIterations = iterations + Int(Double(target - iterations) / Double(steps))
        return (imageSize: imageSize, center: center, iterations: newIterations, depth: depth)
    }
}

final class Resize: Action {
    
    private let target: Int
    private var steps: Int
    
    init(target: Int, steps: Int) {
        self.target = target
        self.steps = steps
    }
    
    func next(imageSize: Int, center: Complex, iterations: Int, depth: Double) -> (imageSize: Int, center: Complex, iterations: Int, depth: Double)? {
        guard steps > 0 else { return nil }
        defer { steps -= 1 }
        
        let newImageSize = imageSize + Int(Double(target - imageSize) / Double(steps))
        return (imageSize: newImageSize, center: center, iterations: iterations, depth: depth)
    }
}

final class Simultaneous: Action {
    
    private let actions: [Action]
    
    init(actions: [Action]) {
        self.actions = actions
    }
    
    func next(imageSize: Int, center: Complex, iterations: Int, depth: Double) -> (imageSize: Int, center: Complex, iterations: Int, depth: Double)? {
        var input = (imageSize: imageSize, center: center, iterations: iterations, depth: depth)
        var didSet = false
        
        for action in actions {
            if let next = action.next(imageSize: input.imageSize, center: input.center, iterations: input.iterations, depth: input.depth) {
                input = next
                didSet = true
            }
        }
        
        return didSet ? input : nil
    }
}
