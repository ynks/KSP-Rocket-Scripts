clearScreen.
core:part:getmodule("kOSProcessor"):doevent("Open Terminal"). //Opens console
print "xeinOS iniciado correctamente.".
print " ".
global Countdown is 0.
until Countdown = 10 {
    print "T-" + (9 - Countdown).
    set Countdown to Countdown + 1.
    wait 1.
}

runpath("0:/novamind.ks").