asect  0x00

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

# optional: Yo %= 32 (cut of the top 3 bits essentially) —— example: 64 = 01000000

	ldi r2, 0		# t
	
	ldi r0, Sx
	ld r0, r0
	
	ldi r1, Vx
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
	
	ldi r0, Sy
	ld r0, r0
	
	ldi r1, Vy
	ld r1, r1
	
	
	# Yo = Yo + Vy * t
	while
		dec r2
	stays	nz
		add r1, r0
	wend
	add r1, r0
	
	
	# r0 %= 32
	shla r0
	shla r0
	shla r0
	shra r0
	shra r0
	shra r0
	
	ldi r1, Y
	st r1, r0
	

	ldi r0, Y
	halt          # Brings execution to a halt


INPUTS>
Vx:      dc 1   # replace these with your choice
Vy:      dc 1   # of unsigned numbers for testing
Sx:      dc 10
Sy:      dc 31
ENDINPUTS>

Y: ds 1    # one byte reserved for the remainder
end


