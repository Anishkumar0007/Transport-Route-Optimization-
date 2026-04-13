CLASS zcit_api_it010 DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_ai_response,
             best_route TYPE string,
             cost       TYPE p LENGTH 13 DECIMALS 2,
             distance   TYPE p LENGTH 10 DECIMALS 2,
             eta_time   TYPE string,
           END OF ty_ai_response.

    CLASS-METHODS calculate_best_route
      IMPORTING iv_source TYPE string
                iv_dest   TYPE string
      RETURNING VALUE(rs_result) TYPE ty_ai_response.
ENDCLASS.

CLASS zcit_api_it010 IMPLEMENTATION.
  METHOD calculate_best_route.
    " 1. If fields are empty, return an error message safely
    IF iv_source IS INITIAL OR iv_dest IS INITIAL.
      rs_result-best_route = '⚠️ Please enter Source and Destination!'.
      RETURN.
    ENDIF.

    " 2. Dynamic Distance Logic (Generates a pseudo-random distance based on city names)
    DATA(lv_base_dist) = strlen( iv_source ) * strlen( iv_dest ) * 12.
    DATA: lv_traffic_delay TYPE i, lv_route_name TYPE string.

    " 3. AI Traffic Simulation (Simulating real-time API data)
    DATA(lv_time_sec) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_random) = lv_time_sec MOD 3. " Returns 0, 1, or 2

    IF lv_random = 0.
      lv_route_name = 'Highway Route (Fastest)'.
      lv_traffic_delay = 10. " 10% delay
    ELSEIF lv_random = 1.
      lv_route_name = 'Bypass Road (Cheapest)'.
      lv_traffic_delay = 5.  " 5% delay
    ELSE.
      lv_route_name = 'City Route (Shortest)'.
      lv_traffic_delay = 45. " Heavy Traffic!
    ENDIF.

    " 4. Calculate Final Values (Distance, Traffic, Cost, Time)
    rs_result-distance = lv_base_dist.
    rs_result-cost = ( lv_base_dist * 12 ) + ( lv_traffic_delay * 50 ). " 12 INR per KM + Traffic cost

    DATA(lv_hours) = ( lv_base_dist / 60 ) + ( lv_traffic_delay / 10 ). " Base speed 60km/h + delays

    rs_result-best_route = |{ iv_source } to { iv_dest } via { lv_route_name } |.
    rs_result-eta_time = |{ lv_hours } Hours (Traffic: { lv_traffic_delay }%)|.
  ENDMETHOD.
ENDCLASS.

.
