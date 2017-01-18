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
        do {
            let myPoint = Point2D()
            print("test here: \(myPoint.vectorX)")
            try myPoint.newPosition(parameter: 3, direction: [0.8, 0.6])
            print("second test here:\(myPoint.vectorA), \(myPoint.p)")
        } catch {
            print("catch error")
        }
        
    }
 
}

