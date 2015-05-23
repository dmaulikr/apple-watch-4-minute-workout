//
//  InterfaceController.swift
//  Four-Minute Workout WatchKit Extension
//
//  Created by Jeffrey Yeung on 4/4/15.
//  Copyright (c) 2015 Yeungs Labs. All rights reserved.
//

import WatchKit
import Foundation


let kStateStarting = 2
let kStateRest = 1          // 10 seconds rest
let kStateRun = 3
let kStateJacks = 4
let kStateJumpingSquats = 5
let kStatePushUp = 6
let kStateBicycleCrunch = 7
let kStateBurpee = 8
let kStateMasonTwist = 9
let kStateMountainClimber = 10

let kStateDone = 11

let kKeyStreak = "streak"
let kKeyLifetime = "lifetime"
let kKeyLastDay = "lastday"


enum State : Int {
    case Stopped = 0, Started = 1
    
    static let allValues = [Stopped, Started]
}

extension NSDate {
    func xDays(days:Int) -> NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit( .CalendarUnitDay, value: days, toDate: self, options: nil)!
    }
    
    func xHours(days:Int) -> NSDate {
        return NSCalendar.currentCalendar().dateByAddingUnit( .CalendarUnitHour, value: days, toDate: self, options: nil)!
    }
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }

}


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var lblWorkout : WKInterfaceLabel!
    @IBOutlet var imgWorkout : WKInterfaceImage!
    @IBOutlet var wkTimer : WKInterfaceTimer!
    @IBOutlet var btnStartPause : WKInterfaceButton!
    @IBOutlet var imgProgress : WKInterfaceImage!
    
    
    var currentState : State = State(rawValue: 0)!
    var arrayExercises : [Int] = []
    var currentIndex : Int = 0
    var timer : NSTimer!
    
    var statsLifetime : Int!
    var statsStreak : Int!
    var statsLastDay : NSDate!
    let defaults = NSUserDefaults.standardUserDefaults()


    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        imgProgress.setHidden(true)
        wkTimer.setHidden(true)
        currentState = State(rawValue: 0)!
        
        
        // pull data
        if (defaults.objectForKey(kKeyLifetime) != nil){
            statsLifetime = defaults.integerForKey(kKeyLifetime)
        }
        else{
            statsLifetime = 0
        }
        if (defaults.objectForKey(kKeyStreak) != nil){
            statsStreak = defaults.integerForKey(kKeyStreak)
        }
        else{
            statsStreak = 0
        }
        if ((defaults.objectForKey(kKeyLastDay)) != nil){
            statsLastDay = defaults.objectForKey(kKeyLastDay) as NSDate
        }
        
        //TODO: add option to change exercises and not just load default
        self.loadDefaultExercises()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        defaults.setInteger(statsLifetime, forKey: kKeyLifetime)
        defaults.setInteger(statsStreak, forKey: kKeyStreak)
        defaults.setObject(statsLastDay, forKey: kKeyLastDay)
    }
    
    // MARK: Interface
    
    @IBAction func startPausePressed ()
    {
        // start workout if Start, pause if already started
        if (currentState == State(rawValue: 0)){
            currentState = State(rawValue: 1)!
            currentIndex = 0
            imgProgress.setHidden(false)
            wkTimer.setHidden(false)
            changeWorkoutState(arrayExercises[currentIndex])
            btnStartPause.setTitle("STOP")
        }
        else if (currentState == State(rawValue: 1)){
            currentState = State(rawValue: 0)!
            timer.invalidate()
            timer = nil
            wkTimer.stop()
            btnStartPause.setTitle("START")
            wkTimer.setHidden(true)
            
//            changeWorkoutState(kStateDone)
        }
    }
    

    // MARK: Backend
    
    func loadDefaultExercises()
    {
        // loads default exercises
        arrayExercises.append(kStateStarting);
        
        for var i = kStateRun; i < kStateMountainClimber; ++i{
            arrayExercises.append(i)
            arrayExercises.append(kStateRest)
        }
            
    }
    
    func changeWorkoutState(workoutNumber : Int)
    {
        // changes image
        switch(workoutNumber)
        {
        case kStateStarting:
            lblWorkout.setText("Starting...")
            wkTimer.setHidden(false)
            imgWorkout.setHidden(false)
            break
        case kStateRest:
            lblWorkout.setText("Rest!")
            break
        case kStateRun:
            lblWorkout.setText("Run in Place")
            break
        case kStateJacks:
            lblWorkout.setText("Jumping Jacks")
            break
        case kStateJumpingSquats:
            lblWorkout.setText("Jumping Squats")
            break
        case kStatePushUp:
            lblWorkout.setText("Push Ups")
            break
        case kStateBicycleCrunch:
            lblWorkout.setText("Bicyle Crunches")
            break
        case kStateBurpee:
            lblWorkout.setText("Burpees")
            break
        case kStateMasonTwist:
            lblWorkout.setText("Mason Twists")
            break
        case kStateMountainClimber:
            lblWorkout.setText("Mountain Climbers")
            break
        case kStateDone:
            wkTimer.setHidden(true)
            imgWorkout.setHidden(true)
            
            if (statsLastDay == nil)
            {
                statsStreak = 1
            }
            else{
                let streakCheckDate : NSDate = statsLastDay.xDays(+1).xHours(+3)
                
                if (NSDate().isLessThanDate(streakCheckDate)){
                    statsStreak = statsStreak + 1
                }
                else{
                    statsStreak = 1
                }

            }
            lblWorkout.setText("Current Sreak: \(statsStreak)")
            
            // set last day stat
            statsLastDay = NSDate()
            statsLifetime = statsLifetime + 1
            
            btnStartPause.setTitle("DONE")
            
            defaults.setInteger(statsLifetime, forKey: kKeyLifetime)
            defaults.setInteger(statsStreak, forKey: kKeyStreak)
            defaults.setObject(statsLastDay, forKey: kKeyLastDay)
            
            break
        default:
            break
        }
        
        var time : NSTimeInterval
        
        //resets timer and starts timer
        if (workoutNumber == kStateStarting){
            time = 6
        }
        else if (workoutNumber == kStateRest){
            time = 11
        }
        else{
            let width : CGFloat = (CGFloat(workoutNumber) - 3.0) * 136 / 8.0
            imgProgress.setWidth(width)
            time = 21
        }
        
        wkTimer.setDate(NSDate(timeIntervalSinceNow: time))
        wkTimer.start();
        timer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector("timerExpired"), userInfo: nil, repeats: false)
    }
    
    func timerExpired() {
        wkTimer.stop()
        if (currentIndex < arrayExercises.count){
            ++currentIndex
            changeWorkoutState(arrayExercises[currentIndex])
        }
        else
        {
            //display done message
        }
    }
    
    
}
