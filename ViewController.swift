//
//  ViewController.swift
//  for PureTone
//
//  Created by vas on 4/16/16.
//  Copyright © 2016 nos. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController, PanUpdateOscillator, toggleOscillatorProtocol {
    
    var numOscs: Int = 0; //update when we add a new osc
    
    @IBOutlet weak var wavePlot: AKOutputWaveformPlot!
    
    var customWaveTable = AKTable(.Square, size: 1024)

    var oscs = [ AKOscillator(), AKOscillator(),
                 AKOscillator(), AKOscillator(),
                 AKOscillator(), AKOscillator(),
                 AKOscillator(), AKOscillator(),
                 AKOscillator(), AKOscillator() ]
    
    var oldAmplitudes = [ Double(), Double(), Double(), Double(), Double(),
                          Double(), Double(), Double(), Double(), Double() ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    wavePlot.plotType = EZPlot
        wavePlot.color = UIColor.whiteColor()
        //wavePlot.updateBuffer(<#T##buffer: UnsafeMutablePointer<Float>##UnsafeMutablePointer<Float>#>, withBufferSize: 1024)
        //wavePlot.shouldOptimizeForRealtimePlot = true
        wavePlot.shouldMirror = false
        
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(_:)))
        self.view.addGestureRecognizer(tapGR)

 
            //
            //Make you own waves rite hear ninja
            //
            //
            //fill up the custom Wave Table that has no name like that horse through the desert
        print("creating new waves")
       /* let samples = customWaveTable.values.count
            for index in 0 ..< samples {
                if index < samples/2 {
                    customWaveTable.values[index] = Float(-0.5)
                } else {
                    customWaveTable.values[index] = Float(0.5)
                }

            }*/
            //  THIS IS WHERE THE MAGIC LIVES ^^^^^^^^^^^^^
                //  LEBRON JAMES
            //  LEBRON JAMES FOR THREE
            //  FROM DOWNTOWN
            //  CLE OUT
            //
            //  RELATED to the above:
            //set the first oscillator waveform as the custom Wave Table populated above
        
        for i in 0..<oscs.count {
            oscs[i] = AKOscillator(waveform: customWaveTable)
            }
        
        /*
        Let x be the sample number (so there are 513 samples)
        
        0 < = x <= 512
        
        f(x) = sin(2pi*x/512)*/
        
        //made-a ma own sine wave
/*    for jazz in 0..<customWaveTable.values.count {
            let wobble = Double(6.28318530718 * Double(jazz))
            let sine_me_up = Double(wobble / Double(customWaveTable.values.count))
            let graph_me_baby = Float( sin(sine_me_up) )//+ 0.5*sin(2*sine_me_up + 90)) // + 0.3*sin(3*sine_me_up) + 0.1*sin(5*sine_me_up))
            
           // customWaveTable.values[jazz] = graph_me_baby
            //print(graph_me_baby)
        }
*/
        
        
        //True timbres tend to have a different waveform based on their frequency.  Like a "low" waveform, a mid-range waveform, and a higher end waveform.  I think with maybe 10 crossfaded oscillators per new instrument we can make some wonderful sounds.  Just have the waveforms crossfade in and out based on the frequency of the selected instrument + pitch
    /*    oscs[0] = AKOscillator(waveform: customWaveTable)
        oscs[1] = AKOscillator(waveform: customWaveTable)
        oscs[2] = AKOscillator(waveform: customWaveTable)
        oscs[3] = AKOscillator(waveform: customWaveTable)*/

        
        //initialize, start oscillators at 0.0 amplitude
        for i in 0...9 {
            oscs[i].amplitude =  0.0
            oscs[i].rampTime =   0.5 //rampTime slows/gradual-ifies frequency change AND amplitude change
            
            oscs[i].start()
        }
        
        
        //unmixed output
        let unmixedOutput = AKMixer(oscs[0], oscs[1],
                                    oscs[2], oscs[3],
                                    oscs[4], oscs[5],
                                    oscs[6], oscs[7],
                                    oscs[8], oscs[9])
        AudioKit.output = unmixedOutput
        AudioKit.start()
    }
    
    var exponentiator = Double(1.08)
    
    func didTap(tapGR: UITapGestureRecognizer) {

        //guarantee no more than 10 circularKeys on screen max since there's an artificial cap on the osc array
        if numOscs <= 9 {
            let tapPoint = tapGR.locationInView(self.view)
            
            let newCircularKey = circularKeyView(origin: tapPoint, oscIndex: numOscs)
        
            self.view.addSubview(newCircularKey)
            newCircularKey.delegatePan = self
            newCircularKey.toggleOscDelegate = self
        
            //&&& the freq multiplyer
            //oscsIndex = oscsIndex + 1;
            //on Tap it sets the frq to twice the xcoord. changes exponentially on pan.
            oscs[numOscs].frequency =  Double( pow( Double(newCircularKey.center.x), exponentiator ) )
            //oscs[numOscs].amplitude = 1.0
            numOscs = numOscs + 1
        }
        
        //else NO-OP, don't add any more oscillators past the artificial limit of 10

    }
    

    
    
    //conforming to toggleOscillatorProtocol
    //pauses and unpauses oscillators of given index

    func toggleOscillator(oscIndex: Int) {
        if (oscs[oscIndex].isStarted) {
            if oscs[oscIndex].amplitude > 0.0 {
                //set amplitude to ON
                oscs[oscIndex].amplitude = 0.0
            } else {
                oscs[oscIndex].amplitude = oldAmplitudes[oscIndex]
            }
        }
    
    }
    
    //conforming to the updateOsc Freq protocol
    func updateOscillatorFrequency(updatedFrequency: Double, oscIndex: Int) {
        oscs[oscIndex].frequency = updatedFrequency
    }
    
    //conforming to the updateAmplitudeOfOsc protocol
    func updateOscillatorAmplitude(updatedAmplitude: Double, oscIndex: Int) {
        //print(oscIndex, " gets a new amplitude of ", updatedAmplitude)
        oscs[oscIndex].amplitude = updatedAmplitude
        oldAmplitudes[oscIndex]  = updatedAmplitude
        //print("updating amplitude")
    }

}

