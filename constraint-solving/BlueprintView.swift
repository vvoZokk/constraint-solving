//
//  BlueprintView.swift
//  constraint-solving
//
//  Created by vvoZokk on 17.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Cocoa

class BlueprintView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.layer?.backgroundColor = NSColor.blue.cgColor
        
    }
    
    override func mouseDown(with event: NSEvent) {
        self.display()
    }

}
