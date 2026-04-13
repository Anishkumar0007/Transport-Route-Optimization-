CLASS lhc_RouteHdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR RouteHdr RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE RouteHdr.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE RouteHdr.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE RouteHdr.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE RouteHdr.

    METHODS read FOR READ
      IMPORTING keys FOR READ RouteHdr RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK RouteHdr.

    METHODS rba_Stops FOR READ
      IMPORTING keys_rba FOR READ RouteHdr\_Stops FULL result_requested RESULT result LINK association_links.

    METHODS cba_Stops FOR MODIFY
      IMPORTING entities_cba FOR CREATE RouteHdr\_Stops.

    METHODS optimizeRoute FOR MODIFY
      IMPORTING keys FOR ACTION RouteHdr~optimizeRoute RESULT result.
ENDCLASS.



CLASS lhc_RouteHdr IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " Allow all
  ENDMETHOD.



  METHOD earlynumbering_create.
    DATA: lv_max_id TYPE n LENGTH 4.
    DATA: lv_max_db    TYPE zcit_hdr_it010-freightid,
          lv_max_draft TYPE zcit_dhd_it010-freightid.

    SELECT SINGLE FROM zcit_hdr_it010 FIELDS MAX( freightid ) INTO @lv_max_db.
    SELECT SINGLE FROM zcit_dhd_it010 FIELDS MAX( freightid ) INTO @lv_max_draft.

    TRY.
        IF lv_max_db > lv_max_draft AND lv_max_db IS NOT INITIAL.
          lv_max_id = CONV #( lv_max_db+3(4) ).
        ELSEIF lv_max_draft IS NOT INITIAL.
          lv_max_id = CONV #( lv_max_draft+3(4) ).
        ELSE.
          lv_max_id = 0.
        ENDIF.
      CATCH cx_root.
        lv_max_id = 0.
    ENDTRY.

    LOOP AT entities INTO DATA(ls_entity).
      " Check if ID already exists (e.g., during Draft Resume)
      IF ls_entity-FreightId IS INITIAL.
        lv_max_id += 1.

        " 👉 CRITICAL FIX: Added %is_draft mapping!
        APPEND VALUE #( %cid      = ls_entity-%cid
                        %is_draft = ls_entity-%is_draft
                        FreightId = |FR-{ lv_max_id }| ) TO mapped-routehdr.
      ELSE.
        APPEND VALUE #( %cid      = ls_entity-%cid
                        %is_draft = ls_entity-%is_draft
                        FreightId = ls_entity-FreightId ) TO mapped-routehdr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD create.

    DATA(lo_util) = zcit_utl_it010=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entity).

      DATA(ls_db) = CORRESPONDING zcit_hdr_it010( ls_entity MAPPING FROM ENTITY ).

      lo_util->buffer_hdr( ls_db ).

    ENDLOOP.

  ENDMETHOD.



*METHOD update.
*    DATA(lo_util) = zcit_utl_it010=>get_instance( ).
*
*    " 1. READ the existing data first so we don't overwrite it with blanks!
*    READ ENTITIES OF zcit_rth_it010 IN LOCAL MODE
*      ENTITY RouteHdr ALL FIELDS WITH CORRESPONDING #( entities )
*      RESULT DATA(lt_existing).
*
*    LOOP AT entities INTO DATA(ls_update).
*      " 2. Match the update request with the existing database record
*      READ TABLE lt_existing INTO DATA(ls_db) WITH KEY FreightId = ls_update-FreightId.
*
*      " 3. ONLY update the fields the user actually touched (%control = 01)
*      IF ls_update-%control-SourceLoc = if_abap_behv=>mk-on.
*        ls_db-SourceLoc = ls_update-SourceLoc.
*      ENDIF.
*
*      IF ls_update-%control-DestLoc = if_abap_behv=>mk-on.
*        ls_db-DestLoc = ls_update-DestLoc.
*      ENDIF.
*
*      IF ls_update-%control-BestRoute = if_abap_behv=>mk-on.
*        ls_db-BestRoute = ls_update-BestRoute.
*      ENDIF.
*
*      IF ls_update-%control-TotalCost = if_abap_behv=>mk-on.
*        ls_db-TotalCost = ls_update-TotalCost.
*      ENDIF.
*
*      IF ls_update-%control-TotalDist = if_abap_behv=>mk-on.
*        ls_db-TotalDist = ls_update-TotalDist.
*      ENDIF.
*
*      IF ls_update-%control-AiStatus = if_abap_behv=>mk-on.
*        ls_db-AiStatus = ls_update-AiStatus.
*      ENDIF.
*
*      " 4. Save the safely merged record back to the buffer
*      DATA(ls_final_db) = CORRESPONDING zcit_hdr_it010( ls_db ).
*      lo_util->buffer_hdr( ls_final_db ).
*    ENDLOOP.
*  ENDMETHOD.

 METHOD update.
    DATA(lo_util) = zcit_utl_it010=>get_instance( ).
    LOOP AT entities INTO DATA(ls_entity).
      DATA(ls_db) = CORRESPONDING zcit_hdr_it010( ls_entity MAPPING FROM ENTITY ).
      lo_util->buffer_hdr( ls_db ).
    ENDLOOP.
  ENDMETHOD.


  METHOD delete.

    DATA(lo_util) = zcit_utl_it010=>get_instance( ).

    LOOP AT keys INTO DATA(ls_key).
      lo_util->buffer_hdr_del( ls_key-FreightId ).
    ENDLOOP.

  ENDMETHOD.



  METHOD read.

    SELECT FROM zcit_hdr_it010
      FIELDS *
      FOR ALL ENTRIES IN @keys
      WHERE freightid = @keys-FreightId
      INTO TABLE @DATA(lt_db).

    result = CORRESPONDING #( lt_db MAPPING TO ENTITY ).

  ENDMETHOD.



  METHOD lock.
    " Empty for unmanaged
  ENDMETHOD.



  METHOD rba_Stops.
    " Navigation
  ENDMETHOD.



METHOD cba_Stops.
    DATA(lo_util) = zcit_utl_it010=>get_instance( ).
    DATA: lv_max_stop TYPE zcit_itm_it010-stop_id,
          lv_max_draft TYPE zcit_dit_it010-stopid,
          lv_next_id   TYPE int2.

    LOOP AT entities_cba INTO DATA(ls_cba).
      SELECT SINGLE FROM zcit_itm_it010 FIELDS MAX( stop_id ) WHERE freightid = @ls_cba-FreightId INTO @lv_max_stop.
      SELECT SINGLE FROM zcit_dit_it010 FIELDS MAX( stopid ) WHERE freightid = @ls_cba-FreightId INTO @lv_max_draft.

      IF lv_max_stop > lv_max_draft.
        lv_next_id = lv_max_stop + 1.
      ELSE.
        lv_next_id = lv_max_draft + 1.
      ENDIF.

      LOOP AT ls_cba-%target INTO DATA(ls_target).
        DATA(ls_db) = CORRESPONDING zcit_itm_it010( ls_target MAPPING FROM ENTITY ).
        ls_db-freightid = ls_cba-FreightId.
        ls_db-stop_id   = lv_next_id.

        lo_util->buffer_itm( ls_db ).

        " 👉 CRITICAL FIX: Added %is_draft mapping!
        APPEND VALUE #( %cid      = ls_target-%cid
                        %is_draft = ls_cba-%is_draft
                        FreightId = ls_cba-FreightId
                        StopId    = lv_next_id ) TO mapped-routeitm.
        lv_next_id += 1.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD optimizeRoute.
    " 1. Read the CURRENT screen data (What the user just typed)
    READ ENTITIES OF zcit_rth_it010 IN LOCAL MODE
      ENTITY RouteHdr ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_route).

    LOOP AT lt_route ASSIGNING FIELD-SYMBOL(<fs_route>).

      " 2. Call our Smart AI Simulator
      DATA(ls_ai_result) = zcit_api_it010=>calculate_best_route(
                               iv_source = CONV string( <fs_route>-SourceLoc )
                               iv_dest   = CONV string( <fs_route>-DestLoc ) ).

      " 3. Format the AI output to fit nicely in our Fiori table
*DATA(lv_final_status) = |Optimized | && |  { ls_ai_result-eta_time }|.

DATA(lv_final_status) = |Optimized |.

      " 4. Safely Update ONLY the AI fields (Do NOT touch Source/Dest)
      MODIFY ENTITIES OF zcit_rth_it010 IN LOCAL MODE
        ENTITY RouteHdr
        UPDATE FIELDS ( BestRoute TotalCost TotalDist AiStatus )
        WITH VALUE #( ( %tky = <fs_route>-%tky
                        BestRoute = ls_ai_result-best_route
                        TotalCost = ls_ai_result-cost
                        TotalDist = ls_ai_result-distance
                        AiStatus  = lv_final_status ) ).
    ENDLOOP.

    " 5. Read the full updated record to send back to the UI
    READ ENTITIES OF zcit_rth_it010 IN LOCAL MODE
      ENTITY RouteHdr ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_route_updated).

    result = VALUE #( FOR route IN lt_route_updated ( %tky = route-%tky %param = route ) ).
  ENDMETHOD.

ENDCLASS.



CLASS lsc_ZCIT_RTH_IT010 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.



CLASS lsc_ZCIT_RTH_IT010 IMPLEMENTATION.
*
*  METHOD save.
*
*    DATA(lo_util) = zcit_utl_it010=>get_instance( ).
*
*    DATA(lt_hdr) = lo_util->get_hdr_buffer( ).
*    IF lt_hdr IS NOT INITIAL.
*      MODIFY zcit_hdr_it010 FROM TABLE @lt_hdr.
*    ENDIF.
*
*    DATA(lt_del) = lo_util->get_hdr_del_buffer( ).
*    IF lt_del IS NOT INITIAL.
*      DELETE zcit_hdr_it010 FROM TABLE @lt_del.
*    ENDIF.
*
*  ENDMETHOD.


METHOD save.
    DATA(lo_util) = zcit_utl_it010=>get_instance( ).

    " Handle Header Inserts/Updates/Deletes
    DATA(lt_hdr) = lo_util->get_hdr_buffer( ).
    IF lt_hdr IS NOT INITIAL. MODIFY zcit_hdr_it010 FROM TABLE @lt_hdr. ENDIF.
    DATA(lt_del) = lo_util->get_hdr_del_buffer( ).
    IF lt_del IS NOT INITIAL. DELETE zcit_hdr_it010 FROM TABLE @lt_del. ENDIF.

    " ===> NEW: Handle Item Inserts/Updates/Deletes <===
    DATA(lt_itm) = lo_util->get_itm_buffer( ).
    IF lt_itm IS NOT INITIAL. MODIFY zcit_itm_it010 FROM TABLE @lt_itm. ENDIF.
    DATA(lt_itm_del) = lo_util->get_itm_del_buffer( ).
    IF lt_itm_del IS NOT INITIAL. DELETE zcit_itm_it010 FROM TABLE @lt_itm_del. ENDIF.

  ENDMETHOD.



  METHOD cleanup.

    zcit_utl_it010=>get_instance( )->clear_buffer( ).

  ENDMETHOD.

ENDCLASS.
