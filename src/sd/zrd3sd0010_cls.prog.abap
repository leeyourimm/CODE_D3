*&---------------------------------------------------------------------*
*& Include          ZRD3SD9010_CLS
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
        IMPORTING e_ucomm,

      on_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id
                  e_column_id.

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

    " 합계/소계 행 더블클릭 방지
    IF e_row-rowtype IS NOT INITIAL.
      " 073 : 합계행을 선택하셨습니다. 다시 선택하세요.
      MESSAGE s073 DISPLAY LIKE 'W'.
      RETURN.
    ENDIF.


    " 대금청구 아이템 조회
    PERFORM select_billing_item USING e_row
                                      e_column.
    " 헤더 ALV에서 선택한 행 셀 색깔 표시
    PERFORM set_selected_color  USING e_row
                                      e_column
                                      es_row_no.
    " 아이템 ALV에서 관련 정보 세팅
    " 세금 금액
    " 세금 텍스트
    " 총액
    PERFORM set_item.


    MOVE-CORRESPONDING gt_billing_item TO gt_detail.

    PERFORM refresh_alv_0100.

  ENDMETHOD.

  METHOD on_user_command.

    PERFORM handle_user_command USING e_ucomm.

  ENDMETHOD.

  METHOD on_hotspot_click.

    PERFORM handle_hotspot_click USING e_row_id
                                       e_column_id.

  ENDMETHOD.

ENDCLASS.
