/*
The MIT License (MIT)

Copyright (c) 2016 Justin Kolb

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

public func intersectTest(box: AABB, _ plane: Plane) -> Bool {
    let projectionRadiusOfBox = sum(box.radius * abs(plane.normal))
    let distanceOfBoxCenterFromPlane = abs(dot(plane.normal, box.center) - plane.distanceToOrigin)
    return distanceOfBoxCenterFromPlane <= projectionRadiusOfBox
}

public func intersectTest(boxA: AABB, _ boxB: AABB) -> Bool {
    if abs(boxA.center.x - boxB.center.x) > (boxA.radius.x + boxB.radius.x) { return false }
    if abs(boxA.center.y - boxB.center.y) > (boxA.radius.y + boxB.radius.y) { return false }
    if abs(boxA.center.z - boxB.center.z) > (boxA.radius.z + boxB.radius.z) { return false }
    return true
}

public func intersectTest(sphere: Sphere, _ plane: Plane) -> Bool {
    let distance = dot(sphere.center, plane.normal) - plane.distanceToOrigin
    return abs(distance) <= sphere.radius
}

public func intersectTest(sphere: Sphere, _ box: AABB) -> Bool {
    let distanceSquared = distance2(sphere.center, box)
    return distanceSquared <= sphere.radius * sphere.radius
}

public func intersectTest(sphereA: Sphere, _ sphereB: Sphere) -> Bool {
    let delta = sphereA.center - sphereB.center
    let distanceSquared = dot(delta, delta)
    let radiusSum = sphereA.radius + sphereB.radius
    return distanceSquared < radiusSum * radiusSum
}

public func insideTest(point: Vector3D, _ box: AABB) -> Bool {
    let bmin = box.minimum
    let bmax = box.maximum
    let xin = point.x > bmin.x && point.x < bmax.x
    let yin = point.y > bmin.y && point.y < bmax.y
    let zin = point.z > bmin.z && point.z < bmax.z
    
    return xin && yin && zin
}

public func intersectTest(ray: Ray3D, _ box: AABB) -> Bool {
    var tmin = Float(0.0)
    var tmax = floatMax
    let amin = box.minimum
    let amax = box.maximum
    
    for i in 0..<3 {
        let oi = ray.origin[i]
        let di = ray.direction[i]
        
        if abs(di) < 0.000001 {
            if oi < amin[i] || oi > amax[i] {
                return false
            }
        }
        else {
            let ood = 1.0 / di
            var t1 = (amin[i] - oi) * ood
            var t2 = (amax[i] - oi) * ood
            
            if t1 > t2 {
                swap(&t1, &t2)
            }
            
            tmin = max(tmin, t1)
            tmax = min(tmax, t2)
            
            if tmin > tmax {
                return false
            }
        }
    }
    
    return true
}

public func intersectTest(ray: Ray3D, _ triangle: Triangle3D) -> Bool {
    let ab = triangle.b - triangle.a
    let ac = triangle.c - triangle.a
    let qp = -ray.direction
    
    let n = cross(ab, ac)
    
    let d = dot(qp, n)
    
    if d <= 0.0 {
        return false
    }
    
    let ap = ray.origin - triangle.a
    let t = dot(ap, n)
    
    if t < 0.0 {
        return false
    }

    let e = cross(qp, ap)
    let v = dot(ac, e)
    
    if v < 0.0 || v > d {
        return false
    }
    
    let w = -dot(ab, e)
    
    if w < 0.0 || v + w > d {
        return false
    }
    
    return true
}
