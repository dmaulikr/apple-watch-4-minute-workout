//
//  StatsInterfaceController.swift
//  Four-Minute Workout
//
//  Created by Jeffrey Yeung on 4/5/15.
//  Copyright (c) 2015 Yeungs Labs. All rights reserved.
//

import WatchKit
import Foundation


extension NSDate{
    
    func monthDay() -> NSString {
        let flags: NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit
        let date = self
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)

        var month : NSString = NSString.alloc()
        switch (components.month){
        case 1:
            month = "Jan"
            break
        case 2:
            month = "Feb"
            break
        case 3:
            month = "Mar"
            break
        case 4:
            month = "Apr"
            break
        case 5:
            month = "May"
            break
        case 6:
            month = "Jun"
            break
        case 7:
            month = "Jul"
            break
        case 8:
            month = "Aug"
            break
        case 9:
            month = "Sep"
            break
        case 10:
            month = "Oct"
            break
        case 11:
            month = "Nov"
            break
        case 12:
            month = "Dec"
            break
        default:
            break
        }
        
        return "\n\(month) \(components.day)"
    }
    
}


class StatsInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblLifetime : WKInterfaceLabel!
    @IBOutlet var lblStreak : WKInterfaceLabel!
    @IBOutlet var lblLastDay : WKInterfaceLabel!
    
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
            statsLastDay = defaults.objectForKey(kKeyLastDay) as! NSDate
        }
        
        self.setStatsLabels()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func setStatsLabels(){
        if (statsLastDay != nil){
            lblLastDay.setText("Last Workout\(statsLastDay.monthDay())")
        }
        else{
            lblLastDay.setText("No prior workouts")
        }
        lblStreak.setText("Current Streak\n\(statsStreak)")
        lblLifetime.setText("Lifetime\n\(statsLifetime)")
    }

}