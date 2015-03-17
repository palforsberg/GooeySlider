//
//  LineLayer.swift
//  GooeySelect
//
//  Created by Pål Forsberg on 2015-03-16.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import UIKit

class LineLayer : CALayer {

    var ballSize : CGFloat = 10
    var lineWidth : CGFloat = 2
    var color : CGColorRef = UIColor(white: 0.9, alpha: 1.0).CGColor
    var selectedColor : CGColorRef
    var ballCenters : [CGFloat]
    var showProgressLine : Bool
    var selectedItem : Int{
        didSet{
            let s = ballCenters[selectedItem]
            selectedLineLength = s
        }
    }
    var selectedLineLength : CGFloat
    var nrOfChoices : Int{
        didSet{
            ballCenters.removeAll(keepCapacity: false)
            nrOfChoices--
            for i in 0...nrOfChoices{
                ballCenters.append(ballSize/2 + (self.frame.size.width - ballSize) * CGFloat(i)/CGFloat(nrOfChoices) - ballSize/2)
            }
        }
    }
    
    override init!() {
        self.ballCenters = [0, 120, 230]
        self.selectedItem = 1
        self.selectedLineLength = 0
        self.nrOfChoices = 3
        self.showProgressLine = false
        self.selectedColor = UIColor.redColor().CGColor
        super.init()
    }
    override init!(layer: AnyObject!) {
        self.nrOfChoices = layer.nrOfChoices
        self.selectedItem = layer.selectedItem
        self.ballCenters = layer.ballCenters
        self.nrOfChoices = layer.nrOfChoices
        self.selectedLineLength = layer.selectedLineLength
        self.showProgressLine = layer.showProgressLine
        self.selectedColor = layer.selectedColor
        super.init(layer: layer)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func needsDisplayForKey(key: String!) -> Bool {
        if (key == "selectedLineLength") {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    func animateLineLengthTo(newLength : CGFloat){
        let ani = SpringAnimation.create("selectedLineLength", duration: 0.2, fromValue: selectedLineLength, toValue: newLength)
        ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        selectedLineLength = newLength
        self.addAnimation(ani, forKey: "eeoo")
    }
    
    override func drawInContext(ctx: CGContext!) {
        var path = CGPathCreateMutable()



        path = linePath(self.frame.size.width, height:lineWidth, path: path)
        
        for i in 0 ... ballCenters.count-1{
            let v = ballCenters[i]
            path = addCircle(path, xpos: v)
        }
        
        CGContextAddPath(ctx, path)
        CGContextSetFillColorWithColor(ctx, color)
        CGContextFillPath(ctx)
        
        
        if showProgressLine {
            CGContextBeginPath(ctx)
            path = CGPathCreateMutable()
            path = linePath(selectedLineLength, height:lineWidth, path: path)
            
            for i in 0 ... ballCenters.count-1{
                let v = ballCenters[i]
                if v < selectedLineLength {
                    path = addCircle(path, xpos: v)
                }
            }
            CGContextAddPath(ctx, path)
            CGContextSetFillColorWithColor(ctx, selectedColor)
            CGContextFillPath(ctx)
        }
    }
    
    func MIN(v1 : CGFloat, v2 : CGFloat)->CGFloat{
        return v1 < v2 ? v1 : v2;
    }
    func linePath(length : CGFloat, height : CGFloat, path : CGMutablePathRef) -> CGMutablePathRef{
        
        CGPathMoveToPoint(path, nil, 0, self.frame.size.height/2)
//        CGPathAddLineToPoint(path, nil, self.frame.size.width, self.frame.size.height/2)
        CGPathAddRoundedRect(path, nil, CGRect(x: 0, y: self.frame.size.height/2 - height/2, width: length, height: height), 0, height/2)
        return path
    }
    
    func addCircle(path : CGMutablePathRef, xpos : CGFloat) -> CGMutablePathRef{
//        CGPathMoveToPoint(path, nil, xpos, self.frame.size.height/2)
        CGPathAddEllipseInRect(path, nil, CGRect(x: xpos, y: self.frame.size.height/2 - ballSize/2, width: ballSize, height: ballSize))
        return path
    }
}
