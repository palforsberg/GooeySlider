//
//  GooeySlider.swift
//  GooeySlider
//
//  Created by Pål Forsberg on 2015-03-17.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import UIKit

protocol GooeySliderDelegate{
    func gooeySliderDidSelect(gs : GooeySlider, index : Int)
}
class GooeySlider: UIView, GooeyViewDelegate {
    private var gooey = GooeyView(frame: CGRect(x: 0, y:0, width: 100, height: 44))
    private var l = LineLayer()
    var delegate : GooeySliderDelegate?
    
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
    var color : UIColor = UIColor.red {
        didSet{
            gooey.gooey.color = color.cgColor
            l.selectedColor = color.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initilize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initilize()
    }
    
    func initilize(){
        // Do any additional setup after loading the view, typically from a nib.
        l.frame = CGRect(x:gooey.gooey.size/2, y:0, width:frame.size.width - gooey.gooey.size, height: frame.size.height)
        l.contentsScale = UIScreen.main.scale
        l.setNeedsDisplay()
        l.nrOfChoices = 3
        l.showProgressLine = false
        self.layer.addSublayer(l)
        
        gooey.center = CGPoint(x: l.frame.origin.x + 5, y: l.frame.origin.y + l.frame.size.height/2)
        gooey.delegate = self
        self.addSubview(gooey)
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tapper)
    }
    
    func tapped(_ tapper : UITapGestureRecognizer){
        let location = tapper.location(in: self)
        
        if(l.frame.contains(location)){
            let p = nearestBall(location: location)
            gooey.animateTo(xpos: p.0)
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
            i += 1
        }
        return (nearest + l.frame.origin.x + gooey.gooey.size/6,smallestIndex)
    }
    
    func gooeyViewWantsNearestBallTo(point: CGPoint) -> CGPoint {
        return CGPoint(x: nearestBall(location: point).0, y: gooey.center.y)
    }
    
    func gooeyViewChangedPosition(gv: GooeyView) {
        l.selectedLineLength = gv.center.x - l.frame.origin.x
        l.setNeedsDisplay()
    }
    
    func gooeyViewWillAnimateTo(xpos: CGFloat) {
        l.animateLineLengthTo(newLength: xpos - l.frame.origin.x)
    }
    
    func gooeyViewDidMove(gv: GooeyView) {
        let (_, index) = nearestBall(location: gv.center)
        self.delegate?.gooeySliderDidSelect(gs: self, index: index)
    }
}
