clearScreen.
core:part:getmodule("kOSProcessor"):doevent("Open Terminal"). //Opens console
print "xeinOS iniciado correctamente.".
print " ".
global Countdown is 0.
until Countdown = 5 {
    print "T-" + (5 - Countdown).
    set Countdown to Countdown + 1.
    wait 1.
}

runpath("0:/novamind.ks").