%{

open Quad
open Common
open Comp
open Karel


%}

%token BEGIN_PROG
%token BEGIN_EXEC
%token END_EXEC
%token END_PROG

%token MOVE
%token TURN_LEFT
%token TURN_OFF

%token SEMI
%token BEGIN
%token END

%token PICK_BEEPER
%token PUT_BEEPER
%token NEXT_TO_A_BEEPER
%token NOT_NEXT_TO_A_BEEPER
%token <int> INT

%token FRONT_IS_CLEAR
%token FRONT_IS_BLOCKED
%token LEFT_IS_CLEAR
%token LEFT_IS_BLOCKED
%token RIGHT_IS_CLEAR 
%token RIGHT_IS_BLOCKED

%token FACING_NORTH 
%token NOT_FACING_NORTH
%token FACING_EAST
%token NOT_FACING_EAST
%token FACING_SOUTH
%token NOT_FACING_SOUTH
%token FACING_WEST
%token NOT_FACING_WEST
%token ANY_BEEPERS_IN_BEEPER_BAG
%token NO_BEEPERS_IN_BEEPER_BAG

%token ITERATE
%token TIMES
%token IF
%token THEN
%token ELSE
%token WHILE 
%token DO
%token DEFINE_NEW_INSTRUCTION
%token AS
%token <string> ID


/*Cela permet lors du conflit shift/reduce sur le ELSE de donner la priorite au shift

Le else va s'appliquer au then le plus proche (associativite a gauche)*/

%left THEN
%left ELSE


%type <unit> prog
%start prog

%%

prog:	BEGIN_PROG define BEGIN_EXEC stmts_opt END_EXEC END_PROG
			{ () }
;

define: /* empty */ { () }
|	jump_sp define_new define { backpatch $1 (nextquad()) }
;

define_new: DEFINE_NEW_INSTRUCTION ID AS jump stmts { (if (is_defined $2) then raise (SyntaxError "sousprog existe déjà") else (define $2 $4)); gen (RETURN) }
;

stmts_opt:	/* empty */		{ () }
|			stmts			{ () }
;

stmts:		stmt			{ () }
|			stmts SEMI stmt	{ () }
|			stmts SEMI		{ () }
;

special_stmt: simple_stmt { () }
| 	BEGIN stmts END {()}
| 	ITERATE iter_stmt TIMES special_stmt { gen (GOTO($2)); backpatch $2 (nextquad()) }
|	WHILE jump if_test DO special_stmt { gen (GOTO($2)); backpatch $3 (nextquad ()) }
| 	IF if_test THEN else_jump_spe jump ELSE special_stmt {backpatch $2 ($5); backpatch $4 (nextquad())}
|	ID { let adr = (get_define $1) in gen (CALL (adr)) }
;

stmt:		simple_stmt { () }
| 	BEGIN stmts END {()}
| 	ITERATE iter_stmt TIMES stmt { gen (GOTO($2)); backpatch $2 (nextquad()) }
|	WHILE jump if_test DO stmt { gen (GOTO($2)); backpatch $3 (nextquad ()) }
|	IF if_test THEN stmt { backpatch $2 (nextquad()) }
|	IF if_test THEN else_jump_spe jump ELSE stmt { backpatch $2 ($5); backpatch $4 (nextquad()) }
|	ID { let adr = (get_define $1) in gen (CALL (adr)) }
;

simple_stmt: TURN_LEFT { gen (INVOKE (turn_left, 0, 0)) }
|	TURN_OFF { gen STOP  }
|	MOVE { gen (INVOKE (move, 0, 0)) }
|	PICK_BEEPER { gen (INVOKE (pick_beeper, 0, 0)) }
|	PUT_BEEPER { gen (INVOKE (put_beeper, 0, 0)) }
;


else_jump_spe: special_stmt {
	let a = nextquad() in
	let _ = gen (GOTO 0) in
	a
}
;

jump: { let a = nextquad() in a}
; 
		

if_test:	test { let v = new_temp()
			in let _ = gen (SETI(v,0))
			in let a = nextquad()
			in let _ = gen(GOTO_EQ(0, $1, v))
			in a }
;

iter_stmt: INT {
	let vp = new_temp() in
	let _ = gen (SETI (vp, $1)) in
	let zero = new_temp() in
	let _ = gen (SETI (zero, 0)) in
	let un = new_temp() in
	let _ = gen (SETI (un, 1)) in
	let a = nextquad () in
	let _ = gen (GOTO_EQ (0, zero, vp)) in
 	let _ = gen (SUB (vp, vp, un)) in
	a
}
;

jump_sp: {let a = nextquad() in 
	let _ = gen (GOTO(0)) in 
	a}
;

	
test : NEXT_TO_A_BEEPER { let d = new_temp() in 
		gen (INVOKE (next_beeper, d, 0)); d }
|	NOT_NEXT_TO_A_BEEPER { let d = new_temp() in 
		gen (INVOKE (no_next_beeper, d, 0)); d }
|	FRONT_IS_CLEAR	{ let d = new_temp() in 
		gen (INVOKE (is_clear, front ,d)); d }
|	FRONT_IS_BLOCKED { let d = new_temp() in
		gen (INVOKE (is_blocked, front , d)); d }
|	LEFT_IS_CLEAR { let d = new_temp() in 
		gen (INVOKE (is_clear, left, d)); d }
|	LEFT_IS_BLOCKED { let d = new_temp() in 
		gen (INVOKE (is_blocked, left , d)); d }
|	RIGHT_IS_CLEAR { let d = new_temp() in 
		gen (INVOKE (is_clear, right, d)); d }
|	RIGHT_IS_BLOCKED { let d = new_temp() in 
		gen (INVOKE (is_blocked, right, d)); d }
|	FACING_NORTH { let d = new_temp() in 
		gen (INVOKE (facing, north, d)); d }
|	NOT_FACING_NORTH { let d = new_temp() in 
		gen (INVOKE (not_facing, north, d)); d }
|	FACING_EAST { let d = new_temp() in
		gen (INVOKE (facing, east, d)); d }
|	NOT_FACING_EAST { let d = new_temp() in 
		gen (INVOKE (not_facing, east, d)); d }
|	FACING_SOUTH { let d = new_temp() in
		gen (INVOKE (facing, south, d)); d }
|	NOT_FACING_SOUTH { let d = new_temp() in 
		gen (INVOKE (not_facing, south, d)); d}
|	FACING_WEST { let d = new_temp() in 
		gen (INVOKE (facing, west, d)); d }
|	NOT_FACING_WEST { let d = new_temp() in 
		gen (INVOKE (not_facing, west, d)); d }
|	ANY_BEEPERS_IN_BEEPER_BAG { let d = new_temp() in 
		gen (INVOKE (any_beeper, d, 0)); d }
|	NO_BEEPERS_IN_BEEPER_BAG { let d = new_temp() in 
		gen (INVOKE (no_beeper, d, 0)); d }
;


