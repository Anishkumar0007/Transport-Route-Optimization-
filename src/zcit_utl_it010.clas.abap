CLASS zcit_utl_it010 DEFINITION PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.

    " ✅ Fully typed tables (MANDATORY in ABAP Cloud)
    TYPES:
      tt_hdr TYPE STANDARD TABLE OF zcit_hdr_it010 WITH EMPTY KEY,
      tt_itm TYPE STANDARD TABLE OF zcit_itm_it010 WITH EMPTY KEY.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcit_utl_it010.

    " Header Buffers
    METHODS buffer_hdr
      IMPORTING is_hdr TYPE zcit_hdr_it010.

    METHODS buffer_hdr_del
      IMPORTING iv_freightid TYPE zcit_hdr_it010-freightid.

    METHODS get_hdr_buffer
      RETURNING VALUE(rt_hdr) TYPE tt_hdr.

    METHODS get_hdr_del_buffer
      RETURNING VALUE(rt_hdr_del) TYPE tt_hdr.

    " Item Buffers
    METHODS buffer_itm
      IMPORTING is_itm TYPE zcit_itm_it010.

    METHODS buffer_itm_del
      IMPORTING is_itm TYPE zcit_itm_it010.

    METHODS get_itm_buffer
      RETURNING VALUE(rt_itm) TYPE tt_itm.

    METHODS get_itm_del_buffer
      RETURNING VALUE(rt_itm_del) TYPE tt_itm.

    METHODS clear_buffer.

  PRIVATE SECTION.

    CLASS-DATA mo_instance TYPE REF TO zcit_utl_it010.

    DATA:
      mt_hdr_buffer TYPE tt_hdr,
      mt_hdr_delete TYPE tt_hdr,
      mt_itm_buffer TYPE tt_itm,
      mt_itm_delete TYPE tt_itm.

ENDCLASS.



CLASS zcit_utl_it010 IMPLEMENTATION.

  METHOD get_instance.
    IF mo_instance IS INITIAL.
      CREATE OBJECT mo_instance.
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.





  METHOD buffer_hdr.
    DELETE mt_hdr_buffer WHERE freightid = is_hdr-freightid.
    APPEND is_hdr TO mt_hdr_buffer.
  ENDMETHOD.

  METHOD buffer_hdr_del.
    APPEND VALUE #( freightid = iv_freightid ) TO mt_hdr_delete.
  ENDMETHOD.

  METHOD get_hdr_buffer.
    rt_hdr = mt_hdr_buffer.
  ENDMETHOD.

  METHOD get_hdr_del_buffer.
    rt_hdr_del = mt_hdr_delete.
  ENDMETHOD.




  METHOD buffer_itm.
    DELETE mt_itm_buffer
      WHERE freightid = is_itm-freightid
        AND stop_id   = is_itm-stop_id.

    APPEND is_itm TO mt_itm_buffer.
  ENDMETHOD.

  METHOD buffer_itm_del.
    APPEND is_itm TO mt_itm_delete.
  ENDMETHOD.

  METHOD get_itm_buffer.
    rt_itm = mt_itm_buffer.
  ENDMETHOD.

  METHOD get_itm_del_buffer.
    rt_itm_del = mt_itm_delete.
  ENDMETHOD.



  METHOD clear_buffer.
    CLEAR: mt_hdr_buffer, mt_hdr_delete, mt_itm_buffer, mt_itm_delete.
  ENDMETHOD.

ENDCLASS.
