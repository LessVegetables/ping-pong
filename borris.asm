# this is borris:
# Y = (Yo + Vy * (Sx / Vx)) % 32

# (Sx / Vx) = t
# <=>
# while Sx > Vx:
#		Sx -= Vx
#		t ++

# Vy * t
# Yo + Vy * t
# <=>
# for i in range(t):
# 		Yo += Vy

# Yo %= 32 (cut of the top 3 bits essentially) —— example: 64 = 01000000

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
	ldi r0, Sx		# Load the address of SxIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until gt
	
	ldi r0, 0x00	# Load the address for Sx
	st r0,r1		# Store Sx at 0x00
	
	
	ldi r0, Sy		# Load the address of SyIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until gt
	
	ldi r0, 0x01	# Load the address for Sy
	st r0,r1		# Store Sy at 0x01
	
	
	ldi r0, Vx		# Load the address of VxIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until gt
	
	ldi r0, 0x02	# Load the address for Vx
	st r0,r1		# Store Vx at 0x02
	
	
	ldi r0, Vy		# Load the address of VyIO
	do      		# Begin the keyboard read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until gt
	
	ldi r0, 0x03	# Load the address for Vy
	st r0,r1		# Store Vy at 0x03
	

	ldi r2, 0		# t
	
	ldi r0, 0x00	# Sx
	ld r0, r0
	
	ldi r1, 0x02	# Vx
	ld r1, r1
	
	# (Sx / Vx) = t
	while
		cmp r0, r1
	stays gt
		neg r1
		add r1, r0
		neg r1
		inc r2
	wend
	inc r2
	
	ldi r0, 0x01	# Sy
	ld r0, r0
	
	ldi r1, 0x03  # Vy
	ld r1, r1
	
	
	# Yo = Yo + Vy * t
	while
		dec r2
	stays	nz
		add r1, r0
	wend
	add r1, r0
	
	
	# r0 %= 32
	shl r0
	shl r0
	shl r0
	shr r0
	shr r0
	shr r0
	
	ldi r1, 0xf4	# New Y
	st r1, r0
	
	br borris          # Brings execution back to the beggining

#INPUTS>
#Vx:      dc 1   # replace these with your choice
#Vy:      dc 1   # of unsigned numbers for testing
#Sx:      dc 10
#Sy:      dc 31
#ENDINPUTS>

# Y: ds 1    # one byte reserved for the remainder
end
