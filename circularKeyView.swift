//
//  circularKeyView.swift
//  for pureTone
//
//  Created by vas on 4/16/16.
//  Copyright © 2016 nos. All rights reserved.
//
import UIKit
import AudioKit

//delegate understanding comes from
//http://stackoverflow.com/questions/34938682/swift-delegate-protocol-structure

protocol PanUpdateOscillator: class {
    func updateOscillatorFrequency(frequency: Double, oscIndex: Int)
    func updateOscillatorAmplitude(amplitude: Double, oscIndex: Int)
}

protocol toggleOscillatorProtocol: class {
    func toggleOscillator(oscIndex: Int)
}

class circularKeyView: UIView {
    
    var oscID = 0
    var active = false
    var exponentiator = Double(1.08) //the rate at which the x-coordinate changes the frequency = pitch upon pan
    
    weak var toggleOscDelegate:toggleOscillatorProtocol? //toggle stopped or play for given OSC
    
    weak var delegatePan:PanUpdateOscillator?
    // a lot of this code came from https://www.weheartswift.com/bezier-paths-gesture-recognizers/
    //all thanks goes to we<3swift
    
    let lineWidth: CGFloat = 0.5
    let sizeWidth: CGFloat = 75.0
    let sizeHeight: CGFloat = 50.0

    init(origin: CGPoint, oscIndex: Int) {

        super.init(frame: CGRectMake(0.0, 0.0, sizeWidth, sizeHeight))
        self.center = origin
        self.backgroundColor = UIColor.clearColor()
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(circularKeyView.didPan(_:)))
        addGestureRecognizer(panGR)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(circularKeyView.didTap(_:)))
        addGestureRecognizer(tapGR)
        self.oscID = oscIndex

    }
    
//    func mapXPositionToFrequencyInAudibleRange(xPosition: Double) {
//        var datMappedFrequencyGoodness = 0
        
        
        
//        return datMappedFrequencyGoodness
        
//    }
//
    
    
    //PAN IT LIKE u FRYIN.
    func didPan(panGR: UIPanGestureRecognizer) {

        self.superview!.bringSubviewToFront(self)
        
        let translation = panGR.translationInView(self)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        
        panGR.setTranslation(CGPointZero, inView: self)
        
        let newFrequency = Double( pow( Double(self.center.x), exponentiator ) )
        let newAmplitude = Double( 1 - Double(self.center.y) / 400)// super.view.totalHeight)
            //print(newAmplitude)
            //mapXPositionToFrequencyInAudibleRange(Double(self.center.x))
        
        
        delegatePan?.updateOscillatorAmplitude(newAmplitude, oscIndex: Int(self.oscID))
        //updateOscillatorFrequencyBasis(newFreuqency)
        delegatePan?.updateOscillatorFrequency(newFrequency, oscIndex: Int(self.oscID) )
        //maybe move this up so it can send old freq and new one.
        
        
        
        //turn the circularKey to "active" state on pan, since it turns on the Oscillator sound.
        //if self.active == false {
        //    self.active = true
        //}
        //so the coordinates can be updated when there's a pan
        self.setNeedsDisplay() //updates the coordinates on a pan event

    }
    
    //user tapped on the circularKey, so pause or play it
    func didTap(tapGR: UITapGestureRecognizer) {

        
        toggleOscDelegate?.toggleOscillator(Int(self.oscID))
        
        //in trying to get active/inactive to toggle colors.  the activity var "active" works as expected, but trying to change the var seems problemseobbaitecs
        if self.active == false {
            self.active = true
        } else {
            self.active = false
        }
        self.setNeedsDisplay()
    }

    // We need to implement init(coder) to avoid compilation errors
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 1)
        UIColor.clearColor().setFill()
        
        /*if self.active == true {
            UIColor.orangeColor().setFill()
        } else {
            UIColor.clearColor().setFill()
        }*/
        path.fill()
        
        path.lineWidth = self.lineWidth
        UIColor.whiteColor().setStroke()
        path.stroke()
        
        
        //write the coordinates of the circularKeys onto the circularKeys
       
        /* let statsDrawPoint = CGPoint(x: 0, y:35)
        ("\(self.center.x), \(frame.origin.y), \(self.oscID)" as NSString).drawAtPoint(statsDrawPoint, withAttributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(10),
            NSForegroundColorAttributeName: UIColor.blackColor()
            ])*/
        
        
        let freqDrawPoint = CGPoint(x: 10, y: 19)
        let xCoord = self.center.x
        let unRoundedfrequency = pow( Double(xCoord), exponentiator )
        let frequency = Double(round(1000*unRoundedfrequency)/1000)
        //write the frequency of the circularKeys onto the circularKeys
        ("\(frequency)Hz" as NSString).drawAtPoint(freqDrawPoint, withAttributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(10),
            NSForegroundColorAttributeName: UIColor.whiteColor()
            ])
        
        
        
    }
}
