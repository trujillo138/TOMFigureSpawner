//
//  Figure.swift
//  TOMFigureSpawner
//
//  Created by TOM on 7/13/16.
//  Copyright © 2016 TOMApps. All rights reserved.
//

import UIKit

enum FigureType {
    case triangle
    case oval
    case rect
}

class Figure: UIView {

    //MARK: Properties
    
    /** The type of the figure to be drawn */
    private var type: FigureType?
    
    /** The color for which the figure is going to be filled */
    private var color: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    //MARK: Drawing
    
    override func draw(_ rect: CGRect) {
        guard let figureType = type,
        let figureColor = color else {
            return
        }
        var bezierPath: UIBezierPath!
        switch figureType {
        case .triangle:
            bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 0.0, y: bounds.height))
            bezierPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
            bezierPath.addLine(to: CGPoint(x: bounds.width / 2, y: 0.0))
            bezierPath.close()
        case .oval:
            bezierPath = UIBezierPath(ovalIn: bounds)
        case .rect:
            bezierPath = UIBezierPath(rect: bounds)
        }
        figureColor.setFill()
        bezierPath.fill()
    }
    
    /** Changes the color of the figure for a random color */
    func chooseRandomColor() {
        let colorNum = arc4random_uniform(4)
        if colorNum == 0 {
            color = UIColor.red
        } else if colorNum == 1 {
            color = UIColor.blue
        } else if colorNum == 2 {
            color = UIColor.yellow
        } else {
            color = UIColor.green
        }
    }
    
    /** Deletes the figure in an animated way */
    func deleteFigure() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
        }) 
    }
    
    //MARK: Gestures
    
    func pinchFigure(_ pinchGesture: UIPinchGestureRecognizer) {
        let scale = CGAffineTransform(scaleX: pinchGesture.scale, y: pinchGesture.scale)
        transform = transform.concatenating(scale);
        pinchGesture.scale = 1.0
        
    }
    
    //MARK: Creation
    
    /** Creates a Figure with a random FigureType and color */
    class func CreateRandomFigure(_ frame: CGRect) -> Figure {
        let figureNum = arc4random_uniform(3)
        var figureType = FigureType.rect
        if figureNum == 0 {
            figureType = .triangle
        } else if figureNum == 1 {
            figureType = .oval
        }
        let figure = Figure(frame: frame)
        figure.type = figureType
        return figure
    }
    
    /** Default setup for the Figure */
    private func setup() {
        backgroundColor = UIColor.clear
        isOpaque = false
        contentMode = .redraw
        clipsToBounds = false
        chooseRandomColor()
        addPinchGesture()
    }
    
    private func addPinchGesture() {
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchFigure)))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
