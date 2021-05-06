//
//  main.swift
//  Mandelbrot
//
//  Created by Marcus Rossel on 18.02.21.
//

// Targets:
// (1) (x: -0.74507899999651, y: 0.11844999988, precision: 300, area: 6 / 2.1^depth)
// (2) (x: -0.745078913977592, y: 0.11846019897722749, precision: 50, area: 6 / 2.1^depth)
// (3) (x: -0.745078913977592, y: 0.11846019897722749, precision: 9, area: 3 / 1.1^depth)
// (4) (x: 0.25001000309, y: 0.00000005050, precision: 50, area: 4 / 1.08^depth)

// Iterators:
// (1) (x: 0.25001000309, y: 0.00000005050, limit: 100 * depth, area: 4 / 1.08^300)

Controller(
    function: Mandelbrot(),
    setup: [
        Simultaneous(actions: [
            Pan(target: .init(real: -0.745078913977592, imaginary: 0.11846019897722749), steps: 1),
            Zoom(method: .target(0.0001), steps: 30),
            Iterate(target: 5000, steps: 30),
        ]),
        Pan(target: .init(real: -0.74499, imaginary: 0.1184), steps: 10),
    ],
    sequence: [
        Zoom(method: .target(0.00001), steps: 10),
        Simultaneous(actions: [
            Resize(target: 4096, steps: 10),
            Iterate(target: 20000, steps: 10)
        ])
    ]
)
.run()
