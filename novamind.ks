// RocketStage is used to chage between phases
declare global RocketStage to 0. 
DEFINE().

function Start {
	//Code here will run once at start

	//Launch statement
	lock throttle to 1.
	lock steering to srfPrograde.
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
		lock throttle to 0.
		lock steering to prograde.
		wait 1.
		DoSafeStage().

		//This stage doesn't have exit condition as it's only run once
		RocketStageIncrement().
	} else if RocketStage = 4 {
		// TODO: Execute maneuver
		
		//Stage exit condition
		if false {
			RocketStageIncrement().
		}
	}
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
	}
	
}

function End {
	//Code here will run when program ends
	lock throttle to 0.
	lock steering to prograde.

}

//Recurring Functions
function DoSafeStage {
	//Waits until Staging is safe 
	wait until stage:ready.
	stage.
}

function AutoStage {
	// Cambia la etapa del cohete si se acaba el combustible
	if ship:availableThrust < (oldThrust-1) {
		DoSafeStage(). wait 1.
		set OldThrust to ship:availablethrust.
	}
}

function ExecuteManuever {
	parameter utime, radial, normal, mnvprograde.
	local mnv is node (utime, radial, normal, mnvprograde).
	add mnv. //Add maneuver to Flight Plan
	local StartTime is time:seconds + mnv:eta - ManueverBurnTime(mnv)/2. //Calculate start time
	wait until time:seconds > StartTime - 10.
	lock steering to mnv:burnvector. //Lock steering at maneuver target
	wait until time:seconds > StartTime.
	lock throttle to 1.
	wait until IsManeuverComplete(mnv).
	lock throttle to 0.
	remove mnv. //Removes maneuver from Flight Plan
}

function ManeuverBurnTime {
	parameter mnv.

	return 10.
}
	
function IsManeuverComplete {
	parameter mnv.
	if not(OriginalVector = -1){
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
		Main().
		MainGUI().
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