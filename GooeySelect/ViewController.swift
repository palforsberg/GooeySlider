//
//  ViewController.swift
//  GooeySelect
//
//  Created by Pål Forsberg on 2015-03-16.
//  Copyright (c) 2015 Pål Forsberg. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GooeySelectDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let select = GooeySelect(frame: CGRect(x: 20, y: 400, width: 280, height: 50))
        select.delegate = self
        select.color = UIColor.redColor()
        select.showProgessLine = true
        select.numberOfOptions = 5

        self.view.addSubview(select)
    }

    func gooeySelectDidSelect(gs: GooeySelect, index: Int) {
        println("Did select \(index)")
    }

}

