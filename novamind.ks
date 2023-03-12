// Neoyandrak's kOS template file
DEFINE().

function Start {
	//Code here will run once at start

	//Launch statement
	lock throttle to 1.
	wait 1.
	DoSafeStage().

	//Ascent statement
	//Sets inclination using curve 90 - (x^0.385)
	lock targetPitch to 90-(alt:radar^0.385).
	lock targetDirection to 90.
	lock steering to heading(targetDirection, targetPitch).
}

function Main {
	//Code here will run until shutdown sequence

}

function MainGUI {
	//Code here is used for the Console GUI
}

function End {
	//Code here will run when program ends
}

//Recurring Functions
function DoSafeStage {
	//Waits until Staging is safe 
	wait until stage:ready.
	stage.
}

//DO NOT TOUCH THESE FUNCTIONS
function DEFINE {

	//RocketStage is used to chage between the rocket phases (ie. ignition, launch, orbit...)
	set RocketStage to 0. 

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