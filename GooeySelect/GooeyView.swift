//
//  GooeyView.swift
//  GooeySelect
//
//  Created by Pål Forsberg on 2015-03-16.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import UIKit

enum DragState {
    case Snapped
    case Unsnapped
}
protocol GooeyViewDelegate {
    func gooeyViewWantsNearestBallTo(point : CGPoint)-> CGPoint
    func gooeyViewChangedPosition(gv : GooeyView)
    func gooeyViewWillAnimateTo(xpos : CGFloat)
    func gooeyViewDidMove(gv : GooeyView)
}

class GooeyView: UIView, UIGestureRecognizerDelegate {
    var gooey = GooeyLayer()
    let duration = 0.2
    var animatin = false
    var dragState : DragState = DragState.Unsnapped
    var delegate : GooeyViewDelegate?
    
    override init(frame: CGRect) {
        gooey.frame = CGRect(origin: CGPointZero, size: frame.size)
        gooey.contentsScale = UIScreen.mainScreen().scale
        gooey.setNeedsDisplay()
        gooey.backgroundColor = UIColor.clearColor().CGColor
        gooey.color = UIColor.redColor().CGColor
        gooey.damping = 0.8
        gooey.velocity = 3.0
        
        super.init(frame: frame)
        self.layer.addSublayer(gooey)
        
        let panner = UIPanGestureRecognizer(target: self, action: "panned:")
        panner.delegate = self
        self.addGestureRecognizer(panner)
    }

    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return !self.animatin
    }
    
    func panned(panner : UIPanGestureRecognizer){
        let translation = panner.translationInView(self)
        let location = panner.locationInView(self)
        let dist = location.x - (gooey.frame.origin.x + gooey.frame.size.width/2)
        if panner.state == UIGestureRecognizerState.Began {
            
        } else if panner.state == UIGestureRecognizerState.Changed {
            if self.animatin == true {
                return
            }
            if abs(dist) < 40 && dragState == DragState.Unsnapped {
                gooey.setPullForce(dist * 0.04)
                gooey.setNeedsDisplay()
                
            } else if dragState == DragState.Unsnapped{
                
                let mult = abs(dist * 0.04)
                let d1 = (dist > 0 ? Direction.LeftOut : Direction.RightOut)
                
                let a1 = gooey.getAnimation(duration, direction: d1, type: Animation.Calm)
                let a3 = gooey.getAnimation(duration * 5, direction: Direction.Back, type: Animation.Gooey)
                
                gooey.animateGroup([a1, a3])
                animateCenter2(location.x + self.frame.origin.x)
                dragState = DragState.Snapped
                
            } else if dragState == DragState.Snapped{
                if(!animatin){
                    self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y)
                    self.delegate?.gooeyViewChangedPosition(self)
                }
            }
            
        } else if panner.state == UIGestureRecognizerState.Ended || panner.state == UIGestureRecognizerState.Cancelled {
            if dragState == DragState.Unsnapped {
                let a1 = gooey.getAnimation(1.0, direction: Direction.Back, type: Animation.Gooey)
                gooey.animateGroup([a1])
            } else {
                let p = self.delegate?.gooeyViewWantsNearestBallTo(self.center)
                if let p1 = p {
                    animateTo(p1.x)
                }
            }
            dragState = DragState.Unsnapped
        }

        panner.setTranslation(CGPointZero, inView: self)
    }

    func animateTo(xpos : CGFloat){
        
        let currentCenterX = self.center.x
        animateCenter(xpos)
        let dist = xpos - currentCenterX
        if dist > 0{
            animateRight(dist)
        } else{
            animateLeft(dist)
        }
    }
    
    func animateCenter(xpos : CGFloat){
        self.animatin = true
        self.delegate?.gooeyViewWillAnimateTo(xpos)
        UIView.animateWithDuration(duration,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                self.center = CGPoint(x: xpos, y: self.center.y)
            }) { (ended) -> Void in
                self.animatin = false
                self.delegate?.gooeyViewDidMove(self)
        }
    }
    
    func animateCenter2(xpos : CGFloat){
        self.animatin = true
        self.delegate?.gooeyViewWillAnimateTo(xpos)
        UIView.animateWithDuration(duration,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                self.center = CGPoint(x: xpos, y: self.center.y)
            }) { (ended) -> Void in
                self.animatin = false
        }
    }
    
    func animateRight(dist : CGFloat){
        animateGooey(abs(dist/120), d1: Direction.LeftOut)
    }
    func animateLeft(dist : CGFloat){
        animateGooey(abs(dist/120), d1: Direction.RightOut)
    }
    
    func animateGooey(mult : CGFloat, d1 : Direction){
    
        var a1 = gooey.getAnimation(duration, direction: d1, type: Animation.Calm)
        let a3 = gooey.getAnimation(duration * 5, direction: Direction.Back, type: Animation.Gooey)
        
        a1.1 = VectorsFunc.multConst(a1.1, k: mult)
        
        gooey.animateGroup([a1, a3])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
