//
//  Pixel.swift
//  Mandelbrot
//
//  Created by Marcus Rossel on 19.02.21.
//

struct Pixel {
    
    static let black = Pixel(red: 0, green: 0, blue: 0)
    
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    
    private init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    init(hue: Float) {
        let x = 6 * hue
        
        switch x {
        case ...1: red = 255;                  green = UInt8(255 * x);       blue = 0
        case ...2: red = UInt8(255 * (2 - x)); green = 255;                  blue = 0
        case ...3: red = 0;                    green = 255;                  blue = UInt8(255 * (x - 2))
        case ...4: red = 0;                    green = UInt8(255 * (4 - x)); blue = 255
        case ...5: red = UInt8(255 * (x - 4)); green = 0;                    blue = 255
        case _:    red = 255;                  green = 0;                    blue = UInt8(255 * (6 - x));
        }
    }
}
