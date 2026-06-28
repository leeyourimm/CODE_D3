*&---------------------------------------------------------------------*
*& Include          ZRD3FI9010_CLS
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Class (Definition) lcl_event_handler
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.

    CLASS-METHODS :
      on_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      on_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id
                  e_column_id,
      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.



ENDCLASS.

*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_toolbar.

    PERFORM handle_toolbar USING e_object.

  ENDMETHOD.

  METHOD on_hotspot_click.

    PERFORM handle_hotspot_click USING e_row_id
                                       e_column_id.
  ENDMETHOD.

  METHOD on_user_command.

    PERFORM handle_user_command USING e_ucomm.

  ENDMETHOD.


ENDCLASS.
