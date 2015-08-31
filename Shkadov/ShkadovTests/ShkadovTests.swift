/*
The MIT License (MIT)

Copyright (c) 2015 Justin Kolb

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import XCTest
import simd
@testable import Shkadov

class ShkadovTests: XCTestCase {
    func testKind() {
        XCTAssertEqual(OrientationComponent.kind, OrientationComponent.kind)
        XCTAssertNotEqual(OrientationComponent.kind, ProjectionComponent.kind)
    }
    
    func testEntityComponents() {
        let entityComponents = EntityComponents()
        let entity = entityComponents.createEntity()
        let orientation = OrientationComponent(position: float3(0.0), forward: float3(0.0), right: float3(0.0))
        let projection = ProjectionComponent(projectionMatrix: float4x4(0.0))
        entityComponents.addComponent(orientation, toEntity: entity)
        entityComponents.addComponent(projection, toEntity: entity)
        let orientation2 = entityComponents.componentForEntity(entity, withComponentType: OrientationComponent.self)
        XCTAssertNotNil(orientation2)
        let projection2 = entityComponents.componentForEntity(entity, withComponentType: ProjectionComponent.self)
        XCTAssertNotNil(projection2)
    }
}
