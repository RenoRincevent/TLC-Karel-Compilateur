_start:
	seti r0, #0
	seti r1, #1
avancer:
	seti r0, #0
	invoke 11, 0, 0
	goto_eq end, r0, r1		@si on trouve le beeper, on s'arrete
	seti r0, #0
	invoke 6, 1, 0			
	goto_eq tournerntow, r0, r1	@si on est devant un mur, on tourne
	invoke 1, 0, 0			@sinon on continue d'avancer
	goto avancer
tournerntow:				@si on fait face au mur du nord, on tourne a gauche
	seti r0, #0
	invoke 6, 2, 0
	goto_eq tournerntoe, r0, r1
	seti r0, #0
	invoke 7, 3, 0
	goto_eq tournerstow, r0, r1
	invoke 2, 0, 0
	invoke 1, 0, 0
	invoke 2, 0, 0
	goto avancer
tournerstow:				@si on fait face au mur du sud on tourne a droite (donc trois fois a gauche)
	seti r0, #0
	invoke 6, 3, 0
	goto_eq tournerstoe, r0, r1
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 1, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	goto avancer
tournerntoe:			@si on ne trouve pas le beeper, on retourne en arriere
	invoke 2, 0, 0		@pour voir si il n'est pas a l'est			
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 1, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	invoke 2, 0, 0
	goto avancerbis
tournerstoe:
	seti r0, #0
	invoke 7, 1, 0
	goto_eq tournerntoe, r0, r1
	invoke 2, 0, 0
	invoke 1, 0, 0
	invoke 2, 0, 0
	goto avancerbis
avancerbis:
	seti r0, #0
	invoke 11, 0, 0
	goto_eq end, r0, r1
	seti r0, #0
	invoke 6, 1, 0
	goto_eq testfin, r0, r1
	invoke 1, 0, 0
	goto avancerbis
testfin:	
	seti r0, #0
	invoke 6, 2, 0		@cas ou il arrive a l'extreme sud ouest de la map,
	goto_eq end, r0, r1	@ il a fait toutes les cases sans trouver de beeper donc on l'arrete
	goto tournerstoe	
end:
	stop
