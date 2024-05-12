# this is borris v1.0.0:
# Y = (Yo + (Vy * Sx) / Vx) % 32

# Four steps:
# 1. Vy  =  (Vy * Sx)
# 2. t   =  (Vy / Vx)
# 3. Yo  =   Yo (+/-) t
# 4. Yo %=   32

# Sign of Vy and Ynew
# 0xe0 == 0 => positive
# 0xe0 == 1 => negative

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
asect 0xf5
Flag:

asect 0x04

borris:
	ldi r0, Flag
	do      		# Begin the input read loop
		ld r0,r1	# Load r1 from data memory 
       tst r1		# Test if r1 is 0
	until nz		# if Flag is 1 — the programm starts
	
	ldi r0, SX
	ld r0, r0
	ldi r1, 0x00
	st r1, r0
	
	ldi r0, SY
	ld r0, r0
	ldi r1, 0x01
	st r1, r0
	
	ldi r0, VX
	ld r0, r0
	ldi r1, 0x02
	st r1, r0
	
	ldi r0, VY
	ld r0, r0
	# Vy: 0xe0 == 0 => going up		(Vy >= 0)
	#   : 0xe0 == 1 => going down 	(Vy < 0)
	if
		tst r0
	is	mi
		neg r0
		ldi r2, 1
	else
		ldi r2, 0
	fi
	ldi r1, 0x03
	st r1, r0
	ldi r3, 0xe0 # adr of sign bit of Vy
	st r3, r2
	
# Begin: Vy = (Vy * Sx)
	# Vy is in r0
	ldi r1, 0x00	# Sx
	ld r1, r1
	ldi r2, 0		# res
	
	while
		tst r1
	stays nz
		if
			shr r1
		is cs
			add r0, r2
		fi
		shl r0
	wend
# End: Vy = (Vy * Sx)
	# Vy is loaded in r2
	

# Begin: t = (Vy / Vx)
	# Vy is loaded in r2
	move r2, r0	# Vy
	
	ldi r1, 0x02	# Vx
	ld r1, r1
	
	ldi r2, 0x02	# temp (also Vx)
	ld r2, r2
	
	ldi r3, 0 		# result
	
	# Stage 1
	while
		cmp r0, r1		# a - b
	stays pl			# not negative
		tst r1
		shl r1
	wend
	shr r1
	
	
	# Stage 2 and 3
	while
		cmp r1, r2			# bnew - b	
	stays pl				# not negative
		if
			cmp r0, r1
		is pl
			neg r1
			add r1, r0
			neg r1
			
			inc r3
			shl r3
			shr r1
		else
			if
				cmp r1, r2
			is le
				tst r3
				shl r3
				break
			fi
			tst r1
			shr r1			# shift b right
			shl r3			# shift ans right
		fi
	wend
	shr r3
# End: t = (Vy / Vx)
	# t is loaded in r3
	
	
# Begin: Sy = Sy (+/-) t
	# t is loaded into r3

	ldi r0, 0x01	# Sy
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
	# Ynew (Yo or Sy) is loaded into r0
	
	
# Begin: % 32
	ldi r1, 0xe0	# sign bit for Ynew 
	ldi r2, 0
	if
		tst r0
	is mi
		neg r0
		ldi r2, 1
	fi
	st r1, r2		# store the sign bit
	
	
	ldi r1, 31
	if					# if (Ynew > 31) then we do all the %32 shenanigans
		cmp r1, r0		# 31 - Ynew
	is	mi 				# negative
		tst r0
		
		shl r0
		shl r0
			
		if
			shl r0
		is cs
			ldi r3, 1	# sign bit for 6th bit
		else
			ldi r3, 0	# sign bit for 6th bit
		fi
		
		tst r0
		shr r0
		shr r0
		shr r0
		
		xor r3, r2		# ideally: sign(Y) is loaded in r2, and 6th bit in r3 already
		
		if
			tst r2
		is nz
			# y = 31 - (y % 32)
			# remember, r1 already contains 31 (see line 190)
			neg r0
			add r1, r0
			neg r0
		fi
	fi
# End: % 32

	ldi r1, 0xf4	# New Y
	st r1, r0
	
	br borris          # Brings execution back to the beggining

INPUTS>
SX:      dc 20 	# dX (distance from ball to wall)
SY:      dc 2		# Y coord of ball
VX:      dc 1		# X vel of ball (MUST be positive)
VY:      dc -2		# Y vel of ball
ENDINPUTS>

# Y: ds 1    # one byte reserved for the remainder
end
