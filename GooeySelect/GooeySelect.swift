//
//  GooeySelect.swift
//  GooeySelect
//
//  Created by Pål Forsberg on 2015-03-17.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import UIKit

protocol GooeySelectDelegate{
    func gooeySelectDidSelect(gs : GooeySelect, index : Int)
}
class GooeySelect: UIView, GooeyViewDelegate {
    private var gooey = GooeyView(frame: CGRect(x: 0, y:0, width: 100, height: 44))
    private var l = LineLayer()
    var delegate : GooeySelectDelegate?
    
    var numberOfOptions : Int = 5 {
        didSet{
            l.nrOfChoices = numberOfOptions
        }
    }
    var showProgessLine : Bool = true {
        didSet{
            l.showProgressLine = showProgessLine
        }
    }
    var color : UIColor = UIColor.redColor() {
        didSet{
            gooey.gooey.color = color.CGColor
            l.selectedColor = color.CGColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Do any additional setup after loading the view, typically from a nib.
        l.frame = CGRect(x:gooey.gooey.size/2, y:0, width:frame.size.width - gooey.gooey.size, height: frame.size.height)
        l.contentsScale = UIScreen.mainScreen().scale
        l.setNeedsDisplay()
        l.nrOfChoices = 5
        l.showProgressLine = true
        self.layer.addSublayer(l)
        
        gooey.center = CGPoint(x: l.frame.origin.x + 5, y: l.frame.origin.y + l.frame.size.height/2)
        gooey.delegate = self
        self.addSubview(gooey)
        
        let tapper = UITapGestureRecognizer(target: self, action: "tapped:")
        self.addGestureRecognizer(tapper)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapped(tapper : UITapGestureRecognizer){
        let location = tapper.locationInView(self)
        
        if(CGRectContainsPoint(l.frame, location)){
            let p = nearestBall(location)
            gooey.animateTo(p.0)
        }
    }
    
    func nearestBall(location : CGPoint)->(CGFloat, Int){
        var smallestDist : CGFloat = 100
        var nearest : CGFloat = 0
        var smallestIndex = 0
        var i = 0
        for v in l.ballCenters{
            let dist = abs((v + l.frame.origin.x + gooey.gooey.size/6) - location.x)
            if dist < smallestDist{
                nearest = v
                smallestIndex = i
                smallestDist = abs((v + l.frame.origin.x) - location.x)
            }
            i++
        }
        return (nearest + l.frame.origin.x + gooey.gooey.size/6,smallestIndex)
    }
    
    func gooeyViewWantsNearestBallTo(point: CGPoint) -> CGPoint {
        return CGPoint(x: nearestBall(point).0, y: gooey.center.y)
    }
    
    func gooeyViewChangedPosition(gv: GooeyView) {
        l.selectedLineLength = gv.center.x - l.frame.origin.x
        l.setNeedsDisplay()
    }
    
    func gooeyViewWillAnimateTo(xpos: CGFloat) {
        l.animateLineLengthTo(xpos - l.frame.origin.x)
    }
    
    func gooeyViewDidMove(gv: GooeyView) {
        let (p, index) = nearestBall(gv.center)
        self.delegate?.gooeySelectDidSelect(self, index: index)
    }
}
