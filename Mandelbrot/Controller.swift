//
//  Controller.swift
//  Mandelbrot
//
//  Created by Marcus Rossel on 20.02.21.
//

typealias Frame = (origin: Complex, width: Double, height: Double)

final class Controller {
    
    private let function: Function
    private let setup: [Action]
    private let sequence: [Action]
    
    private var imageSize: Int {
        didSet {
            guard imageSize != oldValue else { return }
            pixelCoordinates = (0..<imageSize).map(Double.init)
            buffer = {
                let allocated = ImageBuffer.allocate(capacity: imageSize * imageSize)
                allocated.initialize(repeating: .black)
                return allocated
            }()
            renderer = Renderer(buffer: buffer, length: imageSize)
        }
    }
    
    private var center = Complex(real: 0, imaginary: 0)
    private var iterations = 200
    private var depth = 4.0
    
    private var pixelCoordinates: [Double]
    private var buffer: ImageBuffer
    private var renderer: Renderer
    
    private var frame: Frame {
        (origin: center - (Complex(real: depth, imaginary: depth) / 2),
         width:  depth,
         height: depth
        )
    }
    
    init(function: Function, setup: [Action] = [], sequence: [Action]) {
        self.function = function
        self.setup = setup
        self.sequence = sequence
        self.imageSize = 512
        
        pixelCoordinates = (0..<512).map(Double.init)
        buffer = {
            let allocated = ImageBuffer.allocate(capacity: 512 * 512)
            allocated.initialize(repeating: .black)
            return allocated
        }()
        renderer = Renderer(buffer: buffer, length: 512)
    }

    func run() {
        var id = (action: 0, image: 0)
        var lasts: [Complex: Complex] = [:]
        
        let phases = [
            (actions: setup,    render: false),
            (actions: sequence, render: true)
        ]
        
        for phase in phases {
            for action in phase.actions {
                id = (action: id.action + 1, image: id.image)
                
                while let new = action.next(imageSize: imageSize, center: center, iterations: iterations, depth: depth) {
                    id = (action: id.action, image: id.image + 1)
                    
                    imageSize = new.imageSize
                    center = new.center
                    iterations = new.iterations
                    depth = new.depth
                    
                    if phase.render { render(id: id, lasts: &lasts) }
                }
            }
        }
    }
    
    private func render(id: (Int, Int), lasts: inout [Complex: Complex]) {
        let scale = depth / Double(imageSize)
        let centerOffset = depth / 2
            
        let scaledCoordinates = pixelCoordinates.map { $0 * scale }
        let reals =       scaledCoordinates.map { $0 - centerOffset + center.real }
        let imaginaries = scaledCoordinates.map { $0 - centerOffset - center.imaginary }
            
        for y in 0..<imageSize {
            for x in 0..<imageSize {
                let coordinate = Complex(real: reals[x], imaginary: imaginaries[y])
                let index = imageSize * y + x
                
                switch function.value(coordinate: coordinate, limit: iterations, frame: frame, last: lasts[coordinate]) {
                case let .hue(hue):
                    buffer[index] = Pixel(hue: hue)
                    lasts[coordinate] = nil
                case let .last(last):
                    buffer[index] = Pixel.black
                    lasts[coordinate] = last
                }
            }
        }
            
        renderer.render(id: id)
    }
}

