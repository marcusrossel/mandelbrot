//
//  Complex.swift
//  Mandelbrot
//
//  Created by Marcus Rossel on 19.02.21.
//

import Foundation

prefix operator ▫️

public struct Complex: Hashable {
    
    public let real: Double
    public let imaginary: Double
    
    public init(real: Double, imaginary: Double) {
        self.real = real
        self.imaginary = imaginary
    }
    
    var conjugate: Complex { Complex(real: real, imaginary: -imaginary) }
    var norm: Double { (real * real) + (imaginary * imaginary) }
    var absolute: Double { sqrt(norm) }
    
    @inlinable public static prefix func ▫️(c: Complex) -> Complex {
        Complex(
            real: (c.real * c.real) - (c.imaginary * c.imaginary),
            imaginary: 2 * c.real * c.imaginary
        )
    }
    
    @inlinable public static func +(lhs: Complex, rhs: Complex) -> Complex {
        Complex(
            real: lhs.real + rhs.real,
            imaginary: lhs.imaginary + rhs.imaginary
        )
    }
    
    static func -(lhs: Complex, rhs: Complex) -> Complex {
        Complex(
            real: lhs.real - rhs.real,
            imaginary: lhs.imaginary - rhs.imaginary
        )
    }
    
    static func *(lhs: Complex, rhs: Complex) -> Complex {
        Complex(
            real: lhs.real * rhs.real - lhs.imaginary * rhs.imaginary,
            imaginary: lhs.real * rhs.imaginary + lhs.imaginary * rhs.real
        )
    }
    
    static func /(lhs: Complex, rhs: Double) -> Self {
        Complex(real: lhs.real / rhs, imaginary: lhs.imaginary / rhs)
    }
    
    static func /(lhs: Complex, rhs: Complex) -> Self {
        if rhs.imaginary == 0 {
            return lhs / rhs.real
        } else {
            return lhs * rhs.conjugate / rhs.norm
        }
    }
}
