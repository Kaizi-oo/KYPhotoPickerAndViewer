//
//  ViewController.swift
//  KYPhotoPickerAndViewer
//
//  Created by kyang on 2017/12/28.
//  Copyright © 2017年 kyang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let nineView = KYSquaredPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.size.width, height: view.frame.size.width))
        
        
        view.addSubview(nineView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

