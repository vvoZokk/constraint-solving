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
        case addNewSLS0
        case addNewSLS
        case addNewConstX
        case addNewConstY
        case addNewConstP
    }

    let radius = 3.0
    let threshold = 2.0
    @IBOutlet weak var output: NSTextField!
    @IBOutlet weak var input: NSTextField!
    @IBOutlet weak var newPointButton: NSButton!
    @IBOutlet weak var newSLSButton: NSButton!
    @IBOutlet weak var fixXButton: NSButton!
    @IBOutlet weak var fixYButton: NSButton!
    @IBOutlet weak var fixLengthButton: NSButton!
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
        var path = NSBezierPath()
        backgroundColor.setFill()
        NSRectFill(dirtyRect)
        borderColor.setStroke()
        NSRectClip(dirtyRect)
        path.lineWidth = 4
        path.move(to: dirtyRect.origin)
        path.line(to: NSPoint(x: dirtyRect.origin.x, y: dirtyRect.height))
        path.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.height))
        path.line(to: NSPoint(x: dirtyRect.width, y: dirtyRect.origin.y))
        path.line(to: dirtyRect.origin)
        path.stroke()
        borderColor = NSColor.init(red: 0.9, green: 0.9, blue: 0.3, alpha: 1)
        mainColor.setFill()
        for o in objects {
            let (type, c) = o.value
            switch type {
            case .point2D:
                borderColor.setStroke()
                let square = NSRect(x: c[0] - radius, y: c[1] - radius, width: 2 * radius, height: 2 * radius)
                path = NSBezierPath(ovalIn: square)
                path.fill()
                if selected.contains(o.key) {
                    path.lineWidth = CGFloat(radius)
                    path.stroke()
                }
            case .straightLineSegment2D:
                if selected.contains(o.key) {
                    borderColor.setStroke()
                } else {
                    mainColor.setStroke()
                }
                path = NSBezierPath()
                path.lineWidth = CGFloat(radius)
                path.move(to: NSPoint(x: c[0], y: c[1]))
                path.line(to: NSPoint(x: c[2], y: c[3]))
                path.stroke()
                var square = NSRect(x: c[0] - radius / 2, y: c[1] - radius / 2, width: radius, height: radius)
                path = NSBezierPath(ovalIn: square)
                path.fill()
                if selected.contains(o.key) {
                    path.lineWidth = CGFloat(radius)
                    path.stroke()
                }
                square = NSRect(x: c[2] - radius / 2, y: c[3] - radius / 2, width: radius, height: radius)
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
            borderColor.setStroke()
            path = NSBezierPath()
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
                    let length = pow(x[0] - Double(pos.x), 2) + pow(x[1] - Double(pos.y), 2)
                    if sqrt(length) < threshold * radius {
                        if selected.contains(o.key) {
                            selected.remove(o.key)
                            output.stringValue = "Status: point #\(o.key) unselected"
                        } else{
                            selected.insert(o.key)
                            output.stringValue = "Status: point #\(o.key) selected"
                        }
                        self.needsDisplay = true
                    }
                case .straightLineSegment2D:
                    let begin = pow(x[0] - Double(pos.x), 2) + pow(x[1] - Double(pos.y), 2)
                    let end = pow(x[2] - Double(pos.x), 2) + pow(x[3] - Double(pos.y), 2)
                    if sqrt(begin) < threshold * radius || sqrt(end) < threshold * radius {
                        if selected.contains(o.key) {
                            selected.remove(o.key)
                            output.stringValue = "Status: line #\(o.key) unselected"
                        } else{
                            selected.insert(o.key)
                            output.stringValue = "Status: line #\(o.key) selected"
                        }
                        self.needsDisplay = true
                    }
                default:
                    break
                }
            }
        case .addNewPoint:
            let point = Point2D(x: Double(pos.x), y: Double(pos.y))
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
        case .addNewSLS0:
            position = pos
            output.stringValue = "Status: select second point position"
            mode = .addNewSLS
        case .addNewSLS:
            let lineSegment = StraightLineSegment2D(x0: Double(position.x), y0: Double(position.y), x1: Double(pos.x), y1: Double(pos.y))
            if controller != nil {
                mode = .none
                controller!.add(object: lineSegment)
                if let status = controller!.calculatePositions() {
                    output.stringValue = "String: " + status
                } else {
                    output.stringValue = "Status: added new line"
                }
                objects = controller!.getDisplayedObjects()
                newSLSButton.setNextState()
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
                        case .straightLineSegment2D:
                            //c[0] += Double(pos.x - lastPosition.x)
                            //c[1] += Double(pos.y - lastPosition.y)
                            c[2] += Double(pos.x - lastPosition.x)
                            c[3] += Double(pos.y - lastPosition.y)
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

    @IBAction func newSLSButtonClick(_ sender: AnyObject) {
        switch mode {
        case .none:
            output.stringValue = "Status: select first point position"
            mode = .addNewSLS0
        case .addNewSLS0, .addNewSLS:
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
            input.stringValue = ""
            input.isEnabled = false
        default:
            fixYButton.setNextState()
        }
    }

    @IBAction func fixLengthButtonClick(_ sender: AnyObject) {
        switch mode {
        case .none:
            if objects.isEmpty {
                output.stringValue = "Status: before draw line"
                fixLengthButton.setNextState()
            } else {
                if selected.isEmpty {
                    output.stringValue = "Status: before select lines"
                    fixLengthButton.setNextState()
                } else {
                    for id in selected {
                        if objects[id]?.type != .straightLineSegment2D {
                            output.stringValue = "Status: select only lines, please"
                            fixLengthButton.setNextState()
                            return
                        }
                    }
                    output.stringValue = "Status: enter length value"
                    mode = .addNewConstP
                    input.isEnabled = true
                    input.becomeFirstResponder()
                }
            }
        case .addNewConstP:
            output.stringValue = "Status: aborted"
            mode = .none
            input.stringValue = ""
            input.isEnabled = false
        default:
            fixLengthButton.setNextState()
        }
    }

    @IBAction func inputValue(_ sender: AnyObject) {
        defer {
            switch mode {
            case .addNewConstX:
                fixXButton.setNextState()
            case .addNewConstY:
                fixYButton.setNextState()
            case .addNewConstP:
                fixLengthButton.setNextState()
            default:
                break
            }
            mode = .none
            objects = controller!.getDisplayedObjects()
            input.stringValue = ""
            input.isEnabled = false
            selected.removeAll()
            self.needsDisplay = true
        }
        switch mode {
        case .addNewConstX, .addNewConstY:
            let value = sender.doubleValue
            if value != nil && controller != nil {
                let const = Constraint(type: .constX, value: value!, relation: nil)
                let index: Int
                if mode == .addNewConstX {
                    index = 0
                } else {
                    index = 1
                }
                for id in selected {
                    if let status = controller!.add(constraint: const, index: index, to: id) {
                        output.stringValue = "Status: " + status
                        return
                    }
                }
                if let status = controller!.calculatePositions() {
                    output.stringValue = "Status: " + status
                } else {
                    output.stringValue = "Status: add constraint for \(selected.count) objects"
                }
            } else {
                output.stringValue = "Status: controler fault"
            }
        case .addNewConstP:
            let value = sender.doubleValue
            if value != nil && controller != nil {
                let const = Constraint(type: .constP, value: value!, relation: nil)
                for id in selected {
                    if let status = controller!.add(constraint: const, index: 2, to: id) {
                        output.stringValue = "Status: " + status
                        return
                    }
                }
                if let status = controller!.calculatePositions() {
                    output.stringValue = "Status: " + status
                } else {
                    output.stringValue = "Status: add constraint for \(selected.count) objects"
                }
            } else {
                output.stringValue = "Status: controler fault"
            }

        default:
            break
        }
    }
}
