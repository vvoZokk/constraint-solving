//
//  BlueprintView.swift
//  constraint-solving
//
//  Created by vvoZokk on 17.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Cocoa

class BlueprintView: NSView {

    enum ViewMode {
        case none
        case move
        case addNewPoint
        case addNewConstX
        case addNewConstY
    }

    let radius = 3.0
    let threshold = 2.0
    @IBOutlet weak var output: NSTextField!
    @IBOutlet weak var input: NSTextField!
    @IBOutlet weak var newPointButton: NSButton!
    @IBOutlet weak var fixXButton: NSButton!
    @IBOutlet weak var fixYButton: NSButton!
    weak var controller: Blueprint?
    var mode = ViewMode.none
    var lastPosition = NSPoint()
    var position = NSPoint()
    var objects = Dictionary<Int, (type: ObjectType, [Double])>()
    var selected = Set<Int>()

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let backgroundColor = NSColor.init(red: 0.15, green: 0.25, blue: 0.35, alpha: 1)
        let mainColor = NSColor.init(red: 0.7, green: 0.9, blue: 0.9, alpha: 1)
        var borderColor = NSColor.init(red: 0.1, green: 0.1, blue: 0.2, alpha: 1)
        backgroundColor.setFill()
        borderColor.setStroke()
        NSRectFill(dirtyRect)
        NSRectClip(dirtyRect)
        var path = NSBezierPath()
        path.lineWidth = 4
        path.move(to: dirtyRect.origin)
        path.line(to: NSPoint(x: dirtyRect.origin.x, y: dirtyRect.height))
        path.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.height))
        path.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.origin.y))
        path.line(to: dirtyRect.origin)
        path.stroke()
        borderColor = NSColor.init(red: 0.9, green: 0.9, blue: 0.3, alpha: 1)
        mainColor.setFill()
        borderColor.setStroke()
        for o in objects {
            let (type, c) = o.value
            switch type {
            case .point2D:
                let square = NSRect(x: c[0] - radius, y: c[1] - radius, width: 2 * radius, height: 2 * radius)
                path = NSBezierPath(ovalIn: square)
                path.fill()
                if selected.contains(o.key) {
                    path.lineWidth = CGFloat(radius)
                    path.stroke()
                }
            default:
                break
            }
        }
        switch mode {
        case .move:
            path.lineWidth = 1
            path.move(to: lastPosition)
            path.line(to: position)
            path.stroke()
        default:
            break
        }
    }

    override func mouseDown(with event: NSEvent) {
        let pos = self.convert(event.locationInWindow, from: nil)
        lastPosition = pos
        output.stringValue = String(format: "Status: last position (%.2f; %.2f)", pos.x, pos.y)
        switch mode {
        case .none:
            for o in objects {
                let (type, x) = o.value
                switch type {
                case .point2D:
                    let lenght = pow(x[0] - Double(pos.x), 2) + pow(x[1] - Double(pos.y), 2)
                    if sqrt(lenght) < threshold * radius {
                        if selected.contains(o.key) {
                            selected.remove(o.key)
                            output.stringValue = "Status: point #\(o.key) unselected"
                        } else{
                            selected.insert(o.key)
                            output.stringValue = "Status: point #\(o.key) selected"
                        }
                        self.needsDisplay = true
                    }
                default:
                    break
                }
            }
        case .addNewPoint:
            let point = Point2D()
            point.setCoordinates(x: Double(pos.x), y: Double(pos.y))
            if controller != nil {
                mode = .none
                controller!.add(object: point)
                if let status = controller!.calculatePositions() {
                    output.stringValue = "String: " + status
                } else {
                    output.stringValue = String(format: "Status: added new point, X = %.2f Y = %.2f", pos.x, pos.y)
                }
                objects = controller!.getDisplayedObjects()
                newPointButton.setNextState()
                self.needsDisplay = true
            } else {
                output.stringValue = "Status: controler fault"
            }
        default:
            break
        }
    }

    override func mouseDragged(with event: NSEvent) {
        switch mode {
        case .none:
            if !selected.isEmpty {
                position = self.convert(event.locationInWindow, from: nil)
                let r = CGFloat(radius)
                if fabs(position.x - lastPosition.x) > r || fabs(position.y - lastPosition.y) > r {
                    mode = .move
                    output.stringValue = "Status: move"
                }
            }
        case .move:
            position = self.convert(event.locationInWindow, from: nil)
            self.needsDisplay = true
        default:
            break
        }
    }

    override func mouseUp(with event: NSEvent) {
        switch mode {
        case .move:
            let pos = self.convert(event.locationInWindow, from: nil)
            if controller != nil {
                mode = .none
                for id in selected {
                    if objects[id] != nil {
                        var (type, c) = objects[id]!
                        switch type {
                        case .point2D:
                            c[0] += Double(pos.x - lastPosition.x)
                            c[1] += Double(pos.y - lastPosition.y)
                            if let status = controller!.setCoordinates(to: id, coordinates: c) {
                                output.stringValue = "Status: " + status
                            }
                        default:
                            break
                        }
                    } else {
                        output.stringValue = "Status: object #\(id) not exist"
                    }
                }
                if let status = controller!.calculatePositions() {
                    output.stringValue = "String: " + status
                } else {
                    output.stringValue = "Status:"
                }
                objects = controller!.getDisplayedObjects()
                self.needsDisplay = true
            } else {
                output.stringValue = "Status: controler fault"
            }
        default:
            break
        }
    }

    @IBAction func newPointButtonClick(_ sender: AnyObject) {
        switch mode {
        case .none:
            output.stringValue = "Status: select position"
            mode = .addNewPoint
        case .addNewPoint:
            output.stringValue = "Status: aborted"
            mode = .none
        default:
            break
        }
    }

    @IBAction func fixXButtonClick(_ sender: AnyObject) {
        switch mode {
        case .none:
            if objects.isEmpty {
                output.stringValue = "Status: before draw objects"
                fixXButton.setNextState()
            } else {
                if selected.isEmpty {
                    output.stringValue = "Status: before select objects"
                    fixXButton.setNextState()
                } else {
                    output.stringValue = "Status: enter X value"
                    mode = .addNewConstX
                    input.isEnabled = true
                    input.becomeFirstResponder()
                }
            }
        case .addNewConstX:
            output.stringValue = "Status: aborted"
            mode = .none
        default:
            fixXButton.setNextState()
        }
    }

    @IBAction func fixYButtonClick(_ sender: AnyObject) {
        switch mode {
        case .none:
            if objects.isEmpty {
                output.stringValue = "Status: before draw objects"
                fixYButton.setNextState()
            } else {
                if selected.isEmpty {
                    output.stringValue = "Status: before select objects"
                    fixYButton.setNextState()
                } else {
                    output.stringValue = "Status: enter Y value"
                    mode = .addNewConstY
                    input.isEnabled = true
                    input.becomeFirstResponder()
                }
            }
        case .addNewConstY:
            output.stringValue = "Status: aborted"
            mode = .none
        default:
            fixYButton.setNextState()
        }
    }

    @IBAction func inputValue(_ sender: AnyObject) {
        switch mode {
        case .addNewConstX, .addNewConstY:
            let value = sender.doubleValue
            if value != nil && controller != nil {
                let const = Constraint(type: .constX, value: value!, relation: nil)
                let index: Int
                if mode == .addNewConstX {
                    index = 0
                    fixXButton.setNextState()
                } else {
                    index = 1
                    fixYButton.setNextState()
                }
                for id in selected {
                    controller!.add(constraint: const, index: index, to: id)
                }
                mode = .none
                if let status = controller!.calculatePositions() {
                    output.stringValue = "Status: " + status
                } else {
                    output.stringValue = "Status: add constraint for \(selected.count) objects"
                }
                objects = controller!.getDisplayedObjects()
                input.stringValue = ""
                input.isEnabled = false
                selected.removeAll()
                self.needsDisplay = true
            } else {
                output.stringValue = "Status: controler fault"
            }
        default:
            break
        }
    }
}
