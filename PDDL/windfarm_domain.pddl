;; PL and RS project - a.y. 2025-26

(define (domain offshore_wind_farm)
  (:requirements :strips :typing :fluents :disjunctive-preconditions :conditional-effects) 
  (:types 
    drone location - object
    base - location
  ) 

  (:predicates
    (at ?d - drone ?l - location)
    (is_inspected ?l - location)
    (is_turbine ?t - location)
    (severe_fault ?t - location)
    (severe_detected ?t - location)
    (fault_handled ?t - location)
  )

  (:functions
    (fly-cost ?from ?to - location)
    (battery ?d - drone)
    (inspection-cost) 
  )

  ;; ACTION FLY
  (:action fly
    :parameters (?d - drone ?x ?y - location)
    :precondition (and
      (at ?d ?x)
      (> (battery ?d) (fly-cost ?x ?y))
      (or (not (severe_detected ?x)) (fault_handled ?x))
    )
    :effect (and 
      (at ?d ?y) 
      (not (at ?d ?x)) 
      (decrease (battery ?d) (fly-cost ?x ?y))
    )
  )



;; ACTION INSPECT
(:action inspect
    :parameters (?d - drone ?t - location)
    :precondition (and (is_turbine ?t) (at ?d ?t) (> (battery ?d) (inspection-cost)))
    :effect (and 
        (is_inspected ?t) 
        (decrease (battery ?d) (inspection-cost))
        (when (severe_fault ?t) (severe_detected ?t))
    )
)
	
;; ACTION BACKTOBASE: in case of severe fault discovered, return to the base
  (:action backtobase
    :parameters (?d - drone ?x - location ?b - base)
    :precondition (and
        (at ?d ?x)
        (is_inspected ?x)
        (severe_detected ?x) 
        (> (battery ?d) (fly-cost ?x ?b))
    )
    :effect (and 
        (at ?d ?b) 
        (not (at ?d ?x)) 
        (decrease (battery ?d) (fly-cost ?x ?b))
        (fault_handled ?x) 
  )
)

  ;; ACTION RECHARGE
  (:action recharge
    :parameters (?d - drone ?b - base)
    :precondition (and (at ?d ?b) (< (battery ?d) 90))
    :effect (assign (battery ?d) 100)
  )
)
