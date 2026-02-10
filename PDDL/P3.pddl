;; PL and RS project - a.y. 2025/26 
;; PDDL Problem file 3

(define (problem problem_2)
  (:domain offshore_wind_farm)

  (:objects
    drone1 drone2 drone3 - drone
    t1 t2 t3 ship - location
    Base - base
  )

  (:init
    ;; Initial State
    (at drone1 Base)
    (at drone2 Base)
    (at drone3 Base)
    (is_turbine t1)
    (is_turbine t2)
    (is_turbine t3)
    (severe_fault t1)
    (severe_fault t3)
    

    ;; BATTERY SETUP
    (= (battery drone1) 80)     ;; Drone starts with 80 units
    (= (battery drone2) 80) 
    (= (battery drone3) 80)
    (= (inspection-cost) 5)        ;; Inspection costs 5 units

    ;; T1 -Base 
    (= (fly-cost Base t1) 10)
    (= (fly-cost t1 Base) 20)

    ;; 2. From T1 to T2 is CHEAP 
    (= (fly-cost t1 t2) 30)
    (= (fly-cost t2 t1) 10)

    ; From BASE to T2 is IMPOSSIBLE/EXPENSIVE (100) owing to the Wind!
    ;; This forces the drone to go to T1 first, because 
    ;; it only has <100 battery! It cannot afford the direct flight.
    (= (fly-cost Base t2) 100)
    (= (fly-cost t2 Base) 10)
    
    ;; From T1 to T3 and back
    (= (fly-cost t1 t3) 20)
    (= (fly-cost t3 t1) 10)
    
    ;; From T2 - T3 and back
    (= (fly-cost t2 t3) 40)
    (= (fly-cost t3 t2) 20)
    
    ;; From T3 - BASE and back
    (= (fly-cost t3 Base) 10)
    (= (fly-cost Base t3) 20)
    
    ;; Self loops (cost 0)
    (= (fly-cost Base Base) 0)
    (= (fly-cost t1 t1) 0)
    (= (fly-cost t2 t2) 0)
    (= (fly-cost t3 t3) 0)
   
  )

  (:goal 
    (and
      (fault_handled t3)
      (is_inspected t2)
      (fault_handled t1)
      
      ;;Return to Base
      (at drone1 Base)
      (at drone2 Base) 
      (at drone3 Base)

      ;; BATTERY 	
      (> (battery drone1) 15)     ;; safety margin of at least 15 battery
      (> (battery drone2) 15) 
      (> (battery drone3) 15) 
    )
  )
)
