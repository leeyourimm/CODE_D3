*&---------------------------------------------------------------------*
*& Include          ZRD3SD0008_CLS
*&---------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_toolbar           FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,

      on_user_command      FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

      on_hotspot_click     FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id
                  e_column_id
                  es_row_no,
      " 트리 더블클릭 했을 때
      on_item_double_click FOR EVENT item_double_click OF cl_gui_alv_tree
        IMPORTING node_key
                  fieldname sender,

      on_data_changed      FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.



ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_toolbar.
    " 툴바 추가
    PERFORM handle_toolbar USING e_object.

    " 기존의 툴바 삭제
    PERFORM delete_toolbar USING e_object.
  ENDMETHOD.


  METHOD on_user_command.
    PERFORM edit_plan_order USING e_ucomm.
  ENDMETHOD.


  METHOD on_hotspot_click.
    PERFORM handle_hotspot_click USING e_row_id
                                       e_column_id.
  ENDMETHOD.

  METHOD on_item_double_click.
    PERFORM get_mat_data_0140.
    PERFORM handle_tree_click USING node_key.
  ENDMETHOD.


  METHOD on_data_changed.
    PERFORM handle_data_changed USING er_data_changed.
  ENDMETHOD.

ENDCLASS.
