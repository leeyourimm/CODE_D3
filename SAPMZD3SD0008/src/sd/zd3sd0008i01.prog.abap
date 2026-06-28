*&---------------------------------------------------------------------*
*& Include          ZRD3SD0001_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.

    WHEN 'REFR'.
      CLEAR sy-ucomm.

    WHEN 'CHK'.
      LEAVE TO SCREEN 100.

      " 뒤로 가기 누를 때
    WHEN 'BACK'.

      " 만약 수정모드 누르고 값 안바꼈으면 gv_edit clear
      PERFORM clean_edit_no_change.
      PERFORM check_edit.


      " 변경전 팝업 띄우고 실행
    WHEN 'SAVE'.
      PERFORM popup_to_confirm USING sy-ucomm
                                     gv_ok.
      PERFORM save_database.
      PERFORM set_for_changed_data.
      " 저장된 셀에 대해 색깔 초기화
      PERFORM reset_row_col.
      " 변경된 데이터가 저장되었으므로, 변경된 데이터 저장한 테이블 초기화
      PERFORM refresh_plan_new.
      " 데이터 초기화 후 데이터 다시 가져온다
      PERFORM reselect_data.
      PERFORM refresh_alv_0100.


      " 자동 채움 누를 때
    WHEN 'AUTO_FILL'.

      CLEAR gv_before_dynnr.
      gv_before_dynnr = sy-dynnr.

      CALL SCREEN 0150 STARTING AT 70 1 ENDING AT 115 3.

      " 검색버튼 누를 때
    WHEN 'BT2'.
      " 입력값 보정
      PERFORM set_input_data.
      " 데이터 가져오는 로직
      PERFORM select_data.
      " 데이터 가공 로직
      PERFORM modify_data.
      " 예외처리 발생 로직
      PERFORM exception_data.
      " 수정된 데이터 붙이는 로직
      PERFORM append_data.
      " VKORG에 따른 지역명 삽입
      PERFORM set_vktxt.
      PERFORM refresh_alv_0100.
      " 아무것도 변경이 안됐을 때 진행하는 로직
      " 변경되면 _old에 데이터 옮기면 안된다
      " PERFORM set_for_changed_data2.

      " 검색조건 초기화 클릭 시
    WHEN 'BT1'.

      PERFORM check_sh_op_already_refresh.

      IF gv_already IS INITIAL.
*        PERFORM popup_to_confirm USING sy-ucomm
*                                       gv_ok.
        PERFORM refresh_search_opt.
      ELSE.
        CLEAR gv_already.
      ENDIF.

      " 판매계획 데이터 생성 버튼 클릭 시
    WHEN 'IN_PLAN'.

      PERFORM call_screen_0110.

      "화면 전체 새로고침
    WHEN 'REFRESH'.

      PERFORM check_already_refresh.

      IF gv_already IS INITIAL.
        PERFORM popup_to_confirm USING sy-ucomm
                                       gv_ok.
        PERFORM refresh_screen_0100.
        PERFORM refresh_alv_0100.
      ELSE.
        CLEAR gv_already.
      ENDIF.

  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.

    WHEN 'CANC'.
      IF gv_before_dynnr = 120.
        PERFORM free_chart_0120.
        PERFORM clear_alv_0140.
        LEAVE TO SCREEN 0.
      ELSEIF gv_before_dynnr = 100.
        gv_kpi_no = abap_true.
        LEAVE TO SCREEN 0.

      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.



  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.


  DATA: lv_plan_month TYPE ztd3sd0004-plan_month,
        lv_plnnr      TYPE ztd3sd0004-plnnr.


  CASE ok_code.
    WHEN 'CONT'.

      CLEAR gv_plnnr.

      PERFORM set_gv_plan_werks.


      " DB에 같은 달/영업조직/플랜트번호의 데이터가 존재하는지 확인
      " 같은 데이터가 존재하면 헤더 데이터를 생성할 필요가 없다
      SELECT SINGLE a~plnnr
        FROM       ztd3sd0004 AS a
       INNER JOIN  ztd3sd0005 AS b
          ON a~plnnr EQ b~plnnr
       WHERE plan_month = @lv_plan_month
         AND vkorg      = @gv_plan_vkorg
         AND werks      = @gv_plan_werks
        INTO @lv_plnnr.

      CLEAR gs_plan_all.

      " DB에 저장되지 않은, ITAB에 이미 생성되었는지도 확인
      " 반영이 이미 되어 있는 경우, lv_plnnr에 데이터가 들어온다
      READ TABLE gt_plan_all INTO gs_plan_all
        WITH KEY plan_month = lv_plan_month
                 vkorg      = gv_plan_vkorg
                 werks      = gv_plan_werks.

      lv_plnnr = gs_plan_all-plnnr.




      " 기존의 판매계획번호가 존재하지 않는다면 넘버레인지 새로 발급해서 새로운 판매계획번호 생성
      " 그에 따른 헤더 테이블도 생성
      IF lv_plnnr IS INITIAL.
        " 판매계획 key를 얻기 위한 넘버레인지
        PERFORM get_plan_number CHANGING gv_plnnr.
        " DB에 저장하기 위한 헤더 ITAB에 데이터를 넣는 로직
        PERFORM set_gs_insert_header.

      ELSE.
        " 기존 판매계획번호가 존재한다면 아이템 테이블에만 추가하기 위해 기존의 판매계획 번호를 불러온다
        gv_plnnr = lv_plnnr.
      ENDIF.


      " DB에 저장하기 위한 아이템 ITAB에 데이터를 넣는 로직
      PERFORM set_gs_insert_item.


      PERFORM append_gt_display.

      PERFORM refresh_alv_0110.


      " 기존 ALV에서 테이블 정보를 다시 재검색하기 위해 설정
      " gv_after_0110 = abap_true.
      PERFORM refresh_alv_0100.


      gv_after_0110 = abap_true.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.



  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUIRED_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_required_0110 INPUT.
*************************************************************************
* 데이터 미입력 여부 확인
*************************************************************************
  IF ok_code = 'CONT'.
    IF gv_plan_month IS INITIAL
       OR gv_plan_matnr IS INITIAL
       OR gv_plan_vkorg IS INITIAL.
      " M01 : 계획월, 자재번호, 영업조직을 모두 입력하세요.
      MESSAGE TEXT-m01 TYPE 'E'.
    ENDIF.
  ENDIF.

*************************************************************************
* 판매 계획 자재에 대한 중복 여부 확인
*************************************************************************
  lv_plan_month = |{ sy-datum(4) }{ gv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

  DATA: lv_max_posnr    TYPE ztd3sd0005-posnr,
        lv_next_posnr   TYPE ztd3sd0005-posnr,
        lv_max_posnr_i  TYPE i,
        lv_next_posnr_i TYPE i,
        lv_exist_matnr  TYPE ztd3sd0005-matnr.

  " DB에 저장하기 위한 STRUCTURE
  DATA: ls_item TYPE ztd3sd0005.

  " 같은 판매계획번호 안에 같은 자재가 이미 있는지 확인
  SELECT SINGLE b~matnr
    INTO @lv_exist_matnr
    FROM ztd3sd0005 AS b
    INNER JOIN ztd3sd0004 AS a
      ON a~plnnr = b~plnnr
    WHERE a~plan_month = @lv_plan_month
      AND a~vkorg      = @gv_plan_vkorg
      AND b~matnr      = @gv_plan_matnr
      AND a~lvorm      = @space
      AND b~lvorm      = @space.

  IF sy-subrc = 0.
    " M02 : 같은 계획월에 이미 존재하는 자재 계획입니다.
    MESSAGE TEXT-m02 TYPE 'E'.
  ENDIF.

*************************************************************************
* 판매 계획 자재 존재 여부 확인
*************************************************************************
  SELECT SINGLE matnr
    FROM ztd3mm0001
    INTO @DATA(lv_matnr_ex)
   WHERE matnr EQ @gv_plan_matnr.

  IF sy-subrc NE 0.
    " M03 : 존재하지 않은 자재번호 입니다.
    MESSAGE TEXT-m13 TYPE 'E'.
  ENDIF.

*************************************************************************
* 판매 계획 자재 완재품 여부 확인
*************************************************************************

  DATA lv_matnr TYPE ztd3mm0001-matnr.

  lv_matnr = gv_plan_matnr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = lv_matnr
    IMPORTING
      output = lv_matnr.

  IF lv_matnr NP '2*'.
    MESSAGE '완제품이 아닙니다.' TYPE 'E'.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUIRED_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_required_0100 INPUT.

  IF ( gv_year_from IS INITIAL AND gv_month_from IS NOT INITIAL ) OR ( gv_year_to IS INITIAL AND gv_month_to IS NOT INITIAL ).
    REFRESH gt_display.
    PERFORM refresh_alv_0100.
    " 년도 없이 달을 입력하실 수 없습니다.
    MESSAGE w336.
  ENDIF.

  IF gv_year_from IS NOT INITIAL AND gv_month_from IS INITIAL AND gv_year_to IS NOT INITIAL AND gv_month_to IS NOT INITIAL.
    REFRESH gt_display.
    PERFORM refresh_alv_0100.
    " 조회 시작달을 입력해주세요
    MESSAGE w339.
  ENDIF.

  IF gv_year_from IS NOT INITIAL AND gv_month_from IS NOT INITIAL AND gv_year_to IS NOT INITIAL AND gv_month_to IS INITIAL.
    REFRESH gt_display.
    PERFORM refresh_alv_0100.
    " 조회 종료달을 입력해주세요
    MESSAGE w340.
  ENDIF.

  IF gv_ch2 IS NOT INITIAL.
    IF  gv_year_to IS NOT INITIAL AND gv_month_to IS INITIAL.

      REFRESH gt_display.
      PERFORM refresh_alv_0100.
      " 달을 입력해주세요
      MESSAGE w337.
    ENDIF.

    IF  gv_year_to IS INITIAL AND gv_month_to IS NOT INITIAL.

      REFRESH gt_display.
      PERFORM refresh_alv_0100.
      " 년도를 입력해주세요
      MESSAGE w338.
    ENDIF.
  ENDIF.

  DATA : lv_ym_from TYPE c LENGTH 6.
  DATA : lv_ym_to   TYPE c LENGTH 6.

  lv_ym_from = |{ gv_year_from }{ gv_month_from WIDTH = 2 ALIGN = RIGHT PAD = '0'  }|.
  lv_ym_to   = |{ gv_year_to }{ gv_month_to }|.
  " 계획기간 다 입력 시
  IF  gv_year_from IS NOT INITIAL AND gv_month_from IS NOT INITIAL
  AND gv_year_to   IS NOT INITIAL AND gv_year_to IS NOT INITIAL.
    IF lv_ym_from GT lv_ym_to.
      REFRESH gt_display.
      PERFORM refresh_alv_0100.
      " 시작 조회조건이 종료 조회조건보다 큽니다.
      MESSAGE w335.
    ENDIF.
  ENDIF.

  " 자재번호 다 입력 시
  IF gv_matnr_from IS NOT INITIAL AND gv_matnr_to IS NOT INITIAL.
    IF gv_matnr_from GT gv_matnr_to.
      REFRESH gt_display.
      PERFORM refresh_alv_0100.
      " 시작 조회조건이 종료 조회조건보다 큽니다.
      MESSAGE w335.
    ENDIF.
  ENDIF.

  " 영업조직 다 입력 시
  IF gv_vkorg_from IS NOT INITIAL AND gv_vkorg_to IS NOT INITIAL.
    IF gv_vkorg_from GT gv_vkorg_to.
      REFRESH gt_display.
      PERFORM refresh_alv_0100.
      " 시작 조회조건이 종료 조회조건보다 큽니다.
      MESSAGE w335.
    ENDIF.
  ENDIF.

  " SOP 번호 다 입력 시
  IF gv_plnnr_from IS NOT INITIAL AND gv_plnnr_to IS NOT INITIAL.
    IF gv_plnnr_from GT gv_plnnr_to.
      REFRESH gt_display.
      PERFORM refresh_alv_0100.
      " 시작 조회조건이 종료 조회조건보다 큽니다.
      MESSAGE w335.
    ENDIF.
  ENDIF.




ENDMODULE.

**&---------------------------------------------------------------------*
**&      Module  F4_GV_PLNNR  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE f4_gv_plnnr INPUT.
*
*  PERFORM get_sh_plnnr.
*
*ENDMODULE.
**&---------------------------------------------------------------------*
**&      Module  F4_GV_MATNR  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE f4_gv_matnr INPUT.
*
*  PERFORM get_sh_matnr.
*
*ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  F4_GV_PLAN_MATNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_gv_plan_matnr INPUT.

  PERFORM get_sh_plan_matnr.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0130  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0130 INPUT.

  CASE ok_code.
    WHEN 'CONT'.
      CASE abap_true.
          " 단건 선택 시
        WHEN gv_op1.
          CALL SCREEN 0110 STARTING AT 70 1.
          " 다건 선택 시
        WHEN gv_op2.
          CALL SCREEN 0140 STARTING AT 1 1 ENDING AT 180 30.
      ENDCASE.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0140  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0140 INPUT.

  CASE ok_code.
    WHEN 'CONT'.

      " 140번 ALV 편집값을 내부테이블에 반영
      IF go_alv_grid4 IS BOUND.
        CALL METHOD go_alv_grid4->check_changed_data.
      ENDIF.


      " 다건 기준으로 헤더/아이템/100번 ALV 데이터 생성
      PERFORM build_data_from_0140.

      " 140번 내 모든 데이터 초기화
      PERFORM clear_alv_0140.

      PERFORM refresh_alv_0100.

      " SAVE 가능하게 세팅
      gv_after_0140 = abap_true.

      LEAVE TO SCREEN 0.

    WHEN 'AUTO_FILL'.

      CLEAR gv_before_dynnr.
      gv_before_dynnr = sy-dynnr.

*      " 전체 제품의 작년 달별 판매량 계산
*      PERFORM sum_lastmonth_qua.
*      PERFORM popup_to_confirm USING sy-ucomm
*                               gv_ok.
*      PERFORM fill_auto_plan_qty_0140.
*      PERFORM refresh_alv_0140.
*      " 데이터가 변경되었으므로, DB에 저장하기 위해 Bool값을 True로 바꾼다
*      gv_after_edit = abap_true.
      CALL SCREEN 0150 STARTING AT 70 1 ENDING AT 115 3.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0150  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0150 INPUT.

  CASE ok_code.
    WHEN 'OP'.
      LEAVE TO SCREEN 150.
    WHEN 'CONT'.
      CASE abap_true.

          " 작년도 판매량 기준 자동 채움
        WHEN gv_op3.
          IF gv_before_dynnr = 0100.
            PERFORM popup_to_confirm USING sy-ucomm
                                           gv_ok.
            PERFORM fill_auto_plan_qty_last_0100.
            PERFORM refresh_alv_0100.

          ELSEIF gv_before_dynnr = 0140.
            " 전체 제품의 작년 달별 판매량 계산
            PERFORM sum_lastmonth_qua.
            PERFORM popup_to_confirm USING sy-ucomm
                                     gv_ok.
            PERFORM fill_auto_plan_qty_last_0140.
            PERFORM refresh_alv_0140.
          ENDIF.

          " 전년도 판매량 + PIR
        WHEN gv_op5.

          PERFORM select_pir_data.

          IF gv_before_dynnr = 0100.
            PERFORM popup_to_confirm USING sy-ucomm
                               gv_ok.
            PERFORM fill_auto_plan_qty_la_pir_0100.
            PERFORM refresh_alv_0100.

          ELSEIF gv_before_dynnr = 0140.

            " 전체 제품의 작년 달별 판매량 계산
            PERFORM sum_lastmonth_qua.

            IF sy-ucomm IS NOT INITIAL.
              PERFORM popup_to_confirm USING sy-ucomm
                                             gv_ok.
            ENDIF.
            PERFORM fill_auto_plan_qty_la_pir_0140.
            PERFORM refresh_alv_0140.
          ENDIF.

      ENDCASE.



      " 작년도 판매량 + PIR
*    WHEN gv_op5.
*
*      PERFORM select_pir_data.
*
*      IF gv_before_dynnr = 0100.
*        PERFORM popup_to_confirm USING sy-ucomm
*                           gv_ok.
*        PERFORM fill_auto_plan_qty_la_pir_0100.
*        PERFORM refresh_alv_0100.
*
*      ELSEIF gv_before_dynnr = 0140.
*
*        " 전체 제품의 작년 달별 판매량 계산
*        PERFORM sum_lastmonth_qua.
*
*        IF sy-ucomm IS NOT INITIAL.
*          PERFORM popup_to_confirm USING sy-ucomm
*                                         gv_ok.
*        ENDIF.
*        PERFORM fill_auto_plan_qty_la_pir_0140.
*        PERFORM refresh_alv_0140.
*      ENDIF.
*
*  ENDCASE.

      " 데이터가 변경되었으므로, DB에 저장하기 위해 Bool값을 True로 바꾼다
      gv_after_edit = abap_true.

      LEAVE TO SCREEN 0.


  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0160  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0160 INPUT.
  CASE ok_code.
    WHEN 'CONT'.
      gv_kpi_ok = abap_true.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
