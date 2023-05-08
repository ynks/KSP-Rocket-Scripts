clearScreen.
print "Parachute stage landing".

wait until vessel:verticalspeed <= -50.
print "Locking steering to srfPrograde".
lock steering to srfPrograde.

wait until alt:radar < 3000.
print "Opening parachutes".
stage.
gear on.

wait until alt:radar = 0.
hudtext(vessel:name + "has landed", 8, 2, 15, green, true).