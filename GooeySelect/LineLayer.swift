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
    var color : CGColor = UIColor(white: 0.9, alpha: 1.0).cgColor
    var selectedColor : CGColor
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
            ballCenters.removeAll(keepingCapacity: false)
            nrOfChoices -= 1
            for i in 0...nrOfChoices{
                ballCenters.append(ballSize/2 + (self.frame.size.width - ballSize) * CGFloat(i)/CGFloat(nrOfChoices) - ballSize/2)
            }
        }
    }
    
    override init() {
        self.ballCenters = [0, 120, 230]
        self.selectedItem = 1
        self.selectedLineLength = 0
        self.nrOfChoices = 3
        self.showProgressLine = false
        self.selectedColor = UIColor.red.cgColor
        super.init()
    }
    
    
    override init(layer _layer: Any) {
        let layer = _layer as AnyObject
        
        self.nrOfChoices = layer.nrOfChoices
        self.selectedItem = layer.selectedItem
        self.ballCenters = layer.ballCenters
        self.nrOfChoices = layer.nrOfChoices
        self.selectedLineLength = layer.selectedLineLength
        self.showProgressLine = layer.showProgressLine
        self.selectedColor = layer.selectedColor
        
        super.init(layer: _layer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if (key == "selectedLineLength") {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    func animateLineLengthTo(newLength : CGFloat){
        let ani = SpringAnimation.create(keypath: "selectedLineLength", duration: 0.2, fromValue: selectedLineLength as AnyObject, toValue: newLength as AnyObject)
        ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        selectedLineLength = newLength
        self.add(ani, forKey: "eeoo")
    }
    
    override func draw(in ctx: CGContext) {
        var path = CGMutablePath()
        
        
        
        path = linePath(length: self.frame.size.width, height:lineWidth, path: path)
        
        for i in 0 ... ballCenters.count-1{
            let v = ballCenters[i]
            path = addCircle(path: path, xpos: v)
        }
        
        ctx.addPath(path)
        ctx.setFillColor(color)
        ctx.fillPath()
        
        
        if showProgressLine {
            ctx.beginPath()
            path = CGMutablePath()
            path = linePath(length: selectedLineLength, height:lineWidth, path: path)
            
            for i in 0 ... ballCenters.count-1{
                let v = ballCenters[i]
                if v < selectedLineLength {
                    path = addCircle(path: path, xpos: v)
                }
            }
            ctx.addPath(path)
            ctx.setFillColor(selectedColor)
            ctx.fillPath()
        }
    }
    
    func MIN(v1 : CGFloat, v2 : CGFloat)->CGFloat{
        return v1 < v2 ? v1 : v2;
    }
    func linePath(length : CGFloat, height : CGFloat, path : CGMutablePath) -> CGMutablePath{
        
        
        path.move(to: CGPoint(x:0, y:self.frame.size.height/2))
        path.addRoundedRect(in: CGRect(x: 0, y: self.frame.size.height/2 - height/2, width: length, height: height), cornerWidth: 0, cornerHeight:  height/2)
        //        CGPathAddLineToPoint(path, nil, self.frame.size.width, self.frame.size.height/2)
        //        path.__addRoundedRect(transform: nil, rect: CGRect(x: 0, y: self.frame.size.height/2 - height/2, width: length, height: height), cornerWidth: 0, cornerHeight: height/2)
        return path
    }
    
    func addCircle(path : CGMutablePath, xpos : CGFloat) -> CGMutablePath{
        //        CGPathMoveToPoint(path, nil, xpos, self.frame.size.height/2)
        path.addEllipse(in: CGRect(x: xpos, y: self.frame.size.height/2 - ballSize/2, width: ballSize, height: ballSize))
        //        CGPathAddEllipseInRect(path, nil, CGRect(x: xpos, y: self.frame.size.height/2 - ballSize/2, width: ballSize, height: ballSize))
        return path
    }
}
