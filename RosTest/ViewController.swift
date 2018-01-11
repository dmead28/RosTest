//
//  ViewController.swift
//  RosTest
//
//  Created by Doug Mead on 1/9/18.
//  Copyright © 2018 Doug Mead. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        RealmManager.setupAllRealms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

