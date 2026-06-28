*&---------------------------------------------------------------------*
*& Include          ZRD3FI9010_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE clear_ok_code OUTPUT.

  CLEAR ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  gv_title = sy-title.

  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100' WITH gv_title.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0100 OUTPUT.

  IF go_container IS INITIAL.

    PERFORM create_object_0100.

    PERFORM set_layout_0100.

    PERFORM set_fieldcat_0100.

    PERFORM set_event_handler_0100.

    PERFORM set_alv_0100.


  ELSE.
    PERFORM refresh_alv_0100.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0100 OUTPUT.

  CLEAR gs_display1.


  LOOP AT gt_display1 INTO gs_display1.

    PERFORM set_status_icon.


    MODIFY gt_display1 FROM gs_display1.

  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TABSTRIP_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_tabstrip_0200 OUTPUT.

  " 이거 없으면 다른 탭스트립으로 안넘어가짐
  IF tab-activetab IS INITIAL.
    tab-activetab = 'FC1'.
  ENDIF.

  CASE tab-activetab.
    WHEN 'FC1'.
      gv_subscreen = '0101'.
    WHEN 'FC2'.
      gv_subscreen = '0102'.
    WHEN 'FC3'.
      gv_subscreen = '0103'.
    WHEN 'FC4'.
      gv_subscreen = '0104'.
    WHEN OTHERS.
      gv_subscreen = '0101'.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_0101 OUTPUT.

  " 공급자 정보 출력
  PERFORM display_company.

  " 공급받는자 정보 출력
  PERFORM display_receiver.

  " 공급받는자 유형 텍스트 세팅
  PERFORM set_kdgrp_txt.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_0102 OUTPUT.

  PERFORM display_so.

  PERFORM display_so_de.

  PERFORM set_SEARCH_OPT.



ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_0101 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_0103 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  DATA : lv_title_0200 TYPE c LENGTH 20.

  lv_title_0200 = TEXT-t04.
  REPLACE '&1' IN lv_title_0200 WITH gs_display1-vbeln.



  SET PF-STATUS 'S0200'.
  SET TITLEBAR 'T0200' WITH lv_title_0200.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0102 OUTPUT.

  IF gv_amt_detail_open = abap_true.
    IF go_container2 IS INITIAL.

      PERFORM create_object_0102.

      PERFORM set_layout_0102.

      PERFORM set_fieldcat_0102.

      "PERFORM set_event_handler_0102.

      PERFORM set_alv_0102.

    ELSE.

    ENDIF.
  ELSE.
    PERFORM free_alv_0102.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0102 OUTPUT.

  CLEAR gs_so_de.

  LOOP AT gt_so_de INTO gs_so_de.

    " 세액 설정
    PERFORM set_mwspr.


    " 할인 금액 설정
    PERFORM set_KBEPR.


    MODIFY gt_so_de FROM gs_so_de.

  ENDLOOP.



ENDMODULE.
