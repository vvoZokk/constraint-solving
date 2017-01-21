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
    var blueprint = Blueprint()

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: BlueprintView! {
        didSet {
            view.controller = blueprint
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func test(_ sender: AnyObject) {
        let myPoint = Point2D()
        do {
            try myPoint.setPosition(parameters: [0.8, 0.6, 5, 0])

            blueprint.calculatePositions()
            print(myPoint.vectorX)
            print("calculation")
        } catch {
            print("catching error")
        }
    }
}
