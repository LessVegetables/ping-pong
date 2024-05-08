# this is borris v0.3.0:
# Y = (Yo + (Vy * Sx) / Vx) % 32

# Vy = (Vy * Sx)
# <=>
# t = Sx
# while t > 0:
#		Vy += Vy
#		t --



# (Vy / Vx) = t
# <=>
# t = 0
# while Vy > Vx:
#		Vy -= Vx
#		t ++

# Yo = Yo (+/-) t

#NOT REALLY # Yo %= 32 (cut of the top 3 bits essentially) —— example: 64 = 01000000

# Vy: 0xe0 == 0 => going up		(Vy >= 0)
#	  0xe0 == 1 => going down	(Vy < 0)

asect 0xf0
Sx:
asect 0xf1
Sy:
asect 0xf2
Vx:
asect 0xf3
Vy:
asect 0xf4
Y:

asect 0x04

borris:
	ldi r0, SX
	ld r0, r0
	ldi r1, Sx
	st r1, r0
	ldi r0, Sx		# Load the address of SxIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until nz
	
	ldi r0, 0x00	# Load the address for Sx
	st r0,r1		# Store Sx at 0x00
	
	ldi r0, SY
	ld r0, r0
	ldi r1, Sy
	st r1, r0
	ldi r0, Sy		# Load the address of SyIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until nz
	
	ldi r0, 0x01	# Load the address for Sy
	st r0,r1		# Store Sy at 0x01
	
	ldi r0, VX
	ld r0, r0
	ldi r1, Vx
	st r1, r0
	ldi r0, Vx		# Load the address of VxIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until nz
	
	ldi r0, 0x02	# Load the address for Vx
	st r0,r1		# Store Vx at 0x02
	
	ldi r0, VY
	ld r0, r0
	ldi r1, Vy
	st r1, r0
	ldi r0, Vy		# Load the address of VyIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until nz

	# Vy: 0xe0 == 0 => going up		(Vy >= 0)
	#	   0xe0 == 1 => going down (Vy < 0)
	ldi r0, 0xe0
	if
		tst r1
	is	mi
		neg r1
		ldi r2, 1
	else
		ldi r2, 0
	fi
	st r0, r2
	
	ldi r0, 0x03	# Load the address for Vy
	st r0,r1		# Store Vy at 0x03
	

	# Begin: Vy = (Vy * Sx)
	ldi r2, 0x00		# t = Sx
	ld r2, r2
	
	ldi r0, 0x03	# Vy copy
	ld r0, r0
	
	ldi r1, 0x03	# Vy
	ld r1, r1

	# Vy = (Vy * Sx) 
	while			# while t > 0:
		dec r2		# t --
	stays nz
		add r0, r1	# Vy += Vy
	wend
	# neg r2
	# End: Vy = (Vy * Sx)

	# Begin: t = (Vy / Vx)
	# Vy is loaded in r1
	
	ldi r0, 0x02  # Vx
	ld r0, r0
	
	ldi r3, 0		# t
	
	# t = (Vy / Vx)
	while
		cmp r1, r0	# while Vy > Vx:
	stays	nz
		inc r3		# t++
		neg r0		# Vy -= Vx
		add r0, r1
		neg r0
	wend
	inc r3
	# End: t = (Vy / Vx)
	
	
	# t is loaded into r3
	# Begin: Yo = Yo (+/-) t
	ldi r0, 0x01	# Sy (<=> Yo)
	ld r0, r0
	
	ldi r1, 0xe0	# sign of Vy
	ld r1, r1
	
	if
		tst r1
	is nz
		neg r3
	fi
	add r3, r0
	# End: Yo = Yo (+/-) t
	
	
	# Begin: Ynew %= 32
	# Ynew loaded into r0
	ldi r1, 0
	ldi r2, 32
	while
		cmp r0, r1
	stays mi # negative
		add r2, r0
	wend
	
	ldi r1, 31
	ldi r2, -32
	while
		cmp r1, r0
	stays mi # while 31 - y stays negative
		add r2, r0
	wend
	# End: Ynew %= 32

	ldi r1, 0xf4	# New Y
	st r1, r0
	
	br borris          # Brings execution back to the beggining

INPUTS>
VX:      dc 1   # replace these with your choice
VY:      dc -2   # of unsigned numbers for testing
SX:      dc 20
SY:      dc 2
#ENDINPUTS>

# Y: ds 1    # one byte reserved for the remainder
end
