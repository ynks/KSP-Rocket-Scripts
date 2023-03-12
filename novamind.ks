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

	//Ascent statement
	//Sets inclination using curve 90 - (x^0.385)
	// lock targetPitch to 90-(alt:radar^0.385).
	// lock targetDirection to 90.
	// lock steering to heading(targetDirection, targetPitch).

	//Declare OldThrust variable for autostage
	declare global OldThrust to ship:availableThrust.
}

function Main {
	//Code here will run until shutdown sequence
	if RocketStage = 1 {
		//Auto Stage
		if ship:availableThrust < (oldThrust-1) {
			DoSafeStage(). wait 1.
			set OldThrust to ship:availablethrust.
		}

		if apoapsis >= 100000 {
			RocketStageShutdown.
		}
	} else if RocketStage = 2 {
		
	}
}

function MainGUI {
	//Code here is used for the Console GUI
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
	print "".
}
function RocketStageIncrement {
	set RocketStage to RocketStage + 1.
}
function RocketStageShutdown {
	set RocketStage to 0.
}