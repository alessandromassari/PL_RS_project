/**
Offshore wind farm  
Planning & Reasoning project - a.y. 2025-26
**/

% Interface to the outside world via read and write
execute(A, SR) :- ask_execute(A, SR).
exog_occurs(_) :- fail.

% STATIC FACTS: topology of the problem

location(L) :- member(L, [t1, t2, t3, base]).

% route(from, to, cost) as in PDDL 
route(base, t1, 10).
route(t1, base, 20).

route(base, t2, 30). %100 in pddl
route(t2, base, 10).

route(base, t3, 20).
route(t3, base, 10).

route(t1, t2, 30).
route(t2, t1, 10).

route(t1, t3, 20).
route(t3, t1, 10).

route(t2, t3, 40).
route(t3, t2, 20).

% Add the following route to make 'True' the basic controller
% route(t3, base, 4).

is_turbine(t1).
is_turbine(t2).
is_turbine(t3).

% FLUENTS

prim_fluent(current_location).
prim_fluent(inspected(T)) :- is_turbine(T).
prim_fluent(severe_fault).
prim_fluent(battery_level).

% PRIMITIVE ACTIONS

prim_action(fly(L)) :- location(L).
prim_action(inspect(T)) :- is_turbine(T).
prim_action(charge(_Drone)).
prim_action(report(_Drone)).

% PRECONDITIONS

poss(fly(To), and(neg(current_location = To), 
    and(route(current_location, To, Cost), battery_level >= Cost))).

poss(inspect(T), and(current_location = T, 
    and(is_turbine(T), neg(inspected(T) = true)))).

poss(charge(_Drone), current_location = base).

poss(report(_Drone), current_location = base).


% CAUSAL LAWS (Successor State Axioms)

% SSA for current_location
causes_val(fly(To), current_location, To, true).

% SSA for inspected
causes_val(inspect(T), inspected(T), true, true).

% SSA for severe_fault logic to detect faults (e.g. on t2)
causes_val(inspect(t2), severe_fault, true, true).

% reset the severe fault after reported
causes_val(report(_), severe_fault, false, true).

% SSA for battery_level
causes_val(fly(To), battery_level, NewVal, 
    and(route(current_location, To, Cost), NewVal is battery_level - Cost)).

causes_val(inspect(_), battery_level, NewVal, 
    NewVal is battery_level - 5).

% reset the battery 100% charging level and low battery condition
causes_val(charge(_), battery_level, 100, true).

% SSA for current_location
current_location(V, do(A, S)) :-
    causes_val(A, current_location, V, true) ;
    (current_location(V, S), \+ (causes_val(A, current_location, _, true))).

% SSA for inspected
inspected(T, V, do(A, S)) :-
    causes_val(A, inspected(T), V, true) ;
    (inspected(T, V, S), \+ (causes_val(A, inspected(T), _, true))).

% SSA for severe_fault 
severe_fault(V, do(A, S)) :-
    causes_val(A, severe_fault, V, true) ;
    (severe_fault(V, S), \+ (causes_val(A, severe_fault, _, true))).

% SSA for battery_level
battery_level(V, do(A, S)) :-
    causes_val(A, battery_level, V, _) ;
    (battery_level(V, S), \+ (causes_val(A, battery_level, _, _))).


% INITIAL STATE

initially(current_location, base).
initially(inspected(_), false).
initially(severe_fault, false).
initially(battery_level, 90).


% HELPER PROCEDURES

proc(at(L), current_location = L).
proc(turbine_needs_inspection(T), and(is_turbine(T), neg(inspected(T) = true))).

% Recharge procedure: fly to base if needed, then charge
proc(recharge,
    [
        if(neg(current_location = base),
            [
                fly(base)
            ],
            ?(write('>>Already at base...\n'))
        ),
        charge(drone),
        ?(write('>>Battery charged.\n'))
    ]
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Controllers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BASIC CONTROLLER (1): inspect all turbines, then return to the base

proc(control(basic),
    [
        while(some(t, turbine_needs_inspection(t)),
            pi(t, [
                ?(turbine_needs_inspection(t)),
                fly(t),
                inspect(t)
                ]
            )
        ),
        fly(base)
    ]
).

% SMART CONTROLLER (2): Adopt prioritized interrupts to handle critical conditions

proc(control(smart),
            
        prioritized_interrupts([
        
            % Highest priority: low battery - return to recharge
            interrupt(
            	battery_level < 40,
                [
                    ?(write('>>LOW BATTERY! \n')),
                    recharge
                ]
            ),

	    % Second priority: severe fault detected - return immediately
            interrupt(
                severe_fault = true,
                [
                    ?(write('>>SEVERE FAULT DETECTED! Report to Base...\n')),
                    fly(base),
                    report(drone)
                ]
            ),
            
            % Lowest priority: normal inspection loop
            interrupt(
                t, turbine_needs_inspection(t),
                [
                    fly(t),
                    inspect(t)  
                ])
        ])
).

