//
//  AppDelegate.swift
//  constraint-solving
//
//  Created by vvoZokk on 17.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var blueprintView: BlueprintView!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func test(_: AnyObject) {
        let myPoint = Point2D()
        let mySecPoint = Point2D()
        //let newP = Point2D()
        do {
            try myPoint.setPosition(parameters: [0.8, 0.6, 5, 0])
            try mySecPoint.setPosition(parameters: [0.6, 0.8, 5, 0])
            let simpleCon = Constraint()
            var con = Constraint()
            try con.changeType(type: ConstraintType.constX, value: -3.8, relation: nil)
            try simpleCon.changeType(type: ConstraintType.constX, value: 4.8, relation: nil)
            try myPoint.addConstraint(constraint: simpleCon, index: 0)
            try myPoint.addConstraint(constraint: con, index: 1)
            let blueprint = Blueprint()
            blueprint.add(object: myPoint)
            //blueprint.add(object: mySecPoint)
            //blueprint.add(object: newP)
            print(myPoint.vectorX)

            blueprint.calculatePositions()
            print(myPoint.vectorX)
            print("")
        } catch {
            print("catching error")
        }
    }
}
