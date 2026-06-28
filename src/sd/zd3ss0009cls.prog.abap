*&---------------------------------------------------------------------*
*& Include          ZD3SS0009CLS
*&---------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,

      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

      on_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row
                  e_column,

      on_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id
                  e_column_id
                  es_row_no,

      on_button_click for event button_click of cl_gui_alv_grid
        IMPORTING es_col_id
                  es_row_no.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_toolbar.
    PERFORM handle_toolbar USING e_object.
  ENDMETHOD.


  METHOD on_user_command.
    PERFORM search_billing_status USING e_ucomm.
  ENDMETHOD.

  METHOD on_double_click.
*    PERFORM handle_double_click USING e_row
*                                      e_column.
  ENDMETHOD.

  METHOD on_hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id
                                       e_column_id.
  ENDMETHOD.

  METHOD on_button_click.
    PERFORM click_create_bill using es_col_id
                                    es_row_no.
  ENDMETHOD.

ENDCLASS.
