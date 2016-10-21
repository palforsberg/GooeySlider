//
//  GooeyLayer.swift
//  Gooey2
//
//  Created by Pål Forsberg on 2015-02-18.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import UIKit

enum Direction {
    case Back
    //    case TopOut
    //    case TopIn
    //    case TopRightOut
    //    case TopRightIn
    case RightOut
    case RightIn
    //    case BottomRightOut
    //    case BottomRightIn
    //    case BottomOut
    //    case BottomIn
    //    case BottomLeftOut
    //    case BottomLeftIn
    case LeftOut
    case LeftIn
    //    case TopLeftOut
    //    case TopLeftIn
}
enum Animation {
    case Calm
    case Gooey
}

typealias Vectors = (CGVector, CGVector, CGVector, CGVector)
typealias GooAnimation = (CAAnimation, Vectors)

class GooeyLayer: CALayer, CAAnimationDelegate{
    
    override init(layer _layer: Any) {
        
        if let layer = _layer as? GooeyLayer{
            self.nextVectors = layer.nextVectors
            self.color = layer.color
            self.currentVectors = layer.currentVectors
            self.insets = layer.insets
            //            self.center = (layer as GooeyLayer).center
        } else{
            nextVectors = VectorsFunc.zero()
            self.color = UIColor.red.cgColor
            self.currentVectors = VectorsFunc.zero()
            //            self.center = CGPointZero
        }
        super.init(layer: _layer)
    }
    
    override init() {
        
        self.nextVectors = VectorsFunc.zero()
        self.currentVectors = VectorsFunc.zero()
        //        self.center = CGPointZero
        super.init()
        
    }
    required init(coder aDecoder: NSCoder) {
        
        self.nextVectors = VectorsFunc.zero()
        self.currentVectors = VectorsFunc.zero()
        //        self.center = CGPointZero
        super.init(coder: aDecoder)!
    }
    
    
    @NSManaged var xpercent : CGFloat
    
    private var currentVectors : Vectors
    private var nextVectors : Vectors
    private var animationQueue : [GooAnimation] = [GooAnimation]()
    
    var animating = false
    let size : CGFloat = 30
    var insets : CGFloat?
    var color : CGColor?
    var damping : Double = 0.2
    var velocity : Double = 2.5
    //    var center : CGPoint {
    //        didSet{
    //            frame = CGRect(x: center.x - self.frame.size.width/2, y: center.y - self.frame.size.height/2, width: self.frame.size.width, height: self.frame.size.height)
    //        }
    //    }
    
    override var frame : CGRect{
        didSet{
            insets = (frame.size.width-size)/2
        }
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if (key == "xpercent") {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    func vectorsForDirection(d : Direction) -> Vectors{
        switch d{
        case Direction.Back:
            return backVectors()
            
        case Direction.LeftOut:
            return leftOutVectors()
            
        case Direction.LeftIn:
            return leftInVectors()
            
        case Direction.RightOut:
            return rightOutVectors()
            
        case Direction.RightIn:
            return rightInVectors()
            //        default :
            //            return VectorsFunc.zero()
        }
    }
    
    func backVectors()->Vectors{
        return VectorsFunc.zero()
    }
    
    func leftOutVectors() -> Vectors{
        return (
            CGVector(dx: 0, dy: 5),
            CGVector(dx: 0, dy: 0),
            CGVector(dx: 0, dy: -5),
            CGVector(dx: -15, dy: 0))
    }
    func leftInVectors() -> Vectors{
        return (
            CGVector(dx: 0, dy: -2),
            CGVector(dx: 2, dy: 0),
            CGVector(dx: 0, dy: 2),
            CGVector(dx: 5, dy: 0))
    }
    func rightOutVectors() -> Vectors{
        return (
            CGVector(dx: 0, dy: 5),
            CGVector(dx: 15, dy: 0),
            CGVector(dx: 0, dy: -5),
            CGVector(dx: 0, dy: 0))
    }
    func rightInVectors() -> Vectors{
        return (
            CGVector(dx: 0, dy: -2),
            CGVector(dx: -5, dy: 0),
            CGVector(dx: 0, dy: 2),
            CGVector(dx: -2, dy: 0))
    }
    
    
    func getAnimation(duration : CFTimeInterval, direction : Direction, type : Animation)-> GooAnimation{
        var ani : CAAnimation?
        if type == Animation.Calm{
            ani = SpringAnimation.create(keypath: "xpercent", duration: duration, fromValue: Double(0.0) as AnyObject, toValue: Double(1.0) as AnyObject)
            
        } else{
            ani = SpringAnimation.createSpring(keypath: "xpercent", duration: duration, usingSpringWithDamping: damping, initialSpringVelocity: velocity, fromValue: 0.0, toValue: 1.0)
        }
        return (ani!, vectorsForDirection(d: direction))
    }
    
    func animateGroup(as_ : [GooAnimation]){
        animationQueue.removeAll(keepingCapacity: false)
        animationQueue = as_
        
        if(self.animation(forKey: "animation eeoo") != nil){
            self.removeAllAnimations()
        } else {
            applyNexAnimation()
        }
    }
    
    func doneAnimating(){
        //        println("Done animating")
        self.animating = false
        self.xpercent = 0.0
        self.currentVectors = self.nextVectors
        self.nextVectors = VectorsFunc.zero()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        doneAnimating()
        applyNexAnimation()
    }
    
    func applyNexAnimation(){
        if animationQueue.count == 0 {  return  }
        
        let gooani = animationQueue.first
        animationQueue.remove(at: 0)
        
        self.nextVectors = gooani!.1
        self.xpercent = 1.0
        self.animating = true
        gooani!.0.delegate = self
        
        self.add(gooani!.0, forKey: "animation eeoo")
    }
    
    
    func setPullForce(force : CGFloat){
        self.removeAllAnimations()
        let vectors = force > 0 ? rightOutVectors() : leftOutVectors()
        self.currentVectors = VectorsFunc.multConst(v1: vectors, k: abs(force))
    }
    
    override func draw(in ctx: CGContext) {
        //        let insets_ = insets == nil ? 0 : insets!
        let rect = CGRect(x: self.frame.size.width/2 - size/2, y: self.frame.size.height/2 - size/2, width: size, height: size)
        let curve : CGFloat = rect.size.width/3.6
        
        var d = self.currentVectors
        var next = self.nextVectors
        
        d = VectorsFunc.multConst(v1: d, k: 1 - xpercent)
        next = VectorsFunc.multConst(v1: next, k: xpercent)
        d = VectorsFunc.plus(v1: d, v2: next)
        
        ctx.addPath(circleDistortPath(rect: rect, curve: curve,
                                      d1: d.0,
                                      d2: d.1,
                                      d3: d.2,
                                      d4: d.3))
        //        CGContextAddPath(ctx, circleDistortPath(rect, curve: curve,
        //            d1: d.0,
        //            d2: d.1,
        //            d3: d.2,
        //            d4: d.3))
        ctx.setFillColor(self.color!);
        
        ctx.fillPath();
    }
    
    
    func currentCirclePath()->CGMutablePath{
        let rect = CGRect(x: self.frame.size.width/2 - size/2, y: self.frame.size.height/2 - size/2, width: size, height: size)
        let curve : CGFloat = rect.size.width/3.6
        return circleDistortPath(rect: rect, curve: curve, d1: currentVectors.0, d2: currentVectors.1, d3: currentVectors.2, d4: currentVectors.3)
    }
    
    func circleDistortPath(rect : CGRect, curve : CGFloat, d1 : CGVector, d2 : CGVector, d3 : CGVector, d4 : CGVector)->CGMutablePath{
        
        return GooeyLayer.circlePath(rect: rect, curve: curve, vs: (
            CGVector(dx:d1.dx, dy:d1.dy),
            CGVector(dx:d2.dx, dy:d2.dy),
            CGVector(dx:d3.dx, dy:d3.dy),
            CGVector(dx:d4.dx, dy:d4.dy)))
    }
    
    
    class func circlePath(rect : CGRect, curve : CGFloat, vs : Vectors) -> CGMutablePath{
        let path = CGMutablePath()
        
        let x1 : CGFloat = ((rect.size.width)/2) + vs.0.dx     + rect.origin.x
        let y1 : CGFloat = (0 + vs.0.dy)                       + rect.origin.y
        
        let x2 : CGFloat = (rect.size.width) + vs.1.dx         + rect.origin.x
        let y2 : CGFloat = ((rect.size.height)/2) + vs.1.dy    + rect.origin.y
        
        let x3 : CGFloat = ((rect.size.width)/2) + vs.2.dx     + rect.origin.x
        let y3 : CGFloat = (rect.size.height) + vs.2.dy        + rect.origin.y
        
        let x4 : CGFloat = (0 + vs.3.dx)                       + rect.origin.x
        let y4 : CGFloat = ((rect.size.height)/2) + vs.3.dy    + rect.origin.y
        
        
        path.move(to: CGPoint(x: x1, y: y1))
        path.addCurve(
            to:         CGPoint(x:x2,           y:y2),
            control1:   CGPoint(x:x1+curve,     y:y1),
            control2:   CGPoint(x:x2,           y:y2 - curve))
        
        path.addCurve(
            to:         CGPoint(x:x3,           y:y3),
            control1:   CGPoint(x:x2,           y:y2 + curve),
            control2:   CGPoint(x:x3 + curve,   y:y3))
        
        path.addCurve(
            to:         CGPoint(x:x4,           y:y4),
            control1:   CGPoint(x:x3 - curve,   y:y3),
            control2:   CGPoint(x:x4,           y:y4 + curve))
        
        path.addCurve(
            to:         CGPoint(x:x1,           y:y1),
            control1:   CGPoint(x:x4,           y:y4 - curve),
            control2:   CGPoint(x:x1 - curve,   y:y1))
        
        path.closeSubpath()
        
        //        CGPathMoveToPoint(path, nil, x1, y1)
        //        CGPathAddCurveToPoint(path, nil,
        //            x1 + curve, y1,
        //            x2, y2 - curve,
        //            x2, y2)
        
        //        CGPathAddCurveToPoint(path, nil,
        //            x2, y2 + curve,
        //            x3 + curve, y3,
        //            x3, y3)
        
        //        CGPathAddCurveToPoint(path, nil,
        //            x3 - curve, y3,
        //            x4, y4 + curve,
        //            x4, y4)
        
        //        CGPathAddCurveToPoint(path, nil,
        //            x4, y4 - curve,
        //            x1 - curve, y1,
        //            x1, y1)
        //        CGPathCloseSubpath(path)
        return path
    }
}

