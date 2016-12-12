//
//  FIgureSpawnerViewController.swift
//  TOMFigureSpawner
//
//  Created by TOM on 7/13/16.
//  Copyright © 2016 TOMApps. All rights reserved.
//

import UIKit

class FigureSpawnerViewController: UIViewController {

    //MARK: Properties
    
    //Bool that will indicate if the next figure will be drawn in a square or rectangle
    private var nextRectIsSquare = true
    
    /** View that is being panned */
    private var panningFigure: Figure?
    
    /** Point to keep track of the last place a panning gesture, that is still in motion, was registered */
    private var previousPanPoint: CGPoint?
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViewGestureRecognizers()
        title = "Figure Spawner"
    }

    //MARK: Gestures
    
    /** Adds all of the views gestures  */
    private func addViewGestureRecognizers() {
        //Tap gesture
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        //Right swipe gesture
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(changeFiguresColor))
        view.addGestureRecognizer(rotationGesture)
        //Left swipe gesture
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(deleteAllFigures))
        downSwipeGesture.direction = .down
        view.addGestureRecognizer(downSwipeGesture)
        //Pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panFigure))
        view.addGestureRecognizer(panGesture)
        panGesture.require(toFail: downSwipeGesture)
    }
    
    /** Creates a figure each adds it to the view when tapped */
    func viewTapped(_ tapGesture: UITapGestureRecognizer) {
        //Create figure
        let height = min(view.bounds.width, view.bounds.height) * 0.2
        let width = nextRectIsSquare ? height : height * 2
        let originX = CGFloat(arc4random_uniform(UInt32(view.bounds.width - width)))
        let originY = CGFloat(arc4random_uniform(UInt32(view.bounds.height - height)))
        view.addSubview(Figure.CreateRandomFigure(CGRect(x: originX, y: originY, width: width, height: height)))
        nextRectIsSquare = !nextRectIsSquare
        
    }
    
    /**Changes the fill color of all of the figures added to the view when swiped */
    func changeFiguresColor(_ rotationGesture: UIRotationGestureRecognizer) {
        if rotationGesture.state == .ended {
            for subview in view.subviews {
                if let figure = subview as? Figure {
                    figure.chooseRandomColor()
                }
            }
        }
    }
    
    /** Deletes all of the figures added to the view when swiped */
    func deleteAllFigures(_ swipeGesture: UISwipeGestureRecognizer) {
        for subview in view.subviews {
            if let figure = subview as? Figure {
                figure.deleteFigure()
            }
        }
    }
    
    /** Moves a figures through the view as long as the user is panning */
    func panFigure(_ panGesture: UIPanGestureRecognizer) {
        let gesturePoint = panGesture.location(in: view)
        switch panGesture.state {
        case .began:
            if let figure = view.hitTest(gesturePoint, with: nil) as? Figure {
                panningFigure = figure
                previousPanPoint = gesturePoint
            }
        case .changed:
            guard let figure = panningFigure, let previousGesturePoint = previousPanPoint else {
                return
            }
            moveFigure(figure, previousPoint: previousGesturePoint, actualPoint: gesturePoint)
            previousPanPoint = gesturePoint
        case .ended:
            guard let figure = panningFigure, let previousGesturePoint = previousPanPoint else {
                return
            }
            moveFigure(figure, previousPoint: previousGesturePoint, actualPoint: gesturePoint)
            panningFigure = nil
            previousPanPoint = nil
        default:
            break
        }
    }
    
    /** Moves a view's frame according to the displacement between two points */
    private func moveFigure(_ figure: UIView, previousPoint: CGPoint, actualPoint: CGPoint) {
        let deltaX = actualPoint.x - previousPoint.x
        let deltaY = actualPoint.y - previousPoint.y
        var frame = figure.frame
        frame.origin.x += deltaX
        frame.origin.y += deltaY
        figure.frame = frame
    }

}
