/**

Planning & Reasoning project - Offshore wind farm  

This file loads the interpreter and the application file, and has a main 0 and main 1 predicate to run the available controllers.

This file needs to be combined after a configuration file, such as config.pl, is loaded (defining interpreter 1).
    
**/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSULT NECESSARY FILES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- [config].

:- dir(indigolog_plain, F), consult(F).
% :- dir(eval_bat, F), consult(F).   

% 4 - Consult application
:- [offshore_windfarm].


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN PREDICATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main :-
    findall(C, proc(control(C), _), L),
    nl, write(' ----  OFFSHORE WIND FARM  ---- '), nl,
    format('Controllers available: ~w\n', [L]),
    write('Select controller: '),
    read(S),
    (   member(S, L) ->
        format('Executing controller: *~w*\n\n', [S]),
        indigolog(control(S))
    ;   
        write('Invalid selection. Try again.'), nl,
        main
    ).

main(C) :- indigolog(control(C)).


% LEGALITY TASK
/*
set battery level to 50%, check if the drone is able to check all or a subset of the wind-farm turbines avoiding discharge below the battery threshold level.
*/

legality_task :-
	write(' LEGALITY TASK '), nl,
	write('Battery threshold: 20%'), nl,
	write('Remember to set the Initial battery to 50% in the problem file!'), nl,
	write('Executing SMART controller'), nl,
	indigolog(control(smart)).
		
	
% PROJECTION TASK
/*
we can consider the following schedule of inspection [fly(base, T2), inspect(T2), fly(T2, T1), inspect(T1), fly(T1, base), fly(base, T3), inspect(T3), fly(T3, base)]; and query if the drone is at the base with a good battery level (e.g. 30%).
*/

projection_task :-
	write(' PROJECTION TASK '), nl,
	
	indigolog([
            fly(t2), 
            inspect(t2), 
            fly(t1), 
            inspect(t1), 
            fly(base),
            % charge(drone), 
            fly(t3),
            inspect(t3), 
            fly(base),
            ?(and(current_location = base, battery_level >= 30))
        ]).
        

% INTERACTIVE LEGALITY TASK 

legality_task_interactive :-
    write(' INTERACTIVE LEGALITY TASK '), nl,
    write('Initial battery: 100%'), nl,
    write('Write sequence of actions in the format: [ A_1, A_2, ... ].'), nl,
    read(SEQ), nl,
    
    indigolog(SEQ).
