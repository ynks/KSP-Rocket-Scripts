// Neoyandrak's kOS template file
//RocketStage is used to chage between the rocket phases (ie. ignition, launch, orbit...)
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
}

function Main {
	//Code here will run until shutdown sequence
	if RocketStage = 1 {
		AutoStage().

		//Stage exit condition
		if apoapsis >= 1000 {
			RocketStageIncrement().
		}
	} else if RocketStage = 2 {
		//Set inclination using curve 90 - (x^0.385)
		lock targetPitch to 90-((alt:radar-1000)^0.385).
		lock targetDirection to 90.
		lock steering to heading(targetDirection, targetPitch).

		//Stage exit condition
		if apoapsis >= 100000 {
			RocketStageIncrement().
		}
	} else if RocketStage = 3 {
		lock throttle to 0.
		lock steering to prograde.
		DoSafeStage().
		ExecuteManuever(x, y, z, w).

		//Stage exit condition
		if false {
			RocketStageIncrement().
		}
	}
}

function MainGUI {
	//Code here is used for the Console GUI
	print "Fase " + RocketStage + ".".
	if RocketStage = 1 {
		print "Escapando de la atmósfera".
	} else if RocketStage = 2 {
		print "Iniciando trayectoria de giro".
	} else if RocketStage = 3 {
		print "Apopasis conseguida.".
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
	parameter utime, radial, normal, prograde.
	local mnv is node (utime, radial, normal, prograde).
	AddManueverToFlightPlan(mnv).
	local StartTime is CalculateStartTime(mnv).
	wait until StartTime - 10.
	LockSteeringAtManeuverTarget(mnv).
	wait until StartTime().
	lock throttle to 1.
	wait until IsManeuverComplete(mnv).
	lock throttle to 0.
	RemoveManeuverFromFlightPlan(mnv).
}

function AddManueverToFlightPlan {
	parameter mnv.

}

function CalculateStartTime {
	parameter mnv.

	return 0.
}

function LockSteeringAtManeuverTarget {
	parameter mnv.

}
	
function IsManeuverComplete {
	parameter mnv.

	return true.
}

function RemoveManeuverFromFlightPlan {
	parameter mnv.
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