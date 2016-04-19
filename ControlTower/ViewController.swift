//
//  ViewController.swift
//  ControlTower
//
//  Created by Nate Bird on 4/19/16.
//  Copyright © 2016 Birdhouse. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let domesticFlight = Flight(type: DomesticAirlineType.Southwest)
        print(domesticFlight.requestLandingInstructions())
        
        let internationFlight = Flight(type: InternationAirlineType.AirFrance)
        print(internationFlight.requestLandingInstructions())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

