*&---------------------------------------------------------------------*
*& Include          ZRD3SD9010_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

* 동적 버튼 구현을 위한 변수 설정
  PERFORM set_btn_status.


  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100' WITH gv_title.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CLEAR_OK_CODE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE clear_ok_code OUTPUT.

  CLEAR ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0100 OUTPUT.
  IF go_container IS INITIAL.

    PERFORM create_object_0100.
    PERFORM set_layout_0100.
    PERFORM set_fieldcat_0100.
    PERFORM set_handler_0100.
    PERFORM set_alv_data_0100.



  ELSE.
    PERFORM refresh_alv_0100.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form create_object_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0100 .


  CREATE OBJECT go_custom_container
    EXPORTING
      container_name = 'CCON1'.

  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_custom_container
      rows    = 2
      columns = 1.

  go_container  = go_splitter->get_container( row = 1 column = 1 ).
  go_container2 = go_splitter->get_container( row = 2 column = 1 ).


  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.

  CREATE OBJECT go_alv_grid2
    EXPORTING
      i_parent = go_container2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0100 OUTPUT.

  " 조회용 ITAB에 데이터를 옮기는 로직
  PERFORM move_data_0100.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_SEARCH_CONDITION OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_search_condition OUTPUT.
  PERFORM display_search_condition.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0110 OUTPUT.

  " T03 : 발생 전표번호
  gv_del_title = TEXT-t03.

  SET PF-STATUS 'S0110'.
  SET TITLEBAR  'T0110' WITH gv_del_title.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0110 OUTPUT.

  " 연체 기간을 세팅하는 로직
  PERFORM set_gv_txt_0110.

  " 지급조건 Fixed Value의 Description을 가져오는 로직
  PERFORM set_gv_zttxt.

  " 회사명을 가져오는 로직
  PERFORM set_gv_butxt_0110.

  " 영업조직 Fixed Value의 Description을 가져오는 로직
  PERFORM set_gv_vktxt_0110.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0120 OUTPUT.
  SET PF-STATUS 'S0120'.
  SET TITLEBAR 'T0120' WITH gs_so-vbeln.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0130 OUTPUT.
  SET PF-STATUS 'S0130'.
  SET TITLEBAR 'T0130' WITH gs_do-dlrno.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0120 OUTPUT.

  " 고객코드에 대한 고객명 세팅
  PERFORM set_gv_kunnm.

  "  세팅하는 로직
  PERFORM set_gv_vktxt_0110.

  " 지급조건 Fixed Value의 Description을 가져오는 로직
  PERFORM set_gv_zttxt.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0130 OUTPUT.

  CLEAR gv_do1.
  CLEAR gv_do2.
  CLEAR gv_d1txt.
  CLEAR gv_d2txt.

  LOOP AT gt_do INTO gs_do.

    IF gs_do-werks EQ 'P00001'.

      gv_do1 = gs_do-dlrno.

    ELSEIF gs_do-werks is INITIAL.

      CLEAR gv_do1.
      gv_d1txt = '출하 정보 없음'.

    ENDIF.

    IF gs_do-werks EQ 'P00002'.

      gv_do2 = gs_do-dlrno.

    ELSEIF gs_do-werks is INITIAL.

      CLEAR gv_do2.
      gv_d2txt = '출하 정보 없음'.

    ENDIF.

  ENDLOOP.

ENDMODULE.
