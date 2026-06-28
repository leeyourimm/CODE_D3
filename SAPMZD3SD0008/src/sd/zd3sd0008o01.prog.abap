*&---------------------------------------------------------------------*
*& Include          ZRD3SD0001_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  " 제목 설정
  gv_title    = sy-title.

  " 검증모드 일 때는 APP 버튼 막는다
  IF gv_kpi_on = abap_true.
    SET PF-STATUS 'S100_KPI'.
    " 이외에는 안막는다
  ELSE.
    SET PF-STATUS 'S100'.
  ENDIF.

  " 제목 설정
  SET TITLEBAR 'T100' WITH gv_title.

  " 시작을 알리는 Bool 세팅
  gv_start = abap_true.

  " 년 리스트 세팅
  PERFORM set_gjahr_listbox_year.

  " 월 리스트 세팅
  PERFORM set_gjahr_listbox_month.


  " 초기 조회 기간 세팅
  IF gv_year_from EQ '0000' OR gv_year_from IS INITIAL.
    gv_year_from = sy-datum(4) .
  ENDIF.
  IF gv_month_from EQ '00' OR gv_month_from IS INITIAL.
    gv_month_from = |{ sy-datum+4(2) ALIGN = RIGHT WIDTH = 2 PAD = '0' }|.
  ENDIF.
  IF gv_year_to IS INITIAL.
    gv_year_to =   sy-datum(4).
  ENDIF.
  IF gv_month_to IS INITIAL.
    gv_month_to =  '12'.
  ENDIF.

  " Exit Command에서 스크린 번호에 따른 로직을 다르게 주기 위해 설정
  gv_before_dynnr = sy-dynnr.

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
*& Module INIT_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0100 OUTPUT.

  IF go_container IS INITIAL.

    PERFORM create_object.

    PERFORM set_layout.

    PERFORM set_fieldcat.

    PERFORM set_handler_event.

    PERFORM display_alv_0100.

  ELSE.
    PERFORM refresh_alv_0100.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  SET PF-STATUS 'S0110'.
  " [SD] 계획 단건 생성
  SET TITLEBAR  'T0110' WITH TEXT-t01.

  " 년 리스트 세팅
  PERFORM set_gjahr_listbox_year_0110.

  " Exit Command에서 스크린 번호에 따른 로직을 다르게 주기 위해 설정
  gv_before_dynnr = sy-dynnr.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DYNC_ALV_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE dync_alv_0110 OUTPUT.

  " 영업 조직 리스트박스에 표기
  PERFORM set_vkorg_listbox.

  " 자재 정보 리스트박스에 표기
  PERFORM set_mat_listbox.


  " 계획 달 리스트박스에 표기
  PERFORM set_month_listbox.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module FILL_MATNM OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0120 OUTPUT.

  SET PF-STATUS 'S0120'.
  SET TITLEBAR  'T0120' WITH gv_chart_maktx.

  IF go_ixml IS INITIAL.
    go_ixml = cl_ixml=>create( ).
  ENDIF.

  IF go_streamfac IS INITIAL.
    go_streamfac = go_ixml->create_stream_factory( ).
  ENDIF.

  " Exit Command에서 스크린 번호에 따른 로직을 다르게 주기 위해 설정
  gv_before_dynnr = sy-dynnr.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0110 OUTPUT.

  " 계획수량 단위 표기
  gv_plan_meins = 'EA'.

  " 화면 나갔다 다시 들어왔을 때 스크린 클리어 하기 위한 로직
  PERFORM set_refresh_0110.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0130 OUTPUT.
  SET PF-STATUS 'S0130'.
  " [SD] 계획 생성 옵션
  SET TITLEBAR 'T0130' WITH TEXT-t15.

  " Exit Command에서 스크린 번호에 따른 로직을 다르게 주기 위해 설정
  gv_before_dynnr = sy-dynnr.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0140 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0140 OUTPUT.
  SET PF-STATUS 'S0140'.
  " [SD] 계획 다건 생성
  SET TITLEBAR 'T0140' WITH TEXT-t16.

  " Exit Command에서 스크린 번호에 따른 로직을 다르게 주기 위해 설정
  gv_before_dynnr = sy-dynnr.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0140 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0140 OUTPUT.

  IF go_tree IS INITIAL.

    PERFORM get_mat_data_0140.
    PERFORM create_object_0140.
    PERFORM set_layout_0140.
    PERFORM set_fieldcat_0140.
    PERFORM display_alv_0140.
    PERFORM set_handler_event_0140.
    PERFORM add_node_0140.


  ELSE.

    PERFORM refresh_alv_0140.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module SET_ALV_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0120 OUTPUT.

  " 선택한 제품의 달별 작년 판매량 조회
  PERFORM get_last_year_month_so.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0120 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0120 OUTPUT.
  IF go_container2 IS INITIAL.

    PERFORM create_object_0120.

    PERFORM create_chart_data_xml_0120.

    PERFORM create_chart_custom_xml_0120.

    PERFORM set_chart_0120.

  ELSE.

    " 같은 화면에서 다른 자재 다시 클릭했을 때 데이터만 다시 그린다
    PERFORM create_chart_data_xml_0120.

    PERFORM create_chart_custom_xml_0120.

    PERFORM set_chart_0120.

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0100 OUTPUT.

  " 변경 가능 필드 조건 세팅
  " 다음달~ + MRP 반영 안된 달만 수정 가능하도록
  PERFORM set_edit_style.

  CHECK gv_after_0110 IS INITIAL
    AND gv_after_0140 IS INITIAL
    AND gv_after_edit IS INITIAL.

  " 검색 전 데이터를 미리 변수에 담을 로직
  " 140번 화면에서 기존 db에 저장된 데이터 + 이미 추가한 데이터에 대해서는 담지 않기 위해
  PERFORM select_db_data.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0150 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0150 OUTPUT.
  SET PF-STATUS 'S0150'.
  " [SD] 자동 채움 옵션
  SET TITLEBAR 'T0150' WITH TEXT-t17.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0160 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0160 OUTPUT.
  DATA : lv_title TYPE c LENGTH 30.

  lv_title = TEXT-t14.

  SET PF-STATUS 'S0160'.
  SET TITLEBAR 'T0160' WITH lv_title.

  FORMAT RESET.

  " Exit Command에서 스크린 번호에 따른 로직을 다르게 주기 위해 설정
  gv_before_dynnr = sy-dynnr.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0160 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0160 OUTPUT.

  PERFORM set_kpi_desc.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form set_gjahr_listbox_year_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gjahr_listbox_year_0110 .

  DATA : lv_cur_year TYPE gjahr.

  lv_cur_year = sy-datum(4).

  REFRESH gt_gjahr_year.

  IF sy-datum+4(2) GE '10'.

    DO 2 TIMES.
      CLEAR gs_gjahr_year.

      gs_gjahr_year-key  = |{ lv_cur_year }|.

      APPEND gs_gjahr_year TO gt_gjahr_year.

      lv_cur_year += 1.

    ENDDO.

  ELSE.

    CLEAR gs_gjahr_year.

    gs_gjahr_year-key  = |{ lv_cur_year }|.

    APPEND gs_gjahr_year TO gt_gjahr_year.

  ENDIF.


  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_PLAN_YEAR'
      values = gt_gjahr_year.

  gv_vrm_init = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_screen_0100 OUTPUT.

  DATA : lv_year_from LIKE gv_year_from.
  DATA : lv_month_from LIKE gv_month_from.

  LOOP AT SCREEN.

    CASE screen-name.

      WHEN 'GV_YEAR_FROM'
        OR 'GV_MONTH_FROM'.

        " 검증모드일 때 입력필드 막는다
        IF gv_kpi_on = abap_true.
          screen-input = 0.

          " 다음달 이후 조회일 때 입력필드 막는다
        ELSEIF gv_ch2 = abap_true.
          screen-input = 0.


          gv_year_from  = sy-datum(4).
          gv_month_from = |{ sy-datum+4(2) + 1 ALIGN = RIGHT WIDTH = 2 PAD = '0' }|.


        ELSE.
          screen-input = 1.

        ENDIF.

      WHEN 'SEARCH'
        OR 'SEARCH_REFRESH'
        OR 'GV_CH1'
        OR 'GV_CH2'
        OR 'GV_YEAR_TO'
        OR 'GV_MONTH_TO'
        OR 'GV_MATNR_FROM'
        OR 'GV_MATNR_TO'
        OR 'GV_PLNNR_FROM'
        OR 'GV_PLNNR_TO'
        OR 'GV_VKORG_FROM'
        OR 'GV_VKORG_TO'.

        " 검증모드일 때 데이터 막는다
        IF gv_kpi_on = abap_true.
          screen-input = 0.
        ELSE.
          screen-input = 1.
        ENDIF.

    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN_APP_BT_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_screen_app_bt_0100 OUTPUT.

*  IF gv_kpi_on = abap_true.
*    SET PF-STATUS 'S0100_KPI'.
*  ELSE.
*    SET PF-STATUS 'S0100'.
*  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_SCREEN_0150 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_screen_0150 OUTPUT.

  LOOP AT SCREEN.

    CLEAR gv_per_ob.

    CASE screen-name.

      WHEN 'GV_PER'.

        " 작년도 판매량 기준일 때
        IF gv_op3 = abap_true.
          screen-input = 1.
          gv_per_ob = abap_true.

          " 작년도 판매량 + PIR 기준일 때
        ELSEIF gv_op5 = abap_true.
          screen-input = 0.
          CLEAR gv_per_ob.
          CLEAR gv_per.

        ENDIF.
    ENDCASE.

    MODIFY SCREEN.

  ENDLOOP.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUIRED_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_required_0150 INPUT.

  IF gv_op3 IS NOT INITIAL.

    " 전년도 판매량 기준일 때 퍼센테이지 체크
    " 값 입력 필수
    PERFORM check_gv_per.

  ENDIF.

ENDMODULE.
