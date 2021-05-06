//
//  Function.swift
//  Mandelbrot
//
//  Created by Marcus Rossel on 20.02.21.
//

import Foundation

enum Value {
    case hue(Float)
    case last(Complex)
}

protocol Function {
    
    func value(coordinate: Complex, limit: Int, frame: Frame, last: Complex?) -> Value
}

struct Mandelbrot: Function {
    
    func value(coordinate: Complex, limit: Int, frame: Frame, last: Complex?) -> Value {
        var z = Complex(real: 0, imaginary: 0)
        let c = coordinate
        
        for iteration in 0..<limit {
            z = (▫️z) + c
            if z.absolute > 2 { return .hue(Float(iteration) / Float(limit)) }
        }
        
        return .last(z)
    }
}

struct InverseMandelbrot: Function {
    
    func value(coordinate: Complex, limit: Int, frame: Frame, last: Complex?) -> Value {
        var z = Complex(real: 0, imaginary: 0)
        let c = coordinate
        
        for _ in 0..<limit {
            z = (▫️z) + c
            if z.absolute > 2 { return .last(z) }
        }
        
        return .hue(Float(abs(z.imaginary)) / 2)
    }
}

struct Julia: Function {
    
    let c: Complex
    
    func value(coordinate: Complex, limit: Int, frame: Frame, last: Complex?) -> Value {
        var z = coordinate
        
        for iteration in 0..<limit {
            z = (▫️z) + c
            if z.absolute > 2 { return .hue(Float(iteration) / Float(limit)) }
        }
        
        return .last(z)
    }
}

struct Gradient: Function {
    
    func value(coordinate: Complex, limit: Int, frame: Frame, last: Complex?) -> Value {
        .hue(Float((coordinate.real - frame.origin.real) / frame.width))
    }
}

struct Quadratic: Function {
    
    func value(coordinate: Complex, limit: Int, frame: Frame, last: Complex?) -> Value {
        // I think the greatest value of a quadratic must be one of the frame's corners.
        let bound = max(
            frame.origin.real * frame.origin.imaginary,
            frame.origin.real * (frame.origin.imaginary + frame.height),
            (frame.origin.real + frame.width) * frame.origin.imaginary,
            (frame.origin.real + frame.width) * (frame.origin.imaginary + frame.height)
        )
        
        let hue = abs(coordinate.real * coordinate.imaginary) / bound
        return .hue(Float(hue))
    }
}
