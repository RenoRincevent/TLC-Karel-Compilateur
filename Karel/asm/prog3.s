_start:
	seti r0, #0
	seti r1, #1
	invoke 4, 0, 0
	invoke 1, 0, 0
	invoke 1, 0, 0
	invoke 1, 0, 0
	invoke 1, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
search:
	invoke 11, 0, 0
	goto_eq end, r0, r1
	invoke 1, 0, 0
	goto search
end:
	stop	
