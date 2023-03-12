// Neoyandrak's kOS template file
DEFINE().

function Start {
	//Code here will run once at start

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
	print "preset.ks by Neoyandrak".
	print "".
}
function RocketStageIncrement {
	set RocketStage to RocketStage + 1.
}
function RocketStageShutdown {
	set RocketStage to 0.
}