//
//  ViewController.swift
//  FYLive
//
//  Created by 飞亦 on 3/22/20.
//  Copyright © 2020 COB. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var watchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func living(_ sender: UIButton) {
        self.navigationController?.pushViewController(FYLiveViewController(), animated: true)
    }
    @IBAction func watching(_ sender: UIButton) {
        self.navigationController?.pushViewController(FYPlayerViewController(), animated: true)
    }
}
