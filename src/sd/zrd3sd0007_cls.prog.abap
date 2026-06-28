*&---------------------------------------------------------------------*
*& Include          ZRD3SD9007_CLS
*&---------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,

      on_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row
                  e_column
                  es_row_no,

      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.

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


  METHOD on_double_click.
    PERFORM handle_double_click  USING e_row
                                       e_column
                                       es_row_no.
  ENDMETHOD.

  METHOD on_user_command.
    PERFORM filter_item USING e_ucomm.
  ENDMETHOD.

ENDCLASS.
