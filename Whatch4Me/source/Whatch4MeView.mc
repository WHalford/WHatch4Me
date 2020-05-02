using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityMonitor as AM;
using Toybox.Activity as Act;
using Toybox.Time.Gregorian as Greg;
using Toybox.Time as Time;
using Toybox.Math as Math;
using  Toybox.Application.Storage as Storage;

// Designed on Venu -  so Im using (10/390.toFloat()*watchHeight).toNumber() everywhere to scale - which seam wrong 
//probably better to calculate scale and use variable once   *Scale.toNumber()

class WHatch4MeView extends Ui.WatchFace {
	var inLowPower=false;
	
	var months;
	var weekdays;
	var dateFormat;
	var lang;
	
	var watchHeight;
	var watchWidth;
	
	//var watchHeightHalf;
	//var watchWidthHalf;

	var foregroundColor;
	var backgroundColor;
	
     

	
	
	
    function initialize() {
        WatchFace.initialize();
        		
		foregroundColor = Gfx.COLOR_WHITE;
		backgroundColor = Gfx.COLOR_BLACK;
                
		// Get background color setting
		var colorNum = Application.getApp().getProperty("BackgroundColor");
		
		if (colorNum == 1) {
			foregroundColor = Gfx.COLOR_BLACK;
			backgroundColor = Gfx.COLOR_WHITE;		
		}
		
        months = [
			Ui.loadResource(Rez.Strings.Mon0),
			Ui.loadResource(Rez.Strings.Mon1),
			Ui.loadResource(Rez.Strings.Mon2),
			Ui.loadResource(Rez.Strings.Mon3),
			Ui.loadResource(Rez.Strings.Mon4),
			Ui.loadResource(Rez.Strings.Mon5),
			Ui.loadResource(Rez.Strings.Mon6),
			Ui.loadResource(Rez.Strings.Mon7),
			Ui.loadResource(Rez.Strings.Mon8),
			Ui.loadResource(Rez.Strings.Mon9),
			Ui.loadResource(Rez.Strings.Mon10),
			Ui.loadResource(Rez.Strings.Mon11)
		];
		
		weekdays = [
			Ui.loadResource(Rez.Strings.Day0),
			Ui.loadResource(Rez.Strings.Day1),
			Ui.loadResource(Rez.Strings.Day2),
			Ui.loadResource(Rez.Strings.Day3),
			Ui.loadResource(Rez.Strings.Day4),
			Ui.loadResource(Rez.Strings.Day5),
			Ui.loadResource(Rez.Strings.Day6)
		];
		
		dateFormat = Ui.loadResource(Rez.Strings.DateFormat);
		lang = Ui.loadResource(Rez.Strings.lang);
		
	//var WhenDidWeLastCheck = Storage.getValue("WhenDidWeLastCheck");
	// Idea here is to trigger in onDisplay an occasional calculation of Sunset - load the step history etc 
	// If the hour has changed for example	
	// 		Sunset/Sunrise calculations 
	//		Load the history into an array of the size of the bars
	//  	Calculate the Max and populate the total steps prior to today for average
	//  	Check the Streak 
	// Might implement that later 
		
    }

    // Load your resources here
    function onLayout(dc) {    
    	 
        watchHeight = dc.getHeight();
		watchWidth = dc.getWidth();
		 
		 
		
	 
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    //System.println("in onShow");
    
}


    // Update the view
    function onUpdate(dc) {   
    
    
        
		// Clear gfx
		dc.setColor(backgroundColor, backgroundColor);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
		 
 
 		if (inLowPower==false)
 		{
 		//if WhenDidWeLastCheck is null or is yesterday or is more than 1 hour ago
 		//if (WhenDidWeLastCheck==null)
 		
 		
 		
 		drawClock(dc);// Draw clock
		drawBattery(dc);// Draw battery
		drawSunEvents(dc); // DrawSunEvents
        drawHeart(dc);   // Draw Heart       
		drawDate(dc);	 // Draw date	and also BT icon so they are alligned
				
		drawSteps(dc);   // Draw steps - graphs and averages  and today
	 
				
		if (Application.getApp().getProperty("DisplayToSinceDate"))
			{
			drawDaysToSince(dc); //draw daysTo or Since event (settings)
   			}
   		 
   		
   		} 
   		else
   		//Low Power Mode
   		{
   		drawLowPowerMode(dc);      
   		}
   		//Sys.println("in on update");
	}//function onupdate


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        inLowPower=false;
    	WatchUi.requestUpdate(); 
    }


    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	inLowPower=true;
    	WatchUi.requestUpdate(); 
    }
    
    function drawLowPowerMode(dc) {	
    	dc.setColor(backgroundColor, backgroundColor);
		dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
	    dc.setColor(foregroundColor, Gfx.COLOR_TRANSPARENT);
		
		var time = Util.getCurrentTime();
		var timeHeight = dc.getTextDimensions(time.minutes, Gfx.FONT_SMALL)[1];
			
 		var timeString = Lang.format("$1$:$2$", [time.hours, time.minutes]);   
      
//Divide watchheight into 8 and rotate through middle 6 every minute  

       var a = time.minutes.toFloat()/6;
       var b= time.minutes.toNumber()/6;
       var c= (a.toFloat()-b)*6;
       
      // System.println(time.minutes+" a:"+a+" b:"+b+" c:"+c);
        
 
		dc.drawText(watchWidth/2.toNumber(), (watchHeight/8)*(c+2), Gfx.FONT_MEDIUM , timeString, Gfx.TEXT_JUSTIFY_CENTER);
				       
	}	
     
    
    
    
    
    
    function drawDaysToSince(dc) {

    	//Event Date comes from Property
    	      	
    	var todayM = new Time.Moment(Time.today().value());    
	   	var eventM = new Time.Moment(Application.getApp().getProperty("MainObjective-Date"));
	    
	    // todayM is +- .5 of a day  depending on Timezone
	    // TodayM is Midnight HERE at start of today (TZ could be +11 or -11 
	    // EventM is midnight at start of date in parameters in UTC
	    // TZ offset +-11.30 is the max - convert these numbers todays / 86400 seconds and round "Today" to convert to same as UTC
	    	    
        var todayMcalc=Math.round(todayM.value().toFloat()/86400);
        var eventMcalc=eventM.value()/86400;
	  
 		var daysToSince = (todayMcalc-eventMcalc).toNumber();
       
        //var daysToSinceText = 0;
        
        //System.println("daysToSince:"+daysToSince);
        
    	//Sys.println("daysToSince:"+daysToSince+"   daysToSinceText:"+daysToSinceText);
    	dc.setColor(0xAAAAAA, Gfx.COLOR_TRANSPARENT);
        var pluraldays =" days" ;
        
        if (daysToSince<1.1) //one day then "Day" not "Days" - we dont use this string if its Zero anyway
        {if (daysToSince>-1.1)
        	{pluraldays = " day";}
   		}
   		
   		if (daysToSince >0)
	   		{ //event in the past - just say Day(s)
	   			pluraldays = daysToSince.abs()+ pluraldays+" since";
	   		}   
        else if (daysToSince<0) 
        	{//event in the future  "Day(s) Till"
        		pluraldays = daysToSince.abs()+ pluraldays + " till";
            }
            else // value = 0   = Today 
   			{
   				pluraldays="Today";
   			}
   		dc.drawText(watchWidth/2.toNumber(), (193/390.toFloat()*watchHeight).toNumber(), Gfx.FONT_XTINY,  pluraldays  , Gfx.TEXT_JUSTIFY_CENTER);  
   		
  //Turned this into above  		
//    	
//        if (daysToSince >0)
//        {   //event in the past - just say Day(s)
//        	dc.drawText(watchWidth/2.toNumber(), (193/390.toFloat()*watchHeight).toNumber(), Gfx.FONT_XTINY, daysToSince.abs()+ pluraldays+" since", Gfx.TEXT_JUSTIFY_CENTER);       
//        }   
//             else if (daysToSince<0)
//        {   //event in the future  "Day(s) Till" 
//        	dc.drawText(watchWidth/2.toNumber(), (193/390.toFloat()*watchHeight).toNumber(), Gfx.FONT_XTINY, daysToSince.abs()+ pluraldays + " till", Gfx.TEXT_JUSTIFY_CENTER);    
//        }
//        else // value = 0   = Today 
//        {        	
//        dc.drawText(watchWidth/2.toNumber(), 193, Gfx.FONT_XTINY,  "Today", Gfx.TEXT_JUSTIFY_CENTER);    
//		}
        
        
        
    
    
    }
    
    function drawHeart(dc) {
    // using https://forums.garmin.com/developer/connect-iq/f/discussion/5977/how-to-get-current-hearth-rate-on-watch-faces/42175#42175
    
    var HRsupport = (Act has :getHeartRateHistory) ? true : false; //check HR support
	
 var am = ActivityMonitor.getInfo();
		if (am has :getHeartRateHistory) 
		{
		 
			var heartRate = Activity.getActivityInfo().currentHeartRate;
			if(heartRate==null) 
				{
				var HRH=AM.getHeartRateHistory(1, true);
				var HRS=HRH.next();
				if(HRS!=null && HRS.heartRate!= AM.INVALID_HR_SAMPLE)
					{
					heartRate = HRS.heartRate;
					}
				}
			if(heartRate!=null) 
			{
				// Original code dc.drawText(100, 150 , Gfx.FONT_SMALL,heartRate.toString(), Gfx.TEXT_JUSTIFY_CENTER);
				//Locations etc
				var heartsize=(14/390.toFloat()*watchHeight).toNumber();
				var x = watchWidth/2.toNumber()-heartsize-heartsize;
     			var y = (50/390.toFloat()*watchHeight).toNumber();     			 
     			//Heart is two circles and a triangle
		       	dc.fillPolygon([[x, y], [x+(heartsize-2), y-(heartsize-2)], [x-(heartsize-2), y-(heartsize-2)], [x, y]]);
     			dc.fillEllipse(x-(heartsize/2),y-heartsize,heartsize/2.2,heartsize/2);
     			dc.fillEllipse(x+(heartsize/2),y-heartsize,heartsize/2.2,heartsize/2);
        		dc.setColor(foregroundColor, backgroundColor); 
     			var  HrWidth =  dc.getTextDimensions(heartRate.toString(), Gfx.FONT_XTINY)[0];
     			var  HrHeight =  dc.getTextDimensions(heartRate.toString(), Gfx.FONT_XTINY)[1];
     			dc.drawText(watchWidth/2.toNumber(), (23 /390.toFloat()*watchHeight).toNumber(), Gfx.FONT_XTINY, heartRate.toString(), Gfx.TEXT_JUSTIFY_LEFT);	
			}//if(heartRate!=null) 
        } //if (am has :getHeartRateHistory)
     }	//drawHeart
    
    
    

	function drawBluetooth(dc) {	
         
//        dc.setColor(Gfx.COLOR_BLUE, backgroundColor);
//                
//		var x = (258/390.toFloat()*watchHeight).toNumber();
//		var y = (15/390.toFloat()*watchHeight).toNumber();
//		var settings = Sys.getDeviceSettings();
//		if (settings.phoneConnected)
//       		{dc.fillCircle(x, y, 4);}
//       		else
//       		{dc.drawCircle(x, y, 4);}
//    	//dc.drawLine(x, y, x+6, y+6);
//    	//dc.drawLine(x+6, y+6, x+3, y+9);
//    	//dc.drawLine(x+3, y+9, x+3, y-3);
//    	//dc.drawLine(x+3, y-3, x+6, y);
//    	//dc.drawLine(x+6, y, x-1, y+6);
//    	
//        dc.setColor(foregroundColor, backgroundColor);
	}//draw Bluetooth

	function drawClock(dc) {
		dc.setColor(foregroundColor, Gfx.COLOR_TRANSPARENT);
		// System.println("   in drawClock");   	
		var time = Util.getCurrentTime();
		//System.println("time : " + time);
			
		//Not used var timeHeight = dc.getTextDimensions(time.minutes, Gfx.FONT_NUMBER_THAI_HOT)[1];
		
 		var timeString = Lang.format("$1$:$2$", [time.hours, time.minutes]);
 				
        var timeY = (75/390.toFloat()*watchHeight).toNumber();
		//Sys.println("inClock watchWidthHalf"+watchWidthHalf);	
		dc.drawText(watchWidth/2.toNumber(), timeY, Gfx.FONT_NUMBER_THAI_HOT, timeString, Gfx.TEXT_JUSTIFY_CENTER);
		 
	}
	
	function drawBattery(dc) {
	//System.println("     in drawBattery");  
		var systemStats = Sys.getSystemStats();
		var battery = systemStats.battery;
		var batteryBarLength = (0.18/390.toFloat()*watchHeight*battery).toNumber();
		
		var batteryTextHeight = dc.getTextDimensions(battery.format("%d") + "%", Gfx.FONT_XTINY)[1];
        var batteryTextWidth = dc.getTextDimensions(battery.format("%d") + "%", Gfx.FONT_XTINY)[0];
        //System.println("batteryWidth/Height: " + batteryTextWidth +" "+batteryTextHeight );
		
		var batteryY = (8/390.toFloat()*watchHeight).toNumber();
		var batteryX = ((watchWidth -(25/390.toFloat()*watchHeight).toNumber())- batteryTextWidth)/2;
	
	  //System.println("batteryX:" + batteryX+" Y: "+batteryY);
		 
        dc.setColor(foregroundColor, backgroundColor);
         
        //if (systemStats.charging) { // later SDK
		//	dc.setColor(Gfx.COLOR_GREEN);        	
        //}
          
        dc.drawRectangle(batteryX, batteryY, (20/390.toFloat()*watchHeight).toNumber(), (10/390.toFloat()*watchHeight).toNumber());
        dc.drawRectangle(batteryX+(20/390.toFloat()*watchHeight).toNumber(), batteryY + 2, 2, (6/390.toFloat()*watchHeight).toNumber() );//,might need to change these litterals?
		
		dc.setColor(Gfx.COLOR_GREEN, backgroundColor);
				
		if (battery < 40) {
			dc.setColor(Gfx.COLOR_ORANGE, backgroundColor);			
		}
		if (battery < 20) {
			dc.setColor(Gfx.COLOR_RED, backgroundColor);			
		} 
						        
        dc.fillRectangle(batteryX + 1, batteryY + 1, batteryBarLength, (8/390.toFloat()*watchHeight).toNumber());
        
        
        
      
        
        // FR45 fix
    	//if (watchHeight == 208)
    	//{
    	//	batteryY = batteryY + 10;
    	//}
    	//drawText(x, y, font, text, justification) ⇒ Object
    	
    	dc.setColor(foregroundColor, backgroundColor);
         dc.drawText(batteryX + (25/390.toFloat()*watchHeight).toNumber(), (batteryY - batteryTextHeight * 0.4), Gfx.FONT_XTINY, battery.format("%d") + "%", Gfx.TEXT_JUSTIFY_LEFT);
               
         
	}

	
	function drawDate(dc) {
	 //System.println("in drawDate");
		dc.setColor(foregroundColor, Gfx.COLOR_TRANSPARENT);
		
		var dateinfo = Greg.info(Time.now(), Time.FORMAT_SHORT);
				
		var weekday = weekdays[dateinfo.day_of_week-1];
		var month = months[dateinfo.month-1];
		var date = dateinfo.day;
		
		var dateText = Lang.format(dateFormat, [weekday, month, date]);
		 
		 var dateY = (50/390.toFloat()*watchHeight).toNumber();
				
		dc.drawText(watchWidth / 2, dateY, Gfx.FONT_SMALL , dateText, Gfx.TEXT_JUSTIFY_CENTER);   
		
		
		//Draw Bluetooth icon here   using a circle at the moment - filled for connected 
		dc.setColor(Gfx.COLOR_BLUE, backgroundColor);
                
		var BTx =(watchWidth / 2) + dc.getTextDimensions(dateText, Gfx.FONT_SMALL)[0]/2+(10/390.toFloat()*watchHeight).toNumber();       
		var BTy = dateY +    (dc.getTextDimensions(dateText, Gfx.FONT_SMALL)[1]/2) ;    
		var BTSize =  (6/390.toFloat()*watchHeight).toNumber();       
		var settings = Sys.getDeviceSettings();
		if (settings.phoneConnected)
       		{dc.fillCircle(BTx, BTy, BTSize);}
       		else
       		{dc.drawCircle(BTx, BTy, BTSize);}
       		
       	//BT Logo -  meh
    	//dc.drawLine(x, y, x+6, y+6);
    	//dc.drawLine(x+6, y+6, x+3, y+9);
    	//dc.drawLine(x+3, y+9, x+3, y-3);
    	//dc.drawLine(x+3, y-3, x+6, y);
    	//dc.drawLine(x+6, y, x-1, y+6);
    	
        dc.setColor(foregroundColor, backgroundColor); 	
    	 
	}


function drawSteps (dc) { 
//Sys.println("inDrawSteps");
	var hist = ActivityMonitor.getHistory(); //History structure
	var maxStepsorGoals =1;  //Max of Goals and Steps - NOTE initialize to 1 to avoid /0 error - this is used to 
	var maxactsteps=1; //Max of steps taken to display as number
	var totsteps=0;  // total of steps taken to calculate average (excludes today)
	var daystocount=0; //used to calculate the average of non zero days
	//get todays values seperately from history
	var actinfo = AM.getInfo();  //structure 
	var todaysofar=actinfo.steps; // 3000
	var todaygoal=actinfo.stepGoal; //10000;;
	 var averagesteps=0; 
	 
	 
	//0 = Yesterday
	//1= Day before Yesterday etc 
	
	var DBSS=9999; //DayBeforeStreekStarts 9999 means we have no other value
// calculation loop Scan through the history and capture the maxStepsorGoals,maxactsteps,totsteps
	 for (var i = 0; i < hist.size(); i++) {
	 		if (hist[i].steps > maxStepsorGoals) {maxStepsorGoals=hist[i].steps;}
	 		if (hist[i].stepGoal>maxStepsorGoals) {maxStepsorGoals=hist[i].stepGoal;}
	 		if (hist[i].steps > maxactsteps) {maxactsteps=hist[i].steps;}
	 		totsteps=totsteps+hist[i].steps;
	 		if (hist[i].steps>0)  {daystocount++;}
	 		if (hist[i].steps<hist[i].stepGoal)//We Missed the Goal
	 		 	{
	 		 	if (DBSS==9999)//We have not recorded any day that is the "Day Before Streak Starts"DBSS
	 		 		{DBSS=i;}
	 		 	}
	 		}//for loop
	 		
	 	 
	 		
	 		var today = new Time.Moment(Time.today().value());
	 		//var display1;
			var oneDay = new Time.Duration(Greg.SECONDS_PER_DAY);
 	 		var DisplayStreak = 0;
 	 	 	var DBSSfromMemory =100;//lets see
 	 	 	var DBSSMoment;
	 		//Sys.println("DBSSfromMemory (initialized):"+DBSSfromMemory);
	 		// DBSSfromMemory = Storage.getValue("StoredDBSS");\
	 		//Dont Do this here - do this inside the if to avoid when the streak starts in history array
       		
             DBSSfromMemory = Storage.getValue("StoredDBSS");
	 		 //Sys.println(" 1st DBSSfromMemory:"+DBSSfromMemory);  //1st DBSSfromMemory:1580428800 Friday, 31 January 2020
	 		//Sys.println(" 1st OverRideStreakDate:"+Application.getApp().getProperty("OverRideStreakDate"));// 1580515200 Saturday, 1 February 2020
	 		 
	 		 
	 		 if (Application.getApp().getProperty("OverRideStreakorNot"))
						{//there is an override value so replace storedDBSS with override  
						 Sys.println("using override value");
				 		 var OverRideStreakMoment = new Time.Moment(Application.getApp().getProperty("OverRideStreakDate"));
						 Sys.println("453");
						 DBSSMoment=OverRideStreakMoment.subtract(oneDay); //because setting will be first day of streak
						 Storage.setValue("StoredDBSS",DBSSMoment.value());//Store the new DBSS for use next time
		  				 Application.getApp().setProperty("OverRideStreakorNot",false);//set the flag to false as this is a one time operation
					     DBSSfromMemory=Storage.getValue("StoredDBSS"); //just to check what we stored
						}//OverRideStreakorNot
	 		 
	 		 		 
             if (DBSS==9999)//No Misses in History
 			   {
					if (DBSSfromMemory !=null) 
						{ //No Misses in history and there is a stored value so use it and dont change it
						  //this could be a fall through from Override but DBSSfromMemory is also set above the override if
						  	 //Sys.println("No Miss- Found Value so using stored value "+DBSSfromMemory);
						  	DBSSMoment = new Time.Moment(DBSSfromMemory);
							var DBSSSince=today.compare(DBSSMoment);
	         	    		DisplayStreak=DBSSSince/86400.toNumber();
	         	    	}
	         	    	else
	         	    	{//   No misses in history and no stored value
  						 //you only get here if the history is all hits the first time you run the watchface!
							DBSS=hist.size()+1;// because the array starts with 0 =yesterday. 
	 		   				DisplayStreak=DBSS;
//	 		   				var DBSSDaysDuration = oneDay.multiply(DBSS);  // DBSS*one Day Duration
//							var DBSSMoment=  today.subtract(DBSSDaysDuration);
						 	var DBSSMoment=  today.subtract(oneDay.multiply(DBSS));// do this without a var 
 				            Storage.setValue("StoredDBSS",DBSSMoment.value()); 
 				        } // elseNo misses in history and no stored value
					} //No Misses in History
					else
					{//There is a miss in history 
						DisplayStreak=DBSS; 
// 		   				var DBSSDaysDuration = oneDay.multiply(DBSS);  // DBSS*one Day Duration
//						var DBSSMoment=  today.subtract(DBSSDaysDuration);
						var DBSSMoment=  today.subtract(oneDay.multiply(DBSS));// do this without a var 
 						Application.getApp().setProperty("OverRideStreakorNot",false);//black out any attempt to override becuase the missed goal in history takes precedence.
  						Storage.setValue("StoredDBSS",DBSSMoment.value()); //Store the value for future use
  					}//There is a miss in history


	
	 		
	 		
 //Check if today actual or goal exceeds maxStepsorGoals (for steps or goal to scale the graph)
 //Also if today we have made the goals then Display streak can include today
 		if (todaysofar > maxStepsorGoals) 
 			{maxStepsorGoals=todaysofar;
 			 }
 		if (todaygoal>maxStepsorGoals) {maxStepsorGoals=todaygoal;}
  
  if (todaysofar >  todaygoal-1)
  	{DisplayStreak=DisplayStreak+1;}
    
 	// Leave maxactsteps alone because we display both weeks (till yesterday) max steps AND todays steps
 	// COMMENTED OUT :  	  if (todaysofar > maxactsteps) {maxactsteps=todaysofar;}
	 	 
	  // Calculate the average of non zero days including today if non zero (above)
	 if (todaysofar>0) // add todays steps to total and add today to days to count for average
		{
		daystocount++;
		totsteps=totsteps+todaysofar;
		}// add todays steps to total and add today to days to count
 
 
    // Sys.println("daystocount:"+daystocount+"  totsteps:"+totsteps+"   totsteps.toFloat():"+totsteps.toFloat());
	 if(daystocount>0) //avoid division by zero)
	 {
	    averagesteps=totsteps.toFloat()/daystocount;
	    
	 } // end avoid division by zero
     
    
 // Logic and calculation of following values -    
 	//VENU  : 
 	//Bottom line is 340
 	//8 bars spread over 270 across 
 	//7 *1/3 width gap between 8 bars means 2+1/3 more width - 10 + 1/3
 	 
     var bottomline=(340/390.toFloat()*watchHeight).toNumber();
	 var maxbarheight=(100/390.toFloat()*watchHeight).toNumber();
	 var barwidth=(26/390.toFloat()*watchHeight).toNumber();
	 var bargap=(6/390.toFloat()*watchHeight).toNumber();
	 var barspace=barwidth+bargap;
	 var rightedge=(260/390.toFloat()*watchHeight).toNumber(); 
	  
 
 	for (var i = 0; i < hist.size(); i++) {
	
		//Color Grey for goals  COLOR_LT_GRAY = 0xAAAAAA
		
		dc.setColor(0xAAAAAA, backgroundColor);
		//left edge  of bar
		dc.drawLine(rightedge-(barspace*i),bottomline-(maxbarheight*(hist[i].stepGoal.toFloat()/maxStepsorGoals)),rightedge-(barspace*i),bottomline);
		//right edge of bar
		dc.drawLine(rightedge-(barspace*i)+barwidth,bottomline-(maxbarheight*(hist[i].stepGoal.toFloat()/maxStepsorGoals)),rightedge-(barspace*i)+barwidth,bottomline);
		//circle top of bar
		dc.drawArc(rightedge-(barspace*i)+(barwidth.toFloat()/2), bottomline-(maxbarheight*(hist[i].stepGoal.toFloat()/maxStepsorGoals)),barwidth.toFloat()/2, 1, 180, 0);

		//choose the fill color of steps actuals based on meeting goal (> goal-1)
		if(hist[i].steps>hist[i].stepGoal-1)
		{dc.setColor( 0x00FF00, backgroundColor);}
		else {dc.setColor(0xAAAAAA, backgroundColor);}
		//rectangle fill for actuals
		dc.fillRectangle(rightedge-(barspace*i), bottomline-(maxbarheight*(hist[i].steps.toFloat()/maxStepsorGoals)), barwidth.toFloat()+1, maxbarheight*(hist[i].steps.toFloat()/maxStepsorGoals));
	
		//only fill the circle if achieved  (> goal-1)
		if(hist[i].steps>hist[i].stepGoal-1)
		{
			dc.fillCircle(rightedge-(barspace*i)+(barwidth.toFloat()/2), bottomline-(maxbarheight*(hist[i].steps.toFloat()/maxStepsorGoals)), barwidth.toFloat()/2);
		}//end if fill the circle
		
	

} //End for loop 
 
   
 //  TODAY bar in blue	

//the "barspace*-1" code keeps this the same format as the loop above - a bit clunky - but thecode matches
 //Today in Blue  unless steps gol met
    dc.setColor(0x00AAFF, backgroundColor);
 	if(todaysofar>todaygoal-1)//or green if completed
		{
		dc.setColor( 0x00FF00, backgroundColor);
		} //end Green Today if completed 
 	 	
 	//Today Left line of goal
 	dc.drawLine(rightedge-(barspace*-1),bottomline-(maxbarheight*(todaygoal.toFloat()/maxStepsorGoals)),rightedge-(barspace*-1),bottomline);
	//Today Right Line of goal
	dc.drawLine(rightedge-(barspace*-1)+barwidth.toFloat(),bottomline-(maxbarheight*(todaygoal.toFloat()/maxStepsorGoals)),rightedge-(barspace*-1)+barwidth.toFloat(),bottomline);
 	//Today goal cap
 	dc.drawArc(rightedge-(barspace*-1)+(barwidth.toFloat()/2), bottomline-(maxbarheight*(todaygoal.toFloat()/maxStepsorGoals)),barwidth.toFloat()/2, 1, 180, 0);
 	 //Today achievement
 	dc.fillRectangle(rightedge-(barspace*-1), bottomline-(maxbarheight*(todaysofar.toFloat()/maxStepsorGoals)), barwidth.toFloat()+1, maxbarheight*(todaysofar.toFloat()/maxStepsorGoals));
 	if(todaysofar>todaygoal-1) // fill cap only if meeting goal (>goal -1) 
	{
		dc.fillCircle(rightedge-(barspace*-1)+(barwidth.toFloat()/2), bottomline-(maxbarheight*(todaysofar.toFloat()/maxStepsorGoals)), barwidth.toFloat()/2);
	} //end fill cap only if met goal (>goal -1)
	
	
	 
	//Text display
	//   AverageØ    DaysSince      ^ MAX  
	var averagestepstxt=averagesteps.toNumber(); //cos we dont display the float
	
	
	var maxavgstepsY=(198/390.toFloat()*watchHeight).toNumber();
	
	dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
 	dc.drawText(4,maxavgstepsY, Gfx.FONT_SYSTEM_XTINY , averagestepstxt , Gfx.TEXT_JUSTIFY_LEFT);  // Average Steps on left
 	dc.drawText(watchWidth-4,maxavgstepsY, Gfx.FONT_SYSTEM_XTINY , maxactsteps , Gfx.TEXT_JUSTIFY_RIGHT);  //Max Steps on Right  /4 Litteral in this line 
 	
 	 
 	dc.setColor(foregroundColor, Gfx.COLOR_TRANSPARENT);
 	
 	//Display Steps today 80% of the time and lenghth of streak 20% of the time in the same place
 	if (Time.now().value()%10<2)
 	 {//Todays Steps 80% of the time
 	 dc.drawText(watchWidth/2,(345/390.toFloat()*watchHeight).toNumber(), Gfx.FONT_SYSTEM_SMALL , DisplayStreak+" days" , Gfx.TEXT_JUSTIFY_CENTER);}
 	 else
 	 {//Streak Length
 	  dc.drawText(watchWidth/2,(345/390.toFloat()*watchHeight).toNumber(), Gfx.FONT_SYSTEM_SMALL , todaysofar , Gfx.TEXT_JUSTIFY_CENTER); 
  	}//	end of if 20% (if Time%mod4 etc)
 	 		

  dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    //draw up arrow (max) and Ø symbol (average)
 	 	//draw up arrow (max) 
 	var maxwidth = dc.getTextDimensions(""+maxactsteps, Gfx.FONT_XTINY)[0];  //width is 0
 	//Sys.println("maxwidth:"+maxwidth);
 	
 	
  	//Up Arrow /\|  next to Max Steps on right
  	maxwidth=maxwidth+(15/390.toFloat()*watchHeight).toNumber();
 	dc.setPenWidth(2);
 	dc.drawLine(watchWidth-maxwidth, maxavgstepsY+(10/390.toFloat()*watchHeight).toNumber(), watchWidth- maxwidth, (227/390.toFloat()*watchHeight).toNumber() );
 	dc.drawLine(watchWidth-maxwidth, maxavgstepsY+(10/390.toFloat()*watchHeight).toNumber(), watchWidth-maxwidth+(7/390.toFloat()*watchHeight).toNumber(), (215/390.toFloat()*watchHeight).toNumber());
 	dc.drawLine(watchWidth-maxwidth, maxavgstepsY+(10/390.toFloat()*watchHeight).toNumber(), watchWidth-maxwidth-(7/390.toFloat()*watchHeight).toNumber(), (215/390.toFloat()*watchHeight).toNumber());  
 	
 	// Ø symbol (average)
 	
 	var avgwidth = dc.getTextDimensions(""+averagestepstxt, Gfx.FONT_XTINY)[0];  //width is 0
 	// Sys.println("maxwidth:"+maxwidth);
 	avgwidth=avgwidth+(15/390.toFloat()*watchHeight).toNumber();
 	dc.setPenWidth(2);
 	dc.drawCircle(avgwidth, (218/390.toFloat()*watchHeight).toNumber(), (6/390.toFloat()*watchHeight).toNumber());
 	dc.setPenWidth(1);
 	dc.drawLine(avgwidth-(5/390.toFloat()*watchHeight).toNumber() , ((216+10)/390.toFloat()*watchHeight).toNumber() , avgwidth+(8/390.toFloat()*watchHeight).toNumber(), ((216-8)/390.toFloat()*watchHeight).toNumber());
 	//dc.drawLine(maxwidth, 205, maxwidth-7, 215);
 	 
 	
 	
}//end drawsteps

function drawSunEvents(dc) {
	//Sys.println("in drawSunEvents v4 hardcoded");
	
	var sunTimes=[0,0];
    var sunText=[0,0];
	var gLocationLat = null;
    var gLocationLng = null;
    var locationLat =  Application.getApp().getProperty("ManualLat");
    var locationLng = Application.getApp().getProperty("ManualLong");
           
//Hard coded  Melbourne,Australia for testing	        
	   //locationLat=-37.809125; 
	   //locationLng=145.103408;
	  	  	      
	   	gLocationLat = locationLat.toFloat();
		gLocationLng = locationLng.toFloat();
	    
	//	var nextSunEvent = 0;
		var now = Greg.info(Time.now(), Time.FORMAT_SHORT);
		now = now.hour + ((now.min + 1) / 60.0);
		sunTimes = getSunTimes(gLocationLat, gLocationLng, null, /* tomorrow */ false);
			 
		var SunTimes0H=Math.floor(sunTimes[0]).toNumber(); 
		var SunTimes0M=((sunTimes[0]-SunTimes0H)*60).toNumber();
		var SunTimes1H=Math.floor(sunTimes[1]).toNumber(); 
		var SunTimes1M=((sunTimes[1]-SunTimes1H)*60).toNumber();
		SunTimes1H=SunTimes1H-12;
	
		var SunTimes0pad = "";
		var SunTimes1pad = "";
		if (SunTimes0M < 10)
			{		SunTimes0pad="0";}
		if (SunTimes1M < 10)
			{		SunTimes1pad="0";}  
	
		
		
		
		
		//Draw Sunise Time	 	
		 dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
		// var sunrisewidth=dc.getTextDimensions(SunTimes0H+":"+SunTimes0pad+SunTimes0M+"00", Gfx.FONT_XTINY)[0];  //width is 0
		 //measure width with an extra character to move it in from being cut off
		 dc.drawText( (90/390.toFloat()*watchHeight).toNumber(), (23/390.toFloat()*watchHeight).toNumber(), Gfx.FONT_SYSTEM_XTINY,SunTimes0H+":"+SunTimes0pad+SunTimes0M  , Gfx.TEXT_JUSTIFY_LEFT);
		 //DrawSunset Time
		 dc.setColor( Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
		 var sunsetwidth=dc.getTextDimensions(SunTimes1H+":"+SunTimes1pad+SunTimes1M+"00", Gfx.FONT_XTINY)[0];  //width is 0 height is 1
		 dc.drawText(watchHeight -(90/390.toFloat()*watchHeight).toNumber(), (23/390.toFloat()*watchHeight).toNumber(), Gfx.FONT_SYSTEM_XTINY ,SunTimes1H+":"+SunTimes1pad+SunTimes1M  , Gfx.TEXT_JUSTIFY_RIGHT);
}


function GetHeartRate(dc) {//From https://forums.garmin.com/developer/connect-iq/f/discussion/5977/how-to-get-current-hearth-rate-on-watch-faces/42175#42175
var ret = "---";
var hr = Act.getActivityInfo().currentHeartRate;
if(hr != null) {ret = hr.toString();}
else {
var hrI = Act.getHeartRateHistory(1, true);
var hrs = hrI.next().heartRate;
if(hrs != null && hrs != Act.INVALID_HR_SAMPLE) {ret = hrs.toString();}
}
return ret;
}


} // Class WHatch4MeView 