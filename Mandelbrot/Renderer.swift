//
//  Renderer.swift
//  Mandelbrot
//
//  Created by Marcus Rossel on 19.02.21.
//

import AppKit

typealias ImageBuffer = UnsafeMutableBufferPointer<Pixel>

final class Renderer {
        
    let buffer: ImageBuffer
    let length: Int
    
    init(buffer: ImageBuffer, length: Int) {
        self.buffer = buffer
        self.length = length
    }
    
    func render(id: (action: Int, image: Int)) {
        let bufferSize = length * length * MemoryLayout<Pixel>.stride
        let data = CGDataProvider(data: NSData(bytes: UnsafeMutableRawPointer(buffer.baseAddress), length: bufferSize))!
        
        let image = CGImage(
            width: length,
            height: length,
            bitsPerComponent: 8,
            bitsPerPixel: 24,
            bytesPerRow: length * MemoryLayout<Pixel>.stride,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: data,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )!

        
        let url = URL(string: "file:///Users/marcus/Desktop/Mandelbrot/\(id.image)-action-\(id.action).png")!
        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil)!
        
        CGImageDestinationAddImage(destination, image, nil)
        CGImageDestinationFinalize(destination)
    }
}
