//
//  ViewController.swift
//  DriveMetaDataDemo
//
//  Created by DriveMetaData on 31/03/24.
//

import UIKit
import DriveMetaDataiOSSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DriveMetaData.initialise(clientId: 1234, token: "Amit", appId: 564)
        //DriveMetaData.doSomething()
        // Do any additional setup after loading the view.
    }


}

