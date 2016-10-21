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
        gooey.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        gooey.contentsScale = UIScreen.main.scale
        gooey.setNeedsDisplay()
        gooey.backgroundColor = UIColor.clear.cgColor
        gooey.color = UIColor.red.cgColor
        gooey.damping = 0.8
        gooey.velocity = 3.0
        
        super.init(frame: frame)
        self.layer.addSublayer(gooey)
        
        let panner = UIPanGestureRecognizer(target: self, action: #selector(panned))
        panner.delegate = self
        self.addGestureRecognizer(panner)
    }
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !self.animatin
    }
    
    func panned(_ panner : UIPanGestureRecognizer){
        let translation = panner.translation(in: self)
        let location = panner.location(in: self)
        let dist = location.x - (gooey.frame.origin.x + gooey.frame.size.width/2)
        if panner.state == .began {
            
        } else if panner.state == .changed {
            if self.animatin == true {
                return
            }
            if abs(dist) < 40 && dragState == DragState.Unsnapped {
                gooey.setPullForce(force:dist * 0.04)
                gooey.setNeedsDisplay()
                
            } else if dragState == DragState.Unsnapped{
                
                //                let mult = abs(dist * 0.04)
                let d1 = (dist > 0 ? Direction.LeftOut : Direction.RightOut)
                
                let a1 = gooey.getAnimation(duration: duration, direction: d1, type: Animation.Calm)
                let a3 = gooey.getAnimation(duration: duration * 5, direction: Direction.Back, type: Animation.Gooey)
                
                gooey.animateGroup(as_: [a1, a3])
                animateCenter2(xpos: location.x + self.frame.origin.x)
                dragState = DragState.Snapped
                
            } else if dragState == DragState.Snapped{
                self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y)
                self.delegate?.gooeyViewChangedPosition(gv: self)
            }
            
        } else if panner.state == .ended || panner.state == .cancelled {
            if dragState == DragState.Unsnapped {
                let a1 = gooey.getAnimation(duration: 1.0, direction: Direction.Back, type: Animation.Gooey)
                gooey.animateGroup(as_: [a1])
            } else {
                let p = self.delegate?.gooeyViewWantsNearestBallTo(point: self.center)
                if let p1 = p {
                    animateTo(xpos: p1.x)
                }
            }
            dragState = DragState.Unsnapped
        }
        
        panner.setTranslation(CGPoint.zero, in: self)
    }
    
    func animateTo(xpos : CGFloat){
        
        let currentCenterX = self.center.x
        animateCenter(xpos: xpos)
        let dist = xpos - currentCenterX
        if dist > 0{
            animateRight(dist: dist)
        } else{
            animateLeft(dist: dist)
        }
    }
    
    func animateCenter(xpos : CGFloat){
        self.animatin = true
        self.delegate?.gooeyViewWillAnimateTo(xpos: xpos)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseIn],
                       animations: { () -> Void in
                        self.center = CGPoint(x: xpos, y: self.center.y)
        }) { (ended) -> Void in
            if ended {
                self.animatin = false
                self.delegate?.gooeyViewDidMove(gv: self)
            }
        }
    }
    
    func animateCenter2(xpos : CGFloat){
        if !self.animatin {
            self.animatin = true
            self.delegate?.gooeyViewWillAnimateTo(xpos: xpos)
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: .curveEaseIn,
                           animations: { () -> Void in
                            self.center = CGPoint(x: xpos, y: self.center.y)
            }) { (ended) -> Void in
                if ended {
                    self.animatin = false
                }
            }
        }
    }
    
    func animateRight(dist : CGFloat){
        animateGooey(mult: abs(dist/120), d1: Direction.LeftOut)
    }
    func animateLeft(dist : CGFloat){
        animateGooey(mult: abs(dist/120), d1: Direction.RightOut)
    }
    
    func animateGooey(mult : CGFloat, d1 : Direction){
        
        var a1 = gooey.getAnimation(duration: duration, direction: d1, type: Animation.Calm)
        let a3 = gooey.getAnimation(duration: duration * 5, direction: Direction.Back, type: Animation.Gooey)
        
        a1.1 = VectorsFunc.multConst(v1: a1.1, k: mult)
        
        gooey.animateGroup(as_: [a1, a3])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
