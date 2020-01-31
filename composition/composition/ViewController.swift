//
//  ViewController.swift
//  composition
//
//  Created by Jijo Pulikkottil on 31/01/20.
//  Copyright © 2020 sample. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let path = Bundle.main.path(forResource: "IMG-5718", ofType:"MOV")
        let fileURL = URL(fileURLWithPath: path!)
        
        VideoOvelay().addOverlayText("JJ1", fileURL: fileURL, position: VideoOvelayPosition.bottomLeft) { (err) in
            print("err = \(String(describing: err))")
            DispatchQueue.main.async {
                self.view.backgroundColor = UIColor.green
            }
            
        }
    }


}

