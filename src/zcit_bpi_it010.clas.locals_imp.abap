CLASS lhc_RouteItm DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE RouteItm.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE RouteItm.
    METHODS read FOR READ IMPORTING keys FOR READ RouteItm RESULT result.
    METHODS rba_Route FOR READ IMPORTING keys_rba FOR READ RouteItm\_Route FULL result_requested RESULT result LINK association_links.
ENDCLASS.



CLASS lhc_RouteItm IMPLEMENTATION.

  METHOD update.

    DATA(lo_util) = zcit_utl_it010=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entity).

      DATA(ls_db) = CORRESPONDING zcit_itm_it010( ls_entity MAPPING FROM ENTITY ).

      lo_util->buffer_itm( ls_db ).

    ENDLOOP.

  ENDMETHOD.



  METHOD delete.

    DATA(lo_util) = zcit_utl_it010=>get_instance( ).

    LOOP AT keys INTO DATA(ls_key).

      DATA(ls_del_itm) = VALUE zcit_itm_it010(
                           freightid = ls_key-FreightId
                           stop_id   = ls_key-StopId ).

      lo_util->buffer_itm_del( ls_del_itm ).

    ENDLOOP.

  ENDMETHOD.



  METHOD read.

    SELECT FROM zcit_itm_it010
      FIELDS *
      FOR ALL ENTRIES IN @keys
      WHERE freightid = @keys-FreightId
        AND stop_id   = @keys-StopId
      INTO TABLE @DATA(lt_db).

    result = CORRESPONDING #( lt_db MAPPING TO ENTITY ).

  ENDMETHOD.



  METHOD rba_Route.

    " Read Parent Header from Child
    SELECT FROM zcit_hdr_it010
      FIELDS *
      FOR ALL ENTRIES IN @keys_rba
      WHERE freightid = @keys_rba-FreightId
      INTO TABLE @DATA(lt_headers).

    result = CORRESPONDING #( lt_headers MAPPING TO ENTITY ).

  ENDMETHOD.

ENDCLASS.
