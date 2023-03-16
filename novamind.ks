// RocketStage is used to chage between phases
declare global RocketStage to 0. 
DEFINE().

function Start {
	//Code here will run once at start

	//Launch statement
	lock throttle to 1.
	lock steering to srfPrograde.
	SetTimeWarp("PHYSICS", 3).
	wait 1.
	DoSafeStage().

	//Declare OldThrust variable for autostage
	declare global OldThrust to ship:availableThrust.
	//Declare OriginalVector variable for maneuver calculation
	declare global OriginalVector to -1.
}

function Main {
	//Code here will run until shutdown sequence
	if RocketStage = 1 {
		AutoStage().

		//Stage exit condition
		if alt:radar >= 1000 {
			RocketStageIncrement().
		}
	} else if RocketStage = 2 {
		//Set inclination using curve 90 - (x^0.385)
		lock targetPitch to 90-((alt:radar-1000)^0.385).
		lock targetDirection to 0.
		lock steering to heading(targetDirection, targetPitch).
		AutoStage().

		//Stage exit condition
		if apoapsis >= 100000 {
			RocketStageIncrement().
		}
	} else if RocketStage = 3 {
		//Prepare rocket to start orbit
		SetTimeWarp("same", 0).
		lock throttle to 0.
		lock steering to prograde.
		wait 1.
		DoSafeStage().

		//This stage doesn't have exit condition as it's only run once
		RocketStageIncrement().
	} else if RocketStage = 4 {
		//Circularize maneuver
		local Circ is list(time:seconds + 30, 0, 0, 0).
		until false {
			local OldScore is Score(Circ).
			set Circ to Improve(Circ).
			if OldScore <= Score(Circ) {
				break.
			}
		}
		ExecuteManuever(Circ).

		//This stage doesn't have exit condition as it's only run once
		RocketStageShutdown().
	// } else if RocketStage = 5 {
	// 	if false {
	// 		RocketStageShutdown().
	// 	}
	}
}

function Score { 
	parameter data.
	//Creates maneuver from imput
	local mnv is node(data[0], data[1], data [2], data[3]). 
	//Adds maneuver to flight plan
	add mnv.
	//Finds eccentricity
	//Lower = better			
	local ManeuverScore is mnv:orbit:eccentricity.
	//Removes maneuver from flight plan
	remove mnv.
	return ManeuverScore.
}

function MainGUI {
	//Code here is used for the Console GUI
	print "Fase " + RocketStage.
	if RocketStage = 1 {
		print "Escapando de la atmósfera".
		print "Altura:   " + floor(alt:radar).
		print "Apoapsis: " + floor(apoapsis).
	} else if RocketStage = 2 {
		print "Iniciando trayectoria de giro".
		print "Altura:   " + floor(alt:radar).
		print "Apoapsis: " + floor(apoapsis).
	} else if RocketStage = 3 {
		print "Apoapsis conseguida".
	} else if RocketStage = 4 {
		print "Consiguiendo órbita".
	} else if RocketStage = 5 {
		print "En orbita".
		print "Presione RCS para salir de órbita".
	}
	
}

function End {
	//Code here will run when program ends
	// lock steering to retrograde.
	// lock throttle to 1.
	// wait until ship:maxThrust = 0.
	// DoSafeStage.
}

//Recurring Functions

function Improve {
	parameter data.
	local ScoreToBeat is Score(data).

	local BestCandidate is data.
	local Candidates is list (
		list(data[0] + 1, data[1], data [2], data[3]),
		list(data[0] - 1, data[1], data [2], data[3]),
		list(data[0], data[1] + 1, data [2], data[3]),
		list(data[0], data[1] - 1, data [2], data[3]),
		list(data[0], data[1], data [2] + 1, data[3]),
		list(data[0], data[1], data [2] - 1, data[3]),
		list(data[0], data[1], data [2], data[3] + 1),
		list(data[0], data[1], data [2], data[3] - 1)
	).
	for Candidate in Candidates {
		local sc is Score(Candidate).
		if sc < ScoreToBeat {
			set ScoreToBeat to sc.
			set BestCandidate to Candidate.
		}
	}
	
	return BestCandidate.
}

function DoSafeStage {
	//Waits until Staging is safe 
	wait until stage:ready.
	stage.
}

function AutoStage {
	// Cambia la etapa del cohete si se acaba el combustible
	if ship:availableThrust < (oldThrust-1) {
		wait 0.5.
		DoSafeStage(). wait 1.
		set OldThrust to ship:availablethrust.
	}
}

function ExecuteManuever {
	parameter mnvList.
	local mnv is node(mnvList[0], mnvList[1], mnvList[2], mnvList[3]).
	add mnv. //Add maneuver to Flight Plan
	local StartTime is time:seconds + mnv:eta - ManeuverBurnTime(mnv)/2. //Calculate start time
	wait until time:seconds > StartTime - 10.
	lock steering to mnv:burnvector. //Lock steering at maneuver target
	wait until time:seconds > StartTime.
	lock throttle to 1.
	SetTimeWarp("PHYSICS", 3).
	wait until IsManeuverComplete(mnv).
	SetTimeWarp("PHYSICS", 0).
	lock throttle to 0.
	unlock steering.
	remove mnv. //Removes maneuver from Flight Plan
}

function ManeuverBurnTime {
	parameter mnv.
	local isp is 0.
	local g0 is 9.80665.
    local ManeuverTime is 0.

	list engines in myEngines.
    print myEngines.
	for en in myEngines {
		if en:ignition and not en:flameout {
			set isp to isp + (en:isp * (en:maxThrust/ship:maxThrust)).
		}
	} 
    
    until not(isp = 0){
        DoSafeStage().
    }
    
    if not(isp = 0) {
        local mf is ship:mass / (constant():e)^(mnv:deltaV:mag / (isp*g0)).
	    local FuelFlow is ship:maxThrust / (isp*g0). 
	    set ManeuverTime to (ship:mass - mf) / fuelFlow.
    } else {
        print "Specific Impulse = 0".
    }
	
	return ManeuverTime.
}
	
function IsManeuverComplete {
	parameter mnv.
	if (OriginalVector = -1) {
		set OriginalVector to mnv:burnvector.
	}
	local CurrentVector is mnv:burnvector.

	if vang(OriginalVector, CurrentVector) > 90 {
		set OriginalVector to -1.
		return true.
	}
	return false.
}

//DO NOT TOUCH THESE FUNCTIONS
function DEFINE {
	//Function Start happens at Stage 0 and does never repeat.
	Start(). 
	GUIHeader().
	RocketStageIncrement().
	until RocketStage = 0 {
		//Function Main repeats until Stage is reset to 0.
		GUIHeader().
		MainGUI().
		Main().
	}
	End().
	clearScreen.
	print "novamind.ks has exited with code 0".
	until false.
}
function GUIHeader {
	clearScreen.
	print "novamind.ks by Neoyandrak".
	print " ".
}
function RocketStageIncrement {
	set RocketStage to RocketStage + 1.
}
function RocketStageShutdown {
	set RocketStage to 0.
}
function SetTimeWarp {
	parameter TWMode, TWTime.
	if TWMode = "PHYSICS" or TWMODE = "RAILS" {
		set kuniverse:timewarp:mode to TWMode.
	} else {
		print "SetTimeWarp error".
	}
	set kuniverse:timewarp:warp to TWTime.
}