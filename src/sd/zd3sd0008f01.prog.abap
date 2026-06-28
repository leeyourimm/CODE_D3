*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .

  CHECK gv_valid_bool IS INITIAL.

  " 전체 제품의 작년 달별 판매량 계산
  PERFORM sum_lastmonth_qua.

  " 올해 판매계획 데이터 생성을 위한 조회(mrp 반영 포함)
  PERFORM select_plan_year_so.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object .

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CCON'.

  CREATE OBJECT go_alv_grid
    EXPORTING
      i_parent = go_container.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_0100 .

  DATA: lt_exclude TYPE ui_functions.

  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO lt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO lt_exclude.

  go_alv_grid->set_table_for_first_display(
    EXPORTING
      is_variant                    = gs_variant               " Layout
      i_save                        = gv_save                  " Save Layout
      is_layout                     = gs_layout                 " Layout
    CHANGING
      it_outtab                     = gt_display                " Output Table
      it_fieldcatalog               = gt_fieldcat               " Field Catalog

  ).


  IF sy-subrc <> 0.
    BREAK-POINT.
  ENDIF.

  " 처음 ALV 생성될 때 수정 가능 불가능 모드로 세팅
  CALL METHOD go_alv_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .

  "gs_layout-cwidth_opt = abap_on.       " 컬럼 넓이 최적화
  gs_layout-zebra      = abap_on.            " 얼룩 무늬
  gs_layout-grid_title = gv_alv_title.  " 판매 계획 데이터 ( &1 ) 건
  gs_layout-totals_bef = abap_on.       " 총계 상단 고정
  gs_layout-ctab_fname = 'CELL_COLOR'.  " 셀 색깔
  gs_layout-info_fname = 'LINE_COLOR'.  " 행 색깔
  gs_layout-stylefname = 'CELLTAB'.     "
  gs_layout-sel_mode = 'D'.             "셀 선택 자유롭게

  " LAYOUT 저장 관련
  gs_variant-report = sy-cprog.
  gv_save = 'A'.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat .

  CLEAR gt_fieldcat.

  DEFINE _set_fieldcat.
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname     = &1.
    gs_fieldcat-coltext       = &2.
    gs_fieldcat-edit          = &3.
    gs_fieldcat-key           = &4.
    gs_fieldcat-hotspot       = &5.
    gs_fieldcat-qfieldname    = &6.
    gs_fieldcat-outputlen     = &7.
    gs_fieldcat-checkbox      = &8.
    gs_fieldcat-just          = &9.

    IF &1 = 'POSNR'.
      gs_fieldcat-outputlen = 4.
      gs_fieldcat-no_zero   = space.
    ENDIF.

    APPEND gs_fieldcat TO gt_fieldcat.
  END-OF-DEFINITION.
  "               fieldname    coltext       edit  key  hotspot   qfieldname  outputlen  checkbox  just
  _set_fieldcat 'PLNNR'      'SOP 번호'      ''   'X'   ''        ''           10        ''        ''.
  _set_fieldcat 'POSNR'      'SOP 아이템'    ''   'X'   ''        ''           10        ''        'R'.
  _set_fieldcat 'VKORG'      '영업조직'      ''    ''   ''        ''            5        ''        'R'.
  _set_fieldcat 'VKTXT'      '지역'          ''   ''    ''        ''           10        ''        ''.
  _set_fieldcat 'MATNR'      '자재번호'      ''    ''   ''        ''           10        ''        ''.
  _set_fieldcat 'MAKTX'      '자재명'        ''   ''    'X'       ''           20        ''        ''.
  _set_fieldcat 'PLAN_MONTH' '계획 달'       ''   ''    ''        ''            6        ''        'R'.
  _set_fieldcat 'MRP_STAT'   'MRP 수행 여부' ''   ''    ''        ''            9        'X'       ''.
  _set_fieldcat 'ICON'       '검증 상태'     ''   ''    'X'        ''           5        ''        'C'.
  _set_fieldcat 'MENGE'      '계획 수량'     'X'  ''    ''        'MEINS'      10        ''        ''.
  _set_fieldcat 'MEINS'      '단위'          ''   ''    ''        ''            5        ''        ''.
  _set_fieldcat 'ERDAT'      '생성일'        ''   ''    ''        ''            8        ''        ''.
  _set_fieldcat 'ERZZT'      '생성시간'      ''   ''    ''        ''            6        ''        ''.
  _set_fieldcat 'ERNAM'      '생성자'        ''   ''    ''        ''           10        ''        ''.
  _set_fieldcat 'AEDAT'      '수정일'        ''   ''    ''        ''            8        ''        ''.
  _set_fieldcat 'AEZET'      '수정시간'      ''   ''    ''        ''            6        ''        ''.
  _set_fieldcat 'AENAM'      '수정자'        ''   ''    ''        ''           10        ''        ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING    po_object TYPE REF TO cl_alv_event_toolbar_set.

  DATA ls_button LIKE LINE OF po_object->mt_toolbar.

  " KPI 실행하는 버튼
  CLEAR ls_button.
  ls_button-function = 'GO_KPI'.

  "
  IF gv_kpi_on = abap_true.
    ls_button-text = TEXT-b02.    " b02 : 검증 중단
    ls_button-icon = icon_system_start_recording.
  ELSE.
    ls_button-text = TEXT-b01.    " b01 : 계획 검증
    ls_button-icon = icon_system_play.
  ENDIF.

  IF gv_edit = abap_true.
    ls_button-disabled = abap_true.
  ELSE.
    ls_button-disabled = space.
  ENDIF.

  APPEND ls_button TO po_object->mt_toolbar.


  " 구분선
  CLEAR ls_button.
  ls_button-butn_type = 3.
  APPEND ls_button TO po_object->mt_toolbar.

  " 계획 수량 변경 허용/불용 버튼
  CLEAR ls_button.
  ls_button-function = 'PO_CNANGE'.
  ls_button-text = TEXT-b03.

  IF gv_edit = abap_true.
    ls_button-text = TEXT-b04.    " b04 : 조회모드
    ls_button-icon = icon_display.
  ELSE.
    ls_button-text = TEXT-b05.    " b05 : 수정모드
    ls_button-icon = icon_toggle_display_change.
  ENDIF.


  IF gv_kpi_on = abap_true.
    ls_button-disabled = abap_true.
  ELSE.
    ls_button-disabled = space.
  ENDIF.


  APPEND ls_button TO po_object->mt_toolbar.


  " 구분선
  CLEAR ls_button.
  ls_button-butn_type = 3.
  APPEND ls_button TO po_object->mt_toolbar.


  APPEND ls_button TO po_object->mt_toolbar.

  " 입력값 초기화
  CLEAR ls_button.
  ls_button-function = 'CLEAR_PLAN'.
  ls_button-text = TEXT-b06.    " b06 : 판매계획 초기화
  ls_button-icon = icon_refresh.

  IF gv_kpi_on = abap_true.
    ls_button-disabled = abap_true.
  ELSE.
    ls_button-disabled = space.
  ENDIF.


  APPEND ls_button TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cls
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_handler_event .

  SET HANDLER lcl_event_handler=>on_toolbar FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_user_command FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_hotspot_click FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_data_changed FOR go_alv_grid.


  " 사용자가 값을 바꾼 순간 바로 이벤트를 발생시키기 위한 설정
  CALL METHOD go_alv_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form edit_plan_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM edit_plan_order  USING    po_ucomm TYPE sy-ucomm.

  DATA ls_stbl TYPE lvc_s_stbl.


  CASE po_ucomm.

      " KPI 실행
    WHEN 'GO_KPI'.

      DATA: lt_display     LIKE gt_display,
            lt_display_old LIKE gt_display_old.

      lt_display     = gt_display.
      lt_display_old = gt_display_old.

      LOOP AT lt_display ASSIGNING FIELD-SYMBOL(<ls_display>).
        CLEAR <ls_display>-celltab.
        CLEAR <ls_display>-line_color.
        CLEAR <ls_display>-cell_color.
        CLEAR <ls_display>-vktxt.
        CLEAR <ls_display>-line_color.
        CLEAR <ls_display>-icon.
      ENDLOOP.

      LOOP AT lt_display_old ASSIGNING FIELD-SYMBOL(<ls_old>).
        CLEAR <ls_old>-celltab.
        CLEAR <ls_old>-line_color.
        CLEAR <ls_old>-cell_color.
        CLEAR <ls_old>-vktxt.
        CLEAR <ls_old>-line_color.
        CLEAR <ls_old>-icon.
      ENDLOOP.


      READ TABLE gt_display INTO gs_display WITH KEY line_color = 'C510'.

      " DB에 반영되지 않은 데이터가 1건이라도 있으면 검증 모드를 실행하지 않는다
      IF sy-subrc <> 0.
        PERFORM kpi_setting.

        " PBO를 한번 더 타게 하기 위한 로직
        CALL METHOD cl_gui_cfw=>set_new_ok_code
          EXPORTING
            new_code = 'REFR'.


      ELSE.
        " 검증은 저장된 데이터를 기준으로 수행됩니다. 먼저 저장해 주세요.
        MESSAGE s342 DISPLAY LIKE 'W'.
      ENDIF.




      " 입력한 값 변경
    WHEN 'PO_CNANGE'.
      " DB에 반영된 건을 저장하는 로직을 실행시기키 위한 bool 세팅
      gv_after_edit  = abap_true.


      " 수정 모드로
      IF gv_edit = abap_false.
        gv_edit = abap_true.

        CALL METHOD go_alv_grid->set_ready_for_input
          EXPORTING
            i_ready_for_input = 1.
        " 조회 모드로
      ELSEIF gv_edit = abap_true.
        gv_edit = abap_false.

        CALL METHOD go_alv_grid->set_ready_for_input
          EXPORTING
            i_ready_for_input = 0.

      ENDIF.

    WHEN 'CLEAR_PLAN'.
      PERFORM popup_to_confirm USING po_ucomm
                                     gv_ok.
      PERFORM reset_data.
      " 데이터가 변경되었으므로, DB에 저장하기 위해 Bool값을 True로 바꾼다
      gv_after_edit = abap_true.


  ENDCASE.



  PERFORM refresh_alv_0100.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form sum_lastmonth_qua
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM sum_lastmonth_qua .

  DATA: lv_year      TYPE n LENGTH 4,
        lv_year_from TYPE sydatum,
        lv_year_to   TYPE sydatum.

  REFRESH gt_layear_sum.

  lv_year = sy-datum(4) - 1.

  lv_year_from = |{ lv_year }0101|.
  lv_year_to   = |{ lv_year }1231|.

  SELECT matnr,
         substring( audat, 5, 2 ) AS month,
         vkorg,
         kwmeng
    FROM zcds_d3_sd_0014
    INTO CORRESPONDING FIELDS OF TABLE @gt_layear_sum.

  SORT gt_layear_sum BY month matnr vkorg.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_kpi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_kpi .

  DATA: lv_month TYPE c LENGTH 2,
        ls_color TYPE lvc_s_scol.


  DATA : lt_matnr TYPE TABLE OF ztd3mm0001.
  DATA : ls_matnr LIKE LINE OF lt_matnr.

  " 작년 판매량이 없는 자재에 대해서는 KPI를 띄우지 않는 걸로
  DATA : lv_year_from TYPE ztd3sd0006-audat,
         lv_year_to   TYPE ztd3sd0006-audat.

  lv_year_from = |{ sy-datum(4) - 1 }0101|.
  lv_year_to   = |{ sy-datum(4) - 1 }1231|.

  SELECT a~matnr
    FROM ztd3mm0001 AS a
   WHERE a~matnr LIKE '00002%'
     AND NOT EXISTS (
       SELECT *
         FROM ztd3sd0007 AS b
         INNER JOIN ztd3sd0006 AS c
           ON c~vbeln = b~vbeln
        WHERE a~matnr = b~matnr
          AND c~audat BETWEEN @lv_year_from AND @lv_year_to
          AND b~lvorm = @space
          AND c~lvorm = @space
     )
    INTO CORRESPONDING FIELDS OF TABLE @lt_matnr.

  LOOP AT gt_display INTO gs_display.

    READ TABLE lt_matnr INTO ls_matnr
          WITH KEY matnr = gs_display-matnr.

    " 작년 판매가 없는 데이터에 대해서는 KPI를 띄우지 않는다
    IF sy-subrc EQ 0.
      CONTINUE.
    ENDIF.

    " 이미 MRP 반영한 데이터에 대해서는 KPI를 띄우지 않는다
    IF gs_display-mrp_stat IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    " 이번달까지의 데이터에 대해서는 KPI를 띄우지 않는다
    IF gs_display-plan_month LE sy-datum(6).
      CONTINUE.
    ENDIF.



    CLEAR gs_display-cell_color.

    lv_month = gs_display-plan_month+4(2).

    READ TABLE gt_layear_sum INTO gs_layear_sum
      WITH KEY month = lv_month
               matnr = gs_display-matnr
               vkorg = gs_display-vkorg.

    IF sy-subrc = 0.

      CLEAR ls_color.
      ls_color-fname = 'MENGE'.

      IF gs_display-menge < gs_layear_sum-kwmeng * '0.9'.

        ls_color-color-col = 6. " 빨강
        ls_color-color-int = 1.
        ls_color-color-inv = 0.
        APPEND ls_color TO gs_display-cell_color.

      ELSEIF gs_display-menge > gs_layear_sum-kwmeng * '1.1'.

        ls_color-color-col = 3. " 파랑
        ls_color-color-int = 1.
        ls_color-color-inv = 1.
        APPEND ls_color TO gs_display-cell_color.

      ENDIF.

    ENDIF.

    MODIFY gt_display FROM gs_display.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_kpi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_kpi .


  LOOP AT gt_display INTO gs_display.

    IF gs_display-cell_color IS NOT INITIAL.

      IF gs_display-menge LT gs_layear_sum-kwmeng * '0.9'.
        gs_display-icon = icon_question.
      ELSEIF gs_display-menge GE gs_layear_sum-kwmeng * '0.9'.
        gs_display-icon = icon_question.
      ENDIF.

      CLEAR gs_display-cell_color.

    ENDIF.

    MODIFY gt_display FROM gs_display.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_auto_plan_qty
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_auto_plan_qty_last_0100.

  CHECK gv_ok IS NOT INITIAL.

  DATA lv_month TYPE c LENGTH 2.

  DATA lv_per TYPE p LENGTH 6 DECIMALS 2.

  DATA : lv_count TYPE i.

  lv_per = gv_per / 100.

  LOOP AT gt_display INTO gs_display.

    lv_month = gs_display-plan_month+4(2).

    READ TABLE gt_layear_sum INTO gs_layear_sum
         WITH KEY month = lv_month
                  matnr = gs_display-matnr
                  vkorg = gs_display-vkorg
         BINARY SEARCH.

    " 이미 판매량을 지정한 자재에 대해서는 자동채움 하지 않는다
    "  mrp 반영한 건에 대해서는 자동채움 하지 않는다.
    IF sy-subrc = 0 AND gs_display-menge = 0 AND lv_month GT sy-datum+4(2) AND gs_display-mrp_stat IS INITIAL.

      gs_display-menge = round(
        val  = gs_layear_sum-kwmeng * lv_per
        dec  = 0
        mode = cl_abap_math=>round_half_up ).


      " 변경된 데이터임을 알리기 위한 행 색깔 지정
      gs_display-line_color = 'C510'.
      lv_count += 1.
    ENDIF.


    MODIFY gt_display FROM gs_display.



  ENDLOOP.

  " DB에 반영된 건을 저장하는 로직을 실행시기키 위한 bool 세팅
  gv_after_edit  = abap_true.

  IF lv_count GT 0.
    " 319 : 자동 채움이 완료되었습니다.
    MESSAGE s319.
  ELSE.
    " 변경된 데이터가 없습니다.
    MESSAGE s905 DISPLAY LIKE 'W'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv_0100 .

  DATA ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.  "행 위치 유지
  ls_stable-col = abap_true.  "열 위치 유지

  " MPR 제외 건만 조회한다면
  IF gv_ch1 IS NOT INITIAL.
    PERFORM del_gv_lines USING gv_count.
  ENDIF.

  gv_alv_title = | SOP 목록( { lines( gt_display ) } )|.

  gs_layout-grid_title = gv_alv_title.

  CALL METHOD go_alv_grid->set_toolbar_interactive.


  CALL METHOD go_alv_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reset_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reset_data .

  CHECK gv_ok IS NOT INITIAL.

  DATA : lt_rows TYPE lvc_t_row,
         ls_row  TYPE lvc_s_row.

  DATA : lv_menge_old TYPE i.

  DATA : lv_count TYPE i.

  DATA : lv_count_mrp TYPE i.
  DATA : lv_count_cur TYPE i.



  " ALV에서 사용자가 선택한 행 가져오기
  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  " 선택 안 했으면 종료
  IF lt_rows IS INITIAL.
    " 322 : 초기화할 행을 먼저 선택하세요.
    MESSAGE s322 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT lt_rows INTO ls_row.

    READ TABLE gt_display INTO gs_display INDEX ls_row-index.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    "MRP 반영된 건에 대해서는 초기화 하지 못한다.
    IF gs_display-mrp_stat EQ 'X'.

      lv_count_mrp += 1.

      IF gs_display-plan_month LE sy-datum(6).
        lv_count_cur += 1.
      ENDIF.

      CONTINUE.
    ENDIF.

    "이번달까지의 건에 대해서는 초기화 하지 못한다.
    IF gs_display-plan_month LE sy-datum(6).

      lv_count_cur += 1.
      CONTINUE.
    ENDIF.



    CLEAR lv_menge_old.

    lv_menge_old = gs_display-menge.

    " 화면 내부테이블도 같이 0으로 변경
    gs_display-menge = 0.

    " 이미 0이면 행 색깔 표시 안하게
    IF lv_menge_old NE gs_display-menge.
      CLEAR gs_display-line_color.
      lv_count += 1.
      " 변경된 행에 대해 변경됐다고 알리기 위해 행 색깔 표시
      gs_display-line_color = 'C510'.
    ENDIF.


    MODIFY gt_display FROM gs_display INDEX ls_row-index
    TRANSPORTING menge line_color.

  ENDLOOP.

  IF lv_count NE 0.
    IF lv_count_mrp EQ 0 AND lv_count_cur EQ 0.
      " 323 : 초기화가 완료되었습니다.
      MESSAGE s323.
    ELSEIF lv_count_mrp NE 0 AND lv_count_cur EQ 0.
      " 068 : MRP 반영한 달을 제외하고 초기화 하였습니다.
      MESSAGE s068.
    ELSEIF lv_count_mrp EQ 0 AND lv_count_cur NE 0.
      " 072 : 이번달까지의 달을 제외하고 초기화 하였습니다.
      MESSAGE s072.
    ELSEIF lv_count_mrp NE 0 AND lv_count_cur NE 0.
      "105 : MRP 반영 건과 이번달까지의 데이터를 제외하고 초기화 하였습니다.
      MESSAGE s105.

    ENDIF.

  ELSEIF lv_count EQ 0.
    " 초기화할 데이터가 존재하지 않습니다.
    MESSAGE s341 DISPLAY LIKE 'W'.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_plan_year_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_plan_year_so .

  DATA : lv_line TYPE i.


  SELECT
    a~plnnr,
    a~vkorg,
    a~plan_month,
    b~posnr,
    b~matnr,
    c~maktx,
    b~menge,
    b~meins,
    a~mrp_stat,
    b~erdat,
    b~erzzt,
    b~ernam,
    b~aedat,
    b~aezet,
    b~aenam,
    b~werks
  FROM ztd3sd0004 AS a
  INNER JOIN ztd3sd0005 AS b
    ON a~plnnr = b~plnnr
  LEFT OUTER JOIN ztd3mm0001 AS c
    ON b~matnr = c~matnr
  WHERE a~plnnr BETWEEN @gv_pn_from AND @gv_pn_to          " 판매계획번호
    AND a~vkorg BETWEEN @gv_vk_from AND @gv_vk_to          " 영업조직
    AND a~plan_month BETWEEN @gv_ym_from AND @gv_ym_to     " 계획 기간
    AND b~matnr BETWEEN @gv_mn_from AND @gv_mn_to          " 자재번호
    AND ( a~mrp_stat = '' OR @gv_ch1 = '' )
    AND c~lvorm = @space                                   " 삭제플래그
    AND a~lvorm = @space
    AND b~lvorm = @space
  INTO CORRESPONDING FIELDS OF TABLE @gt_display.

  SORT gt_display BY plan_month matnr vkorg  posnr.

  lv_line = lines( gt_display ).

  " ALV 타이틀 세팅
  gv_alv_title = | SOP 목록( { lv_line } )|.


  " 검색 결과가 없으면
  IF sy-subrc NE 0.
    " 검색된 데이터가 없다는 Bool 세팅
    gv_no_count = abap_true.
  ENDIF.

  " 수정 및 생성을 안한 상태일 때
  " 저장을 누르면 클리어 되어서 저장버튼 누른 직후해도 문제 X
  IF gv_after_0110 IS INITIAL AND gv_after_0140 IS INITIAL AND gv_after_edit IS INITIAL.

    REFRESH gt_display_old.

    gt_display_old = gt_display.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gjahr_listbox
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gjahr_listbox_month .

  REFRESH gt_gjahr_month.

  DATA : lv_next_month TYPE c LENGTH 2.
  DATA : lv_month_from TYPE c LENGTH 2.



  DO 12 TIMES.
    CLEAR gs_gjahr_month.

    gs_gjahr_month-key  = |{ sy-index WIDTH = 2  ALIGN = RIGHT PAD = '0' }|.
    gs_gjahr_month-text = |{ sy-index WIDTH = 2  ALIGN = RIGHT PAD = '0' }|.

    APPEND gs_gjahr_month TO gt_gjahr_month.
  ENDDO.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_MONTH_FROM'
      values = gt_gjahr_month.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_MONTH_TO'
      values = gt_gjahr_month.

  gv_vrm_init = abap_true.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_screen_0110 .

  CLEAR: gv_plan_vkorg, gv_plan_month, gv_plan_matnr, gv_plan_menge.

  CALL SCREEN 0130 STARTING AT 70 1 ENDING AT 100 3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_plan_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_plan_header .

  INSERT ztd3sd0004 FROM gs_insert_header.

  IF sy-subrc = 0.
    COMMIT WORK.
    " 023 : 저장되었습니다.
    MESSAGE s023.
  ELSE.
    ROLLBACK WORK.
    " 025 : 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'E'.
  ENDIF.

  CLEAR gs_insert_header.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_plan_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_plan_item .



  INSERT ztd3sd0005
    FROM @gs_insert_item.

  IF sy-subrc = 0.
    COMMIT WORK.
    " 023 : 저장되었습니다.
    MESSAGE s023.
  ELSE.
    ROLLBACK WORK.
    " 025 : 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'E'.
  ENDIF.

  CLEAR gs_insert_item.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_plan_number
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_plan_number CHANGING pv_plnnr TYPE ztd3sd0004-plnnr.

  DATA: lv_number TYPE n LENGTH 8.


  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'                 " Number range number
      object                  = 'ZNRD3SD04'                 " Name of number range object
    IMPORTING
      number                  = lv_number                 " free number
    EXCEPTIONS
      interval_not_found      = 1                " Interval not found
      number_range_not_intern = 2                " Number range is not internal
      object_not_found        = 3                " Object not defined in TNRO
      quantity_is_0           = 4                " Number of numbers requested must be > 0
      quantity_is_not_1       = 5                " Number of numbers requested must be 1
      interval_overflow       = 6                " Interval used up. Change not possible.
      buffer_overflow         = 7                " Buffer is full
      OTHERS                  = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  pv_plnnr = |PS{ lv_number }|.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_mat_listbox
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_mat_listbox .

  " 프로그램 실행 시 최소 1번만 실행됨
  IF gv_vrm_init3 EQ abap_false.

    REFRESH gt_list_mantr.
    CLEAR gs_list_mantr.

    SELECT matnr,
           maktx
      FROM ztd3mm0001
     WHERE matnr LIKE '00002%'
       AND lvorm EQ @space
      INTO TABLE @DATA(lt_matnr).

    LOOP AT lt_matnr INTO DATA(ls_matnr).
      CLEAR gs_list_mantr.
      gs_list_mantr-key  = ls_matnr-matnr.
      gs_list_mantr-text = ls_matnr-maktx.
      APPEND gs_list_mantr TO gt_list_mantr.
    ENDLOOP.


    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = 'GV_PLAN_MATNR'   " 화면 필드명
        values = gt_list_mantr.

    gv_vrm_init3 = abap_true.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_month_listbox
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_month_listbox .

  REFRESH gt_gjahr_month.
  CLEAR gs_gjahr_month.

  DATA: lv_next_month TYPE n LENGTH 2,
        lv_month      TYPE n LENGTH 2,
        lv_yyyymm     TYPE c LENGTH 6,
        lv_exist      TYPE c LENGTH 1.

  " 다음 달
  lv_next_month = sy-datum+4(2) + 1.

  IF gv_vrm_init2 = abap_false.

    DO 3 TIMES.

      lv_month = lv_next_month + sy-index - 1.

                                                            " 예: 202606
      lv_yyyymm = |{ sy-datum+0(4) }{ lv_month WIDTH = 2 PAD = '0' }|.

      CLEAR lv_exist.

      " 해당 년월 영업조직에 MRP 실행된 데이터가 있는지 확인
      SELECT SINGLE 'X'
        FROM ztd3sd0004
       WHERE plan_month EQ @lv_yyyymm
         AND mrp_stat  = 'X'
        INTO @lv_exist.

      " 이미 MRP 실행된 월이면 리스트박스에 추가하지 않음
*      IF lv_exist = 'X'.
*        CONTINUE.
*      ENDIF.

      CLEAR gs_gjahr_month.
      gs_gjahr_month-key  = lv_month.
      gs_gjahr_month-text = lv_month.
      APPEND gs_gjahr_month TO gt_gjahr_month.

    ENDDO.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = 'GV_PLAN_MONTH'
        values = gt_gjahr_month.

    gv_vrm_init2 = abap_true.
    CLEAR gv_plan_month.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_vkorg_listbox
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_vkorg_listbox .

  CLEAR gs_gjahr_vkorg.
  REFRESH gt_gjahr_vkorg.

  " 기본값 세팅
  " gv_plan_vkorg = 1010.

  IF gv_vrm_init4 EQ abap_false.

    CLEAR gs_gjahr_vkorg.
    " 드롭다운에 보이는 값
    gs_gjahr_vkorg-key  = '1010'.
    " 선택 후 파라미터에 들어가는 값
    gs_gjahr_vkorg-text = TEXT-d01. "  수도권
    APPEND gs_gjahr_vkorg TO gt_gjahr_vkorg.

    CLEAR gs_gjahr_vkorg.
    gs_gjahr_vkorg-key  = '1020'.
    gs_gjahr_vkorg-text = TEXT-d02. " 비수도권
    APPEND gs_gjahr_vkorg TO gt_gjahr_vkorg.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = 'GV_PLAN_VKORG'
        values = gt_gjahr_vkorg.

    gv_vrm_init4 = abap_true.

  ENDIF.



ENDFORM.


*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING po_row_id    TYPE lvc_s_row
                                 po_column_id TYPE lvc_s_col.

  CLEAR gs_display.
  CLEAR gv_chart_vkorg.
  CLEAR gv_chart_matnr.
  CLEAR gv_chart_maktx.

  READ TABLE gt_display INTO gs_display INDEX po_row_id-index.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CASE po_column_id.
    WHEN  'MAKTX'.
      gv_chart_matnr = gs_display-matnr.
      gv_chart_maktx = gs_display-maktx.

      " 작년 해당 제품의 달별 판매량을 가져온다
      PERFORM show_last_year_chart.
    WHEN 'ICON'.
      IF gs_display-menge < gs_layear_sum-kwmeng * '0.9'.
        " 전년도 판매량에 비해 90% 이하로 설정하셨습니다.
        MESSAGE i344.


      ELSEIF gs_display-menge < gs_layear_sum-kwmeng * '0.9'.
        " 전년도 판매량에 비해 1100% 이상으로 설정하셨습니다.
        MESSAGE i345.
      ENDIF.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_search_opt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_search_opt .

  " CHECK gv_ok IS NOT INITIAL.

  CLEAR gv_ch1.
  CLEAR gv_ch2.
  CLEAR gv_year_from.
  CLEAR gv_year_to.
  CLEAR gv_month_from.
  CLEAR gv_month_to.
  CLEAR gv_matnr_from.
  CLEAR gv_matnr_to.
  CLEAR gv_plnnr_from.
  CLEAR gv_plnnr_to.
  CLEAR gv_vkorg_from.
  CLEAR gv_vkorg_to.

  " 초기화가 완료되었습니다.
  MESSAGE s323.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_screen_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_screen_0100 .


  CHECK gv_ok IS NOT INITIAL.

  CLEAR gv_ch1.
  CLEAR gv_ch2.
  CLEAR gv_year_from.
  CLEAR gv_year_to.
  CLEAR gv_month_from.
  CLEAR gv_month_to.
  CLEAR gv_matnr_from.
  CLEAR gv_matnr_to.
  CLEAR gv_plnnr_from.
  CLEAR gv_plnnr_to.
  CLEAR gv_vkorg_from.
  CLEAR gv_vkorg_to.

  REFRESH gt_display.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_edit_style
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_edit_style .

  CLEAR gs_display.

  DATA: ls_style   TYPE lvc_s_styl,
        lv_curr_ym TYPE c LENGTH 6.

  lv_curr_ym = sy-datum(6).

  LOOP AT gt_display INTO gs_display.

    CLEAR gs_display-celltab.

    ls_style-fieldname = 'MENGE'.


    " 판매계획 일자가 다음달 이후 또는 MRP 실행이 되지 않은 건에 대해서만 수정이 가능하도록 한다
    IF ( gs_display-plan_month LE lv_curr_ym ) OR ( gs_display-mrp_stat EQ 'X' ).
      ls_style-style = cl_gui_alv_grid=>mc_style_disabled.
    ELSE.
      ls_style-style = cl_gui_alv_grid=>mc_style_enabled.
    ENDIF.

    APPEND ls_style TO gs_display-celltab.

    MODIFY gt_display FROM gs_display
    TRANSPORTING           celltab.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form show_last_year_chart
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM show_last_year_chart .

  CALL SCREEN 0120 STARTING AT 85 1 ENDING AT 165 8.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form set_gt_insert_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gs_insert_header.

  DATA : ls_plan_month    TYPE c LENGTH 6.

  CLEAR gs_insert_header.


  ls_plan_month = |{ gv_plan_year }{ gv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.


  gs_insert_header-plnnr      = gv_plnnr.
  gs_insert_header-vkorg      = gv_plan_vkorg.
  gs_insert_header-plan_month = ls_plan_month.
  gs_insert_header-erdat      = sy-datum.
  gs_insert_header-erzzt      = sy-uzeit.
  gs_insert_header-ernam      = sy-uname.

  APPEND gs_insert_header TO gt_insert_header.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gs_insert_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gs_insert_item .

  DATA: lv_max_posnr    TYPE ztd3sd0005-posnr,  " 아이템 번호 생성을 위해 참고
        lv_next_posnr   TYPE ztd3sd0005-posnr,  " 새로 생성할 아이템 번호
        lv_max_posnr_i  TYPE i,
        lv_next_posnr_i TYPE i,
        lv_price_id     TYPE ztd3sd0014-price_id.


  CLEAR gs_insert_item.


  " 판매계획 아이템 번호를 갖고 오기 위한로직
  " 해당 판매계획에 대해 처음 생성하면 값이 들어오지 않는다
  SELECT SINGLE MAX( posnr )
    FROM ztd3sd0005
    INTO @lv_max_posnr
   WHERE plnnr = @gv_plnnr
     AND lvorm = @space.

  " ITAB에서도 가져온다
  LOOP AT gt_insert_item INTO DATA(ls_item)
    WHERE plnnr = gv_plnnr.
    IF ls_item-posnr GT lv_max_posnr.
      lv_max_posnr = ls_item-posnr.
    ENDIF.
  ENDLOOP.

  " 판매계획 번호를 10단위로 가져온다
  IF lv_max_posnr IS INITIAL.
    lv_next_posnr = '0000000010'.
  ELSE.
    lv_max_posnr_i  = lv_max_posnr.
    lv_next_posnr_i = lv_max_posnr_i + 10.
    lv_next_posnr   = |{ lv_next_posnr_i WIDTH = 10  ALIGN = RIGHT PAD = '0' }|.
  ENDIF.

  " 가격정보를 가져오기 위한 로직
  SELECT SINGLE price_id
    FROM ztd3sd0014
    INTO @lv_price_id
   WHERE matnr EQ @gv_plan_matnr
     AND lvorm EQ @space.


  " 만약 계획 수량을 입력하지 않았으면 0으로 넣는다
  IF gv_plan_menge IS INITIAL OR gv_plan_menge EQ 0.
    gv_plan_menge = 0.
  ENDIF.




  " 아이템 저장
  CLEAR gs_insert_item.
  gs_insert_item-plnnr    = gv_plnnr.
  gs_insert_item-posnr    = lv_next_posnr.
  gs_insert_item-matnr    = gv_plan_matnr.
  gs_insert_item-price_id = lv_price_id.
  gs_insert_item-menge    = gv_plan_menge.
  gs_insert_item-meins    = gv_plan_meins.
  gs_insert_item-lvorm    = space.
  gs_insert_item-erdat    = sy-datum.
  gs_insert_item-erzzt    = sy-uzeit.
  gs_insert_item-ernam    = sy-uname.

  IF gs_insert_item-matnr BETWEEN '0000200001' AND '0000200007'.
    gs_insert_item-werks    = 'P00002'.
  ELSEIF gs_insert_item-matnr BETWEEN '0000200008' AND '0000200010'.
    gs_insert_item-werks    = 'P00001'.
  ENDIF.

  APPEND gs_insert_item TO gt_insert_item.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_gt_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM append_gt_display .

  " ITAB 초기화 후, 데이터 재검색
  CLEAR gs_display.
  " REFRESH gt_display.

  " 데이터 재검색
  " PERFORM select_data.

  " 화면에 보일 ITAB에 새로 추가된 데이터를 넣는다
  MOVE-CORRESPONDING gs_insert_header TO gs_display.
  MOVE-CORRESPONDING gs_insert_item   TO gs_display.

  " 영업 조직 추가
  gs_display-vkorg      = gv_plan_vkorg.

  " 계획 달 추가
  gs_display-plan_month =  |{ gv_plan_year }{ gv_plan_month }|.

  " 화면에 보일 ITAB에 영업조직 텍스트 추가
  PERFORM set_vktxt_0140.

  " 새로 데이터가 추가되었다는 것을 보이기 위한 행 컬러 세팅
  gs_display-line_color = 'C510'.

  " 새로 추가된 자재명을 불러오기 위한 로직
  SELECT SINGLE maktx
    FROM ztd3mm0001
   WHERE matnr EQ @gs_display-matnr
     AND lvorm EQ @space
    INTO @gs_display-maktx.

  " DB에 저장되어 있고 새로 추가된 데이터일 것임을 위한 로직
  APPEND gs_display TO gt_plan_all.
  " DB에 저장되지 않은 새로 추가된 데이터일 것임을 위한 로직
  APPEND gs_display TO gt_plan_new.

  " 화면에 보일 ITAB에 새로 생성할 데이터 추가
  APPEND gs_display TO gt_display.

  " 정렬
  SORT gt_display BY plan_month matnr vkorg  posnr.

  " 추가한 자재 포함한 건수를 재계산
  gv_count = lines( gt_plan_all ).

  " 검색된 결과가 없으면
  IF gv_no_count IS NOT INITIAL.
    gv_count = 0.
    CLEAR gv_no_count.
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_vktxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_vktxt .

  CLEAR gs_display.

  LOOP AT gt_display INTO gs_display.


    IF gs_display-vkorg EQ '1010'.
      gs_display-vktxt = TEXT-d01.    " 수도권
    ELSEIF gs_display-vkorg EQ '1020'.
      gs_display-vktxt = TEXT-d02.    " 비수도권
    ENDIF.

    MODIFY gt_display FROM gs_display.
  ENDLOOP.

ENDFORM.

**&---------------------------------------------------------------------*
**& Form get_sh_matnr
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM get_sh_matnr .
*
*  DATA: ls_shlp   TYPE shlp_descr,
*        lt_return TYPE TABLE OF ddshretval,
*        ls_return TYPE ddshretval,
*        ls_iface  TYPE ddshiface,
*        lt_dynp   TYPE TABLE OF dynpread,
*        ls_dynp   TYPE dynpread.
*
*  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
*    EXPORTING
*      shlpname = 'ZSHD3PP0003'
*      shlptype = 'SH'
*    IMPORTING
*      shlp     = ls_shlp.
*
*  LOOP AT ls_shlp-interface INTO ls_iface.
*    CASE ls_iface-shlpfield.
*      WHEN 'MATNR' OR 'MAKTX'.
*        ls_iface-valfield = 'X'.
*        MODIFY ls_shlp-interface FROM ls_iface.
*    ENDCASE.
*  ENDLOOP.
*
*  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
*    EXPORTING
*      shlp          = ls_shlp
*      maxrecords    = 500
*    TABLES
*      return_values = lt_return.
*
*  CLEAR: gv_matnr.
*
*  LOOP AT lt_return INTO ls_return.
*    CASE ls_return-fieldname.
*      WHEN 'MATNR'.
*        gv_matnr = ls_return-fieldval.
*      WHEN 'MAKTX'.
*        gv_matnm = ls_return-fieldval.
*    ENDCASE.
*  ENDLOOP.
*
*
*  CLEAR lt_dynp.
*  ls_dynp-fieldname  = 'GV_MATNR'.
*  ls_dynp-fieldvalue = gv_matnr.
*  APPEND ls_dynp TO lt_dynp.
*
*  CLEAR ls_dynp.
*  ls_dynp-fieldname  = 'GV_MATNM'.
*  ls_dynp-fieldvalue = gv_matnm.
*  APPEND ls_dynp TO lt_dynp.
*
*  CALL FUNCTION 'DYNP_VALUES_UPDATE'
*    EXPORTING
*      dyname     = sy-repid
*      dynumb     = sy-dynnr
*    TABLES
*      dynpfields = lt_dynp.
*
*ENDFORM.
**&---------------------------------------------------------------------*
**& Form get_sh_plnnr
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
**FORM get_sh_plnnr .
**
**  DATA: ls_shlp   TYPE shlp_descr,
**        lt_return TYPE TABLE OF ddshretval,
**        ls_return TYPE ddshretval,
**        ls_iface  TYPE ddshiface,
**        lt_dynp   TYPE TABLE OF dynpread,
**        ls_dynp   TYPE dynpread,
**        lv_rc     TYPE sy-subrc.
**
**  CLEAR: gv_plnnr.
**
**   1) 서치헬프 정의 읽기
**  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
**    EXPORTING
**      shlpname = 'ZSHD3SD0004'   " 네가 만든 PLNNR용 서치헬프명으로 변경
**      shlptype = 'SH'
**    IMPORTING
**      shlp     = ls_shlp
**    EXCEPTIONS
**      OTHERS   = 1.
**
**  IF sy-subrc <> 0.
**    RETURN.
**  ENDIF.
**
**   2) 반환받고 싶은 필드 지정
**  LOOP AT ls_shlp-interface INTO ls_iface.
**    CASE ls_iface-shlpfield.
**      WHEN 'PLNNR' OR 'VKORG'.
**        ls_iface-valfield = 'X'.
**        MODIFY ls_shlp-interface FROM ls_iface.
**    ENDCASE.
**  ENDLOOP.
**
**   3) 서치헬프 팝업 호출
**  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
**    EXPORTING
**      shlp          = ls_shlp
**      maxrecords    = 500
**      multisel      = space
**    IMPORTING
**      rc            = lv_rc
**    TABLES
**      return_values = lt_return
**    EXCEPTIONS
**      OTHERS        = 1.
**
**  IF sy-subrc <> 0 OR lt_return IS INITIAL.
**    RETURN.
**  ENDIF.
**
**   4) 서치헬프에서 받은 값 읽기
**  LOOP AT lt_return INTO ls_return.
**    CASE ls_return-fieldname.
**      WHEN 'PLNNR'.
**        gv_plnnr = ls_return-fieldval.
**      WHEN 'VKORG'.
**        gv_vkorg = ls_return-fieldval.
**    ENDCASE.
**  ENDLOOP.
**
**   5) 화면 필드 반영
**  CLEAR lt_dynp.
**
**  CLEAR ls_dynp.
**  ls_dynp-fieldname  = 'GV_PLNNR'.
**  ls_dynp-fieldvalue = gv_plnnr.
**  APPEND ls_dynp TO lt_dynp.
**
**  CLEAR ls_dynp.
**  ls_dynp-fieldname  = 'GV_VKORG'.
**  ls_dynp-fieldvalue = gv_vkorg.
**  APPEND ls_dynp TO lt_dynp.
**
**
**  CALL FUNCTION 'DYNP_VALUES_UPDATE'
**    EXPORTING
**      dyname     = sy-repid
**      dynumb     = sy-dynnr
**    TABLES
**      dynpfields = lt_dynp
**    EXCEPTIONS
**      OTHERS     = 1.
**
**
**
**ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sh_plan_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_sh_plan_matnr .

  DATA: ls_shlp   TYPE shlp_descr,
        lt_return TYPE TABLE OF ddshretval,
        ls_return TYPE ddshretval,
        ls_iface  TYPE ddshiface,
        lt_dynp   TYPE TABLE OF dynpread,
        ls_dynp   TYPE dynpread.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = 'ZSHD3PP0003'
      shlptype = 'SH'
    IMPORTING
      shlp     = ls_shlp.

  LOOP AT ls_shlp-interface INTO ls_iface.
    CASE ls_iface-shlpfield.
      WHEN 'MATNR' OR 'MAKTX' OR 'MTART'.
        ls_iface-valfield = 'X'.
        MODIFY ls_shlp-interface FROM ls_iface.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
      maxrecords    = 500
    TABLES
      return_values = lt_return.

  CLEAR: gv_plan_matnr, gv_plan_matnm.

  LOOP AT lt_return INTO ls_return.
    CASE ls_return-fieldname.
      WHEN 'MATNR'.
        gv_plan_matnr = ls_return-fieldval.
      WHEN 'MAKTX'.
        gv_plan_matnm = ls_return-fieldval.
      WHEN 'MTART'.
        gv_plan_mtart = ls_return-fieldval.
    ENDCASE.
  ENDLOOP.


  CLEAR lt_dynp.
  ls_dynp-fieldname  = 'GV_PLAN_MATNR'.
  ls_dynp-fieldvalue = gv_plan_matnr.
  APPEND ls_dynp TO lt_dynp.

  CLEAR ls_dynp.
  ls_dynp-fieldname  = 'GV_PLAN_MATNM'.
  ls_dynp-fieldvalue = gv_plan_matnm.
  APPEND ls_dynp TO lt_dynp.

  CLEAR ls_dynp.
  ls_dynp-fieldname  = 'GV_PLAN_MTART'.
  ls_dynp-fieldvalue = gv_plan_mtart.
  APPEND ls_dynp TO lt_dynp.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_dynp.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form edit_plan_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit_plan_item .


  LOOP AT gt_display INTO gs_display.

    READ TABLE gt_display_old INTO gs_display_old
      WITH KEY plnnr      = gs_display-plnnr
               posnr      = gs_display-posnr.

    IF sy-subrc = 0.

      " 값이 변경된 경우
      IF gs_display_old-menge <> gs_display-menge.

        gs_display-aedat = sy-datum.
        gs_display-aezet = sy-uzeit.
        gs_display-aenam = sy-uname.

        MODIFY gt_display FROM gs_display INDEX sy-tabix
        TRANSPORTING menge aedat aezet aenam line_color.
      ENDIF.

    ENDIF.

  ENDLOOP.




ENDFORM.

*&---------------------------------------------------------------------*
*& Form save_change_plan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PLNNR
*&---------------------------------------------------------------------*
FORM save_change_plan.

  " 값 수정인 경우, 수정된 일자, 시간, 이름을 저장하기 위한 로직
  PERFORM edit_plan_item.
  " DB 업데이트
  PERFORM update_plan_item.

  IF sy-subrc = 0.
    COMMIT WORK.
    "     gt_display_old = gt_display.
    " 329 : 판매계획이 수정되었습니다.
    MESSAGE s329.
  ELSE.
    ROLLBACK WORK.
    " 330 : 판매계획 수정에 실패했습니다.
    MESSAGE s330 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_plan_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_LV_PLNNR
*&---------------------------------------------------------------------*
FORM update_plan_item.

  DATA lv_subrc TYPE sy-subrc.

  lv_subrc = 0.

  LOOP AT gt_display INTO gs_display.

    " MRP가 반영된 건은 수정되지 않게 한다
    IF gs_display-mrp_stat IS NOT INITIAL.
      CONTINUE.
    ENDIF.


    " 판매계획 헤더 테이블 수정 > 변경 시간만
    UPDATE ztd3sd0004
       SET aedat = @gs_display-aedat,
           aezet = @gs_display-aezet,
           aenam = @gs_display-aenam
     WHERE plnnr = @gs_display-plnnr
       AND lvorm = @space.


    " 판매계획 아이템 테이블 수정
    UPDATE ztd3sd0005
       SET menge = @gs_display-menge,
           aedat = @gs_display-aedat,
           aezet = @gs_display-aezet,
           aenam = @gs_display-aenam
     WHERE plnnr = @gs_display-plnnr
       AND posnr = @gs_display-posnr
       AND matnr = @gs_display-matnr
       AND lvorm = @space.

    IF sy-subrc <> 0.
      lv_subrc = sy-subrc.
      EXIT.
    ENDIF.

  ENDLOOP.

  sy-subrc = lv_subrc.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ll
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit_plan.
  CALL METHOD go_alv_grid->check_changed_data.

  IF gt_display_old EQ gt_display.
    " 905 : 변경된 데이터가 없습니다.
    MESSAGE s905 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM save_change_plan.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_plan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_plan .
  DATA : lv_cnt_old TYPE i.
  DATA : lv_cnt     TYPE i.

  lv_cnt_old = lines( gt_display_old ).
  lv_cnt     = lines( gt_display ).

* 기존의 판매계획번호가 있는지 확인
  SELECT SINGLE a~plnnr
    INTO @lv_plnnr
    FROM ztd3sd0004 AS a
   INNER JOIN ztd3sd0005 AS b
      ON a~plnnr = b~plnnr
   WHERE a~plan_month EQ @lv_plan_month
     AND a~vkorg      EQ @gv_plan_vkorg
     AND b~werks      EQ @gs_insert_item-werks
     AND a~lvorm      EQ @space
     AND b~lvorm      EQ @space.

  " 기존의 판매계획번호가 존재하지 않는다면 넘버레인지 새로 발급해서 새로운 판매계획번호 생성
  " 그에 따른 헤더 테이블도 생성
  IF sy-subrc NE 0.
    PERFORM insert_plan_header.
    PERFORM insert_plan_item.
    " 기존의 판매계획번호가 존재한다면
    " 생성 : 판매계획 아이템 테이블에 데이터 생성 > 생성일자에 데이터 삽입
    " 수정 : 판매계획 아이템 테이블 데이터 수정   > 수정일자에 데이터 삽입
  ELSE.
    IF lv_cnt_old NE lv_cnt.
      PERFORM insert_plan_item.
    ELSE.
      " 905 : 변경된 데이터가 없습니다.
      MESSAGE s905 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_edit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_edit .

  DATA lv_changed TYPE abap_bool.

  CALL METHOD go_alv_grid->check_changed_data.

  CLEAR lv_changed.

  LOOP AT gt_display INTO gs_display.

    CLEAR gs_display_old.

    READ TABLE gt_display_old INTO gs_display_old
      WITH KEY plnnr = gs_display-plnnr
               posnr = gs_display-posnr
               matnr = gs_display-matnr.

    " 기존에 없던 신규 행이면 변경된 것으로 봄
    IF sy-subrc <> 0.
      lv_changed = abap_true.
      EXIT.
    ENDIF.

    " 실제 저장 대상 필드만 비교
    IF gs_display-menge <> gs_display_old-menge.
      lv_changed = abap_true.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF lv_changed = abap_true.

    PERFORM popup_to_confirm USING sy-ucomm
                                   gv_ok.

    CHECK gv_ok IS NOT INITIAL.

  ENDIF.


  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_for_changed_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_for_changed_data .
  " 저장 버튼을 누르면 다시 반영된 테이블로 초기값 세팅
  IF gv_start EQ abap_true.

    gt_display_old = gt_display.

    gv_start = abap_false.
  ENDIF.



  REFRESH gt_insert_header.
  REFRESH gt_insert_item.
  CLEAR gs_insert_header.
  CLEAR gs_insert_item.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_mat_data_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_mat_data_0140 .

  REFRESH gt_mat.

  " 완재품만 조회한다
  SELECT matnr,
         maktx,
         mtart
    FROM ztd3mm0001
   WHERE matnr LIKE '00002%'
     AND lvorm EQ @space
    INTO CORRESPONDING FIELDS OF TABLE @gt_mat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0140 .

  CREATE OBJECT go_custom_container
    EXPORTING
      container_name = 'CCON3'.

  IF go_splitter IS INITIAL.
    CREATE OBJECT go_splitter
      EXPORTING
        parent  = go_custom_container
        rows    = 1
        columns = 2.

    go_container3 = go_splitter->get_container( row = 1 column = 1 ).
    go_container4 = go_splitter->get_container( row = 1 column = 2 ).

    " 비율 조정
    CALL METHOD go_splitter->set_column_width
      EXPORTING
        id    = 1
        width = 30.

    CALL METHOD go_splitter->set_column_width
      EXPORTING
        id    = 2
        width = 70.
  ENDIF.

  IF go_tree IS INITIAL.
    CREATE OBJECT go_tree
      EXPORTING
        parent              = go_container3
        node_selection_mode = cl_gui_column_tree=>node_sel_mode_single.
  ENDIF.

  IF go_alv_grid4 IS INITIAL.
    CREATE OBJECT go_alv_grid4
      EXPORTING
        i_parent = go_container4.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_0140 .
  " 트리를 위한 레이아웃
  CLEAR gs_hierarchy_header.
  gs_hierarchy_header-heading = TEXT-t11. " T11 : 자재번호
  gs_hierarchy_header-width   = 30.

  CLEAR gs_layout4.
  "gs_layout4-cwidth_opt = abap_true.
  gs_layout4-zebra      = abap_true.

  gs_variant4 = sy-uzeit.
  gv_save4 = 'A'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0140 .

  " 트리를 위한 필드 카탈로그
  REFRESH gt_fieldcat3.

  " 자재명
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MAKTX'.
  gs_fieldcat-outputlen = 30.
  gs_fieldcat-coltext   = TEXT-t12.
  APPEND gs_fieldcat TO gt_fieldcat3.


  " 판매계획을 위한 필드 카탈로그
  REFRESH gt_fieldcat4.

  DEFINE _set_fieldcat.
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname     = &1.
    gs_fieldcat-coltext       = &2.
    gs_fieldcat-edit          = &3.
    gs_fieldcat-outputlen     = &4.
    gs_fieldcat-hotspot       = &5.
    gs_fieldcat-qfieldname    = &6.
    gs_fieldcat-no_out        = &7.
    APPEND gs_fieldcat TO gt_fieldcat4.
  END-OF-DEFINITION.



  "              fieldname        coltext              edit  key    hotspot  qfieldname   no_out
  _set_fieldcat 'PLAN_VKORG'     '판매 계획 영업조직'  ''    15     ''       ''           ''.
  _set_fieldcat 'PLAN_YEAR'      '판매 계획 년도'      ''    10     ''       ''           ''.
  _set_fieldcat 'PLAN_MONTH'     '판매 계획 월'        ''    8     ''       ''           ''.
  _set_fieldcat 'PLAN_MATNR'     '판매 계획 자재번호'  ''    12    ''        ''           ''.
  _set_fieldcat 'PLAN_MATNM'     '판매 계획 자재명'    ''    25    ''        ''           ''.
  _set_fieldcat 'PLAN_MENGE'     '판매 계획 수량'      'X'   10    ''        'PLAN_MEINS' ''.
  _set_fieldcat 'PLAN_MEINS'     '판매 계획 단위'      ''    10    ''        ''           ''.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_handler_event_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_handler_event_0140 .

  " 이벤트 등록을 위한 내부 테이블 (여러 이벤트를 등록 가능)
  DATA: lt_events TYPE cntl_simple_events,
        ls_event  TYPE cntl_simple_event.

  "--------------------------------------------------
  " 1. 이미 이벤트 등록이 끝났으면 다시 하지 않음
  "    (중복 등록 방지)
  "--------------------------------------------------
*  IF gv_event_init_0140 = abap_true.
*    RETURN.
*  ENDIF.

  CLEAR lt_events.
  CLEAR ls_event.

  "--------------------------------------------------
  " 2. 어떤 이벤트를 받을지 정의
  "    트리에서 '아이템 더블클릭' 이벤트
  "--------------------------------------------------
  ls_event-eventid    = cl_gui_column_tree=>eventid_item_double_click.

  " appl_event = space
  " → SAP GUI 이벤트로 처리 (일반적인 방식)
  " → 'X'면 application 이벤트 (거의 안 씀)
  ls_event-appl_event = space.

  " 이벤트 테이블에 추가
  APPEND ls_event TO lt_events.

  "--------------------------------------------------
  " 3. 트리 객체에 이벤트 등록
  "    "이 이벤트를 감지하겠다" 라는 선언
  "--------------------------------------------------
  CALL METHOD go_tree->set_registered_events
    EXPORTING
      events = lt_events.

  "--------------------------------------------------
  " 4. 이벤트 발생 시 실행될 ABAP 메서드 연결
  "    실제 로직과 이벤트를 연결하는 핵심
  "--------------------------------------------------
  SET HANDLER lcl_event_handler=>on_item_double_click FOR go_tree.


  "
  SET HANDLER lcl_event_handler=>on_data_changed FOR go_alv_grid4.

  CALL METHOD go_alv_grid4->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_0140 .


  CALL METHOD go_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = gs_hierarchy_header
    CHANGING
      it_outtab           = gt_dummy
      it_fieldcatalog     = gt_fieldcat3.


  CALL METHOD go_alv_grid4->set_table_for_first_display
    EXPORTING
      is_variant      = gs_variant4
      i_save          = gv_save4
      is_layout       = gs_layout4
    CHANGING
      it_outtab       = gt_display4
      it_fieldcatalog = gt_fieldcat4.

  gt_display4_old = gt_display4.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form add_node_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_node_0140 .

  DATA: lv_root_key  TYPE lvc_nkey,   " 루트 노드 키
        lv_child_key TYPE lvc_nkey,   " 자식 노드 키
        lv_node_text TYPE lvc_value,  " 노드에 표시할 텍스트
        ls_root_line TYPE ztd3mm0001. " 루트용 더미 라인

*  "---------------------------------------
*  " 1. 이미 트리 생성 완료되었으면 다시 생성하지 않음
*  "---------------------------------------
*  IF gv_node_init_0140 = abap_true.
*    RETURN.
*  ENDIF.
*
*  "---------------------------------------
*  " 2. 자재 데이터가 없으면 트리 생성 안 함
*  "---------------------------------------
*  IF gt_mat IS INITIAL.
*    RETURN.
*  ENDIF.

  "---------------------------------------
  " 3. 트리 노드 ↔ 자재 매핑 테이블 초기화
  "    (나중에 클릭 이벤트에서 사용)
  "---------------------------------------
  REFRESH gt_tree_map.

  "---------------------------------------
  " 4. 루트 노드 생성용 데이터 가져오기
  "    (자재유형 기준으로 폴더 하나 만듦)
  "---------------------------------------
  READ TABLE gt_mat INTO gs_mat INDEX 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
  " 루트 노드 텍스트 = 자재유형 (완제품)
  lv_node_text = gs_mat-mtart.


  " 루트는 실제 데이터가 아니라 폴더라서 내용 비움
  CLEAR ls_root_line.
  CLEAR ls_root_line-maktx.

  "---------------------------------------
  " 5. 루트 노드 생성
  "---------------------------------------
  CALL METHOD go_tree->add_node
    EXPORTING
      i_relat_node_key = ''   " 부모 없음 → 최상위 노드
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = lv_node_text        " 화면 표시 텍스트
      is_outtab_line   = ls_root_line        " 데이터 (더미)
    IMPORTING
      e_new_node_key   = lv_root_key.        " 생성된 노드 키 반환

  "---------------------------------------
  " 6. 자재 데이터를 자식 노드로 생성
  "---------------------------------------
  LOOP AT gt_mat INTO gs_mat.

    " 자식 노드 텍스트 = 자재번호
    lv_node_text = gs_mat-matnr.

    CALL METHOD go_tree->add_node
      EXPORTING
        i_relat_node_key = lv_root_key      " 루트 아래에 붙임
        i_relationship   = cl_gui_column_tree=>relat_last_child
        i_node_text      = lv_node_text     " 화면 표시 텍스트
        is_outtab_line   = gs_mat           " 실제 데이터 연결
      IMPORTING
        e_new_node_key   = lv_child_key.    " 생성된 자식 노드 키

    "---------------------------------------
    " 7. 노드 키 ↔ 자재번호 매핑 저장
    "---------------------------------------
    CLEAR gs_tree_map.
    gs_tree_map-node_key = lv_child_key.   " 트리 노드 키
    gs_tree_map-matnr    = gs_mat-matnr.   " 실제 자재번호
    APPEND gs_tree_map TO gt_tree_map.

  ENDLOOP.

  "---------------------------------------
  " 8. 루트 노드 자동 펼치기
  "---------------------------------------
  CALL METHOD go_tree->expand_node
    EXPORTING
      i_node_key = lv_root_key.

  "---------------------------------------
  " 9. 트리 화면 갱신
  "---------------------------------------
  CALL METHOD go_tree->frontend_update.

  "---------------------------------------
  " 10. 생성 완료 플래그
  "---------------------------------------
  " gv_node_init_0140 = abap_true.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_tree_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> NODE_KEY
*&---------------------------------------------------------------------*
FORM handle_tree_click  USING    pv_node_key TYPE tv_nodekey.

  " 140번 ALV에서 삭제한 행 감지
  PERFORM check_deleted_plan_rows.

  DATA : lv_count       TYPE i,
         lv_plan_year   TYPE c LENGTH 4,
         lv_plan_month  TYPE c LENGTH 2,
         lt_vkorg       TYPE TABLE OF ztd3sd0004-vkorg,
         lv_plan_vkorg  TYPE ztd3sd0004-vkorg,
         lv_plan_plant  TYPE ztd3sd0005-werks,
         lv_matnm       TYPE ztd3mm0001-maktx,
         ls_outtab_line TYPE ztd3mm0001.

  CLEAR: gs_tree_map.

  READ TABLE gt_tree_map INTO gs_tree_map
    WITH KEY node_key = pv_node_key.

  IF sy-subrc <> 0.
    MESSAGE s327 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  READ TABLE gt_mat INTO ls_outtab_line
    WITH KEY matnr = gs_tree_map-matnr.

  CALL METHOD go_tree->change_node
    EXPORTING
      i_node_key    = pv_node_key
      i_outtab_line = ls_outtab_line
      i_node_text   = |✓{ gs_tree_map-matnr }|
      i_u_node_text = abap_true.

  CALL METHOD go_tree->frontend_update.

  SELECT SINGLE maktx
    FROM ztd3mm0001
   WHERE matnr EQ @gs_tree_map-matnr
     AND lvorm EQ @space
    INTO @lv_matnm.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF gs_tree_map-matnr BETWEEN '0000200001' AND '0000200007'.
    lv_plan_plant = 'P00002'.
  ELSEIF gs_tree_map-matnr BETWEEN '0000200008' AND '0000200010'.
    lv_plan_plant = 'P00001'.
  ENDIF.

  lv_count      = 3.
  lv_plan_year  = sy-datum(4).
  lv_plan_month = sy-datum+4(2) + 1.
  lt_vkorg = VALUE #( ( '1010' ) ( '1020' ) ).

  DO lv_count TIMES.

    LOOP AT lt_vkorg INTO lv_plan_vkorg.

      READ TABLE gt_display4 TRANSPORTING NO FIELDS
        WITH KEY plan_vkorg = lv_plan_vkorg
                 plan_matnr = gs_tree_map-matnr
                 plan_year  = lv_plan_year
                 plan_month = lv_plan_month.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      READ TABLE gt_plan_all TRANSPORTING NO FIELDS
        WITH KEY vkorg      = lv_plan_vkorg
                 matnr      = gs_tree_map-matnr
                 plan_month = |{ lv_plan_year }{ lv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      READ TABLE gt_plan_all TRANSPORTING NO FIELDS
        WITH KEY plan_month = |{ lv_plan_year }{ lv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|
                 matnr      = gs_tree_map-matnr
                 mrp_stat   = 'X'.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      READ TABLE gt_plan_deleted TRANSPORTING NO FIELDS
        WITH KEY plan_vkorg = lv_plan_vkorg
                 plan_matnr = gs_tree_map-matnr
                 plan_month = |{ lv_plan_year }{ lv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR gs_display4.

      gs_display4-plan_vkorg = lv_plan_vkorg.
      gs_display4-plan_matnr = gs_tree_map-matnr.
      gs_display4-plan_matnm = lv_matnm.
      gs_display4-plan_year  = lv_plan_year.
      gs_display4-plan_month = lv_plan_month.
      gs_display4-plan_meins = 'EA'.
      gs_display4-plan_werks = lv_plan_plant.

      APPEND gs_display4 TO gt_display4.

    ENDLOOP.

    lv_plan_month += 1.

    IF lv_plan_month GE 13.
      lv_plan_month = 1.
      lv_plan_year += 1.
    ENDIF.

  ENDDO.

  IF go_alv_grid4 IS BOUND.
    go_alv_grid4->refresh_table_display( ).
    gt_display4_old = gt_display4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_alv_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_alv_0140 .

  " 140번 실행 후에만 실행하기 위해
  CHECK sy-dynnr EQ '0140'.

  REFRESH gt_dummy.

  REFRESH: gt_tree_map, gt_display4, gt_display4_old, gt_mat.
  CLEAR: gs_tree_map, gs_display4, gs_display4_old, gs_mat.

  " 객체를 생성한 역순으로 객체를 삭제해야 한다
  " 객체 생성 순서
  " 1. go_custom_container
  " 2. go_splitter
  " 3. go_container3
  " 4. go_container4
  " 5. go_tree
  " 6. go_alv_grid4
  IF go_alv_grid4 IS BOUND.
    CALL METHOD go_alv_grid4->free.
  ENDIF.
  FREE go_alv_grid4.

  IF go_tree IS BOUND.
    CALL METHOD go_tree->free.
  ENDIF.
  FREE go_tree.


  IF go_container4 IS BOUND.
    CALL METHOD go_container4->free.
  ENDIF.
  FREE go_container4.

  IF go_container3 IS BOUND.
    CALL METHOD go_container3->free.
  ENDIF.
  FREE go_container3.

  IF go_splitter IS BOUND.
    CALL METHOD go_splitter->free.
  ENDIF.
  FREE go_splitter.

  IF go_custom_container IS BOUND.
    CALL METHOD go_custom_container->free.
  ENDIF.
  FREE go_custom_container.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form add_multi_plan
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_multi_plan .



  DATA : lv_cnt_old TYPE i.
  DATA : lv_cnt     TYPE i.

  lv_cnt_old = lines( gt_display_old ).
  lv_cnt     = lines( gt_display ).

* 기존의 판매계획번호가 있는지 확인
  SELECT SINGLE a~plnnr
    INTO @lv_plnnr
    FROM ztd3sd0004 AS a
   INNER JOIN ztd3sd0005 AS b
      ON a~plnnr = b~plnnr
   WHERE a~plan_month EQ @lv_plan_month
     AND a~vkorg      EQ @gv_plan_vkorg
     AND b~werks      EQ @gs_insert_item-werks
     AND a~lvorm      EQ @space
     AND b~lvorm      EQ @space.

  " 기존의 판매계획번호가 존재하지 않는다면 넘버레인지 새로 발급해서 새로운 판매계획번호 생성
  " 그에 따른 헤더 테이블도 생성
  IF sy-subrc NE 0.
    PERFORM insert_multi_plan_header.
    PERFORM insert_multi_plan_item.
    " 기존의 판매계획번호가 존재한다면
    " 생성 : 판매계획 아이템 테이블에 데이터 생성 > 생성일자에 데이터 삽입
    " 수정 : 판매계획 아이템 테이블 데이터 수정   > 수정일자에 데이터 삽입
  ELSE.
    " 이미 계획 달이 존재한다면 아이템 테이블 데이터만 생성
    IF lv_cnt_old NE lv_cnt.
      PERFORM insert_multi_plan_item.
    ELSE.
    ENDIF.


  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_data_from_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_data_from_0140 .

  DATA: lv_plan_month   TYPE ztd3sd0004-plan_month,
        lv_plnnr        TYPE ztd3sd0004-plnnr,
        lv_exist_matnr  TYPE ztd3sd0005-matnr,
        lv_max_posnr    TYPE ztd3sd0005-posnr,
        lv_next_posnr   TYPE ztd3sd0005-posnr,
        lv_max_posnr_i  TYPE i,
        lv_next_posnr_i TYPE i.
  " lv_price_id     TYPE ztd3sd0014-price_id.

  "REFRESH : gt_insert_header, gt_insert_item.

  " 새로 생성된 데이터만 담는다
  REFRESH gt_plan_new.

  CLEAR gs_display4.

  LOOP AT gt_display4 INTO gs_display4.

    CLEAR: gs_display, gs_insert_header, gs_insert_item,
           gv_plnnr, lv_plnnr, lv_exist_matnr,
           lv_max_posnr, lv_next_posnr.

    " 계획달 세팅
    lv_plan_month = |{ gs_display4-plan_year }{ gs_display4-plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.


    "--------------------------------------------------
    " DB에 이미 있으면 skip
    "--------------------------------------------------
    SELECT SINGLE b~matnr
      FROM ztd3sd0004 AS a
      INNER JOIN ztd3sd0005 AS b
        ON a~plnnr = b~plnnr
     WHERE a~plan_month = @lv_plan_month
       AND a~vkorg      = @gs_display4-plan_vkorg
       AND b~matnr      = @gs_display4-plan_matnr
       AND b~werks      = @gs_display4-plan_werks
       AND a~lvorm      = @space
       AND b~lvorm      = @space
      INTO @lv_exist_matnr.

    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.

    "--------------------------------------------------
    " 3. 헤더 plnnr 찾기
    "    DB 우선 -> 없으면 이번 생성분 gt_insert_header 확인 -> 그래도 없으면 새 번호
    "--------------------------------------------------
    SELECT SINGLE a~plnnr
      FROM       ztd3sd0004 AS a
      INNER JOIN ztd3sd0005 AS b
      ON         a~plnnr EQ b~plnnr
     WHERE plan_month = @lv_plan_month
       AND vkorg      = @gs_display4-plan_vkorg
       AND werks      = @gs_display4-plan_werks
       AND a~lvorm    = @space
       AND b~lvorm    = @space
      INTO @lv_plnnr.


    " 판매계획 번호 채번 로직
    " DB 확인 ( 없으면 )
    IF sy-subrc NE 0.

      CLEAR gs_plan_all.

      " 내부 테이블에 DB에 저장되지 않은 이미 생성된 데이터가 있는지 확인
      " 반영이 이미 되어 있는 경우, lv_plnnr에 데이터가 들어온다
      READ TABLE gt_plan_all INTO gs_plan_all
        WITH KEY plan_month = lv_plan_month
                 vkorg      = gs_display4-plan_vkorg
                 werks      = gs_display4-plan_werks.

      lv_plnnr = gs_plan_all-plnnr.

      " 내부테이블에 이미 추가가 되어 있으면( lv_plnnr에 데이터가 들어온 경우 )
      IF lv_plnnr IS NOT INITIAL.
        gv_plnnr = lv_plnnr.

        " 내부 테이블에 추가가 안되어 있으면( lv_plnnr에 데이터가 들어오지 않은 경우 )
      ELSE.
        " 판매계획번호 생성
        PERFORM get_plan_number CHANGING gv_plnnr.
        " 다건용 판매계획 헤더 테이블에 데이터 저장할 GT에 데이터를 넣는다
        " 단건 : GS -> insert
        " 다건 : GT -> insert 하기 위해
        PERFORM get_plan_header_multi USING lv_plan_month.

      ENDIF.

      " DB 확인 ( 있으면 )
    ELSE.
      gv_plnnr = lv_plnnr.
    ENDIF.


    PERFORM get_plan_item_multi USING lv_next_posnr.

    "--------------------------------------------------
    " 7. 100번 ALV용 gt_display 적재
    "--------------------------------------------------

    " 영업조직 텍스트
    " 안에 클리어도 같이 있음

    CLEAR gs_display.



    gs_display-plan_month = lv_plan_month.
    gs_display-matnr      = gs_display4-plan_matnr.
    gs_display-maktx      = gs_display4-plan_matnm.
    gs_display-plnnr      = gv_plnnr.
    gs_display-posnr      = lv_next_posnr.
    gs_display-vkorg      = gs_display4-plan_vkorg.
    gs_display-menge      = gs_display4-plan_menge.
    gs_display-meins      = gs_display4-plan_meins.
    gs_display-werks      = gs_display4-plan_werks.
    gs_display-erdat      = sy-datum.
    gs_display-erzzt      = sy-uzeit.
    gs_display-ernam      = sy-uname.
    gs_display-line_color = 'C510'.

    " 영업조직 텍스트
    PERFORM set_vktxt_0140.


    APPEND gs_display TO gt_plan_all.
    APPEND gs_display TO gt_plan_new.

  ENDLOOP.

  CLEAR gv_plnnr.

  gv_count = lines( gt_plan_all ).

  " 검색된 결과가 없으면
  IF gv_no_count IS NOT INITIAL.
    gv_count = 0.
    CLEAR gv_no_count.
  ENDIF.


  APPEND LINES OF gt_plan_new TO gt_display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_data_from_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_data_from_display .
  DATA: ls_header_exist LIKE gs_insert_header,
        lv_price_id     TYPE ztd3sd0014-price_id.

  CLEAR: gt_insert_header, gt_insert_item.

  LOOP AT gt_display INTO gs_display.

    "-----------------------------
    " 1. 헤더 적재
    "    같은 plnnr는 한 번만
    "-----------------------------
    READ TABLE gt_insert_header INTO ls_header_exist
      WITH KEY plnnr = gs_display-plnnr.

    IF sy-subrc <> 0.
      CLEAR gs_insert_header.
      gs_insert_header-plnnr      = gs_display-plnnr.
      gs_insert_header-vkorg      = gs_display-vkorg.
      gs_insert_header-plan_month = gs_display-plan_month.
      gs_insert_header-erdat      = gs_display-erdat.
      gs_insert_header-erzzt      = gs_display-erzzt.
      gs_insert_header-ernam      = gs_display-ernam.
      gs_insert_header-aedat      = gs_display-aedat.
      gs_insert_header-aezet      = gs_display-aezet.
      gs_insert_header-aenam      = gs_display-aenam.
      gs_insert_header-lvorm      = space.
      APPEND gs_insert_header TO gt_insert_header.
    ENDIF.

    "-----------------------------
    " 2. price_id 조회
    "-----------------------------
    CLEAR lv_price_id.
    SELECT SINGLE price_id
      INTO @lv_price_id
      FROM ztd3sd0014
     WHERE matnr = @gs_display-matnr
       AND lvorm EQ @space.

    "-----------------------------
    " 3. 아이템 적재
    "-----------------------------
    CLEAR gs_insert_item.
    gs_insert_item-plnnr    = gs_display-plnnr.
    gs_insert_item-posnr    = gs_display-posnr.
    gs_insert_item-matnr    = gs_display-matnr.
    gs_insert_item-price_id = lv_price_id.
    gs_insert_item-meins    = gs_display-meins.
    gs_insert_item-erdat    = gs_display-erdat.
    gs_insert_item-erzzt    = gs_display-erzzt.
    gs_insert_item-ernam    = gs_display-ernam.
    gs_insert_item-aedat    = gs_display-aedat.
    gs_insert_item-aezet    = gs_display-aezet.
    gs_insert_item-aenam    = gs_display-aenam.
    gs_insert_item-lvorm    = space.

    APPEND gs_insert_item TO gt_insert_item.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv_0140 .

  go_alv_grid4->refresh_table_display( ).

  gt_display4_old = gt_display4.


  CALL METHOD go_alv_grid4->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_plan_header_multi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_plan_header_multi USING pv_plan_month TYPE ztd3sd0004-plan_month.

  CLEAR gs_insert_header.
  gs_insert_header-mandt      = 100.
  gs_insert_header-plnnr      = gv_plnnr.
  gs_insert_header-vkorg      = gs_display4-plan_vkorg.
  gs_insert_header-plan_month = pv_plan_month.
  gs_insert_header-erdat      = sy-datum.
  gs_insert_header-erzzt      = sy-uzeit.
  gs_insert_header-ernam      = sy-uname.
  gs_insert_header-lvorm      = space.

  APPEND gs_insert_header TO gt_insert_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_plan_item_multi
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_plan_item_multi CHANGING pv_posnr TYPE ztd3sd0005-posnr.

  DATA : lv_max_posnr    TYPE ztd3sd0005-posnr,
         lv_max_posnr_i  TYPE i,
         lv_next_posnr_i TYPE i.

  "--------------------------------------------------
  " 4. posnr 계산
  "    DB 기준 max + 이번 생성분 gt_insert_item 반영
  "--------------------------------------------------
  SELECT SINGLE MAX( posnr )
    INTO @lv_max_posnr
    FROM ztd3sd0005
   WHERE plnnr = @gv_plnnr
     AND lvorm = @space.

  LOOP AT gt_insert_item INTO DATA(ls_item)
    WHERE plnnr = gv_plnnr.
    IF ls_item-posnr GT lv_max_posnr.
      lv_max_posnr = ls_item-posnr.
    ENDIF.
  ENDLOOP.

  IF lv_max_posnr IS INITIAL.
    pv_posnr = '0000000010'.
  ELSE.
    lv_max_posnr_i  = lv_max_posnr.
    lv_next_posnr_i = lv_max_posnr_i + 10.
    pv_posnr   = |{ lv_next_posnr_i WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
  ENDIF.

  "--------------------------------------------------
  " 5. price_id 조회
  "--------------------------------------------------
  SELECT SINGLE price_id
    INTO @DATA(lv_price_id)
    FROM ztd3sd0014
   WHERE matnr = @gs_display4-plan_matnr
     AND lvorm EQ @space.

  "--------------------------------------------------
  " 6. gt_insert_item 적재
  "--------------------------------------------------
  CLEAR gs_insert_item.
  gs_insert_item-plnnr    = gv_plnnr.
  gs_insert_item-posnr    = pv_posnr.
  gs_insert_item-matnr    = gs_display4-plan_matnr.
  gs_insert_item-price_id = lv_price_id.
  gs_insert_item-menge    = gs_display4-plan_menge.
  gs_insert_item-meins    = gs_display4-plan_meins.
  gs_insert_item-lvorm    = space.
  gs_insert_item-erdat    = sy-datum.
  gs_insert_item-erzzt    = sy-uzeit.
  gs_insert_item-ernam    = sy-uname.

  IF gs_insert_item-matnr BETWEEN '0000200001' AND '0000200007'.
    gs_insert_item-werks = 'P00002'.
  ELSE.
    gs_insert_item-werks = 'P00001'.
  ENDIF.



  APPEND gs_insert_item TO gt_insert_item.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_last_year_month_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_last_year_month_so .

  " PERFORM select_last_year_month_so2.

  " 전체 제품의 작년 달별 판매량 계산
  PERFORM sum_lastmonth_qua.


  REFRESH gt_chart.

  LOOP AT gt_layear_sum INTO gs_layear_sum
    WHERE matnr = gv_chart_matnr.

    CLEAR gs_chart.
    gs_chart-month  = gs_layear_sum-month.
    gs_chart-vkorg  = gs_layear_sum-vkorg.
    gs_chart-kwmeng = gs_layear_sum-kwmeng.
    APPEND gs_chart TO gt_chart.

  ENDLOOP.

  SORT gt_chart BY month.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_0120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0120 .
  CREATE OBJECT go_container2
    EXPORTING
      container_name = 'CCON2'.

  CREATE OBJECT go_chart
    EXPORTING
      parent = go_container2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_chart_data_xml_0120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_chart_data_xml_0120 .

  DATA: lo_doc      TYPE REF TO if_ixml_document,
        lo_root     TYPE REF TO if_ixml_element,
        lo_cat      TYPE REF TO if_ixml_element,
        lo_series   TYPE REF TO if_ixml_element,
        lo_elem     TYPE REF TO if_ixml_element,
        lo_encoding TYPE REF TO if_ixml_encoding,
        lo_ostream  TYPE REF TO if_ixml_ostream.

  TYPES: BEGIN OF ty_month,
           month TYPE c LENGTH 2,
         END OF ty_month.

  TYPES: BEGIN OF ty_vkorg,
           vkorg TYPE ztd3sd0006-vkorg,
         END OF ty_vkorg.

  TYPES: BEGIN OF ty_vkorg_txt,
           vkorg TYPE ztd3sd0006-vkorg,
           text  TYPE text10,
         END OF ty_vkorg_txt.

  DATA: lt_month     TYPE SORTED TABLE OF ty_month WITH UNIQUE KEY month,
        ls_month     TYPE ty_month,

        lt_vkorg     TYPE SORTED TABLE OF ty_vkorg WITH UNIQUE KEY vkorg,
        ls_vkorg     TYPE ty_vkorg,

        lt_vkorg_txt TYPE SORTED TABLE OF ty_vkorg_txt WITH UNIQUE KEY vkorg,
        ls_vkorg_txt TYPE ty_vkorg_txt,

        lv_qty       TYPE ztd3sd0007-kwmeng,
        lv_label     TYPE string.

  CLEAR gv_chart_xdata.

  lo_doc = go_ixml->create_document( ).

  lo_encoding = go_ixml->create_encoding(
                  byte_order    = if_ixml_encoding=>co_little_endian
                  character_set = 'utf-8' ).
  lo_doc->set_encoding( lo_encoding ).

  lo_root = lo_doc->create_simple_element(
              name   = 'SimpleChartData'
              parent = lo_doc ).

  "--------------------------------------------------
  " 월 / 영업조직 중복 제거
  "--------------------------------------------------

  IF gt_chart IS INITIAL.
    lt_month = VALUE #(
      ( month = '01' )
      ( month = '02' )
      ( month = '03' )
      ( month = '04' )
      ( month = '05' )
      ( month = '06' )
      ( month = '07' )
      ( month = '08' )
      ( month = '09' )
      ( month = '10' )
      ( month = '11' )
      ( month = '12' )
    ).

    lt_vkorg = VALUE #(
      ( vkorg = '1010' )
      ( vkorg = '1020' )
    ).

  ENDIF.

  lt_vkorg_txt = VALUE #(
    ( vkorg = '1010' text = '수도권' )
    ( vkorg = '1020' text = '비수도권' )
  ).

  LOOP AT gt_chart INTO gs_chart.

    CLEAR ls_month.
    ls_month-month = gs_chart-month.
    INSERT ls_month INTO TABLE lt_month.

    CLEAR ls_vkorg.
    ls_vkorg-vkorg = gs_chart-vkorg.
    INSERT ls_vkorg INTO TABLE lt_vkorg.


  ENDLOOP.

  "--------------------------------------------------
  " X축: 월은 한 번씩만 표시
  "--------------------------------------------------
  lo_cat = lo_doc->create_simple_element(
             name   = 'Categories'
             parent = lo_root ).

  LOOP AT lt_month INTO ls_month.
    lo_elem = lo_doc->create_simple_element(
                name   = 'C'
                parent = lo_cat ).

    lo_elem->if_ixml_node~set_value( CONV string( ls_month-month ) ).
  ENDLOOP.

  "--------------------------------------------------
  " Series: 영업조직별로 생성
  "--------------------------------------------------
  LOOP AT lt_vkorg INTO ls_vkorg.

    CLEAR: ls_vkorg_txt, lv_label.

    READ TABLE lt_vkorg_txt INTO ls_vkorg_txt
      WITH KEY vkorg = ls_vkorg-vkorg.

    IF sy-subrc = 0.
      lv_label = ls_vkorg_txt-text.
    ELSE.
      lv_label = ls_vkorg-vkorg.
    ENDIF.

    lo_series = lo_doc->create_simple_element(
                  name   = 'Series'
                  parent = lo_root ).

    lo_series->set_attribute(
      name  = 'label'
      value = lv_label ).

    LOOP AT lt_month INTO ls_month.

      CLEAR lv_qty.

      READ TABLE gt_chart INTO gs_chart
        WITH KEY month = ls_month-month
                 vkorg = ls_vkorg-vkorg.

      IF sy-subrc = 0.
        lv_qty = gs_chart-kwmeng.
      ENDIF.

      lo_elem = lo_doc->create_simple_element(
                  name   = 'S'
                  parent = lo_series ).

      lo_elem->if_ixml_node~set_value( |{ lv_qty }| ).

    ENDLOOP.

  ENDLOOP.

  lo_ostream = go_streamfac->create_ostream_xstring( gv_chart_xdata ).
  lo_doc->render( ostream = lo_ostream ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_chart_custom_xml_0120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_chart_custom_xml_0120 .

  DATA: lo_doc      TYPE REF TO if_ixml_document,
        lo_root     TYPE REF TO if_ixml_element,
        lo_global   TYPE REF TO if_ixml_element,
        lo_default  TYPE REF TO if_ixml_element,
        lo_elements TYPE REF TO if_ixml_element,
        lo_chartel  TYPE REF TO if_ixml_element,
        lo_title    TYPE REF TO if_ixml_element,
        lo_values   TYPE REF TO if_ixml_element,
        lo_series   TYPE REF TO if_ixml_element,
        lo_elem     TYPE REF TO if_ixml_element,
        lo_encoding TYPE REF TO if_ixml_encoding,
        lo_ostream  TYPE REF TO if_ixml_ostream,
        lv_title    TYPE string.

  CLEAR gv_chart_xcust.

  " XML 생성
  lo_doc = go_ixml->create_document( ).

  " 이 XML을 어떤 문자 인코딩으로 만들지
  lo_encoding = go_ixml->create_encoding(
                  byte_order    = if_ixml_encoding=>co_little_endian
                  character_set = 'utf-8' ).
  lo_doc->set_encoding( lo_encoding ).

  lo_root = lo_doc->create_simple_element(
              name   = 'SAPChartCustomizing'
              parent = lo_doc ).
  lo_root->set_attribute( name = 'version'
                          value = '2.0' ).



  "  차트 전체 공동 옵션 묶음
  lo_global = lo_doc->create_simple_element(
                name   = 'GlobalSettings'
                parent = lo_root ).

  " 출력 렌더링 형식
  lo_elem = lo_doc->create_simple_element(
              name   = 'FileType'
              parent = lo_global ).
  lo_elem->if_ixml_node~set_value( 'PNG' ).

  " n차원 차트
  lo_elem = lo_doc->create_simple_element(
              name   = 'Dimension'
              parent = lo_global ).
  lo_elem->if_ixml_node~set_value( 'TWO' ).

  " 세로 막대차트
  lo_elem = lo_doc->create_simple_element(
              name   = 'ChartType'
              parent = lo_global ).
  lo_elem->if_ixml_node~set_value( 'Columns' ).


  " 차트 렌더링 영역 크기(가로)
  lo_elem = lo_doc->create_simple_element(
              name   = 'Width'
              parent = lo_global ).
  lo_elem->if_ixml_node~set_value( '820' ).
  " 차트 렌더링 영역 크기(가로)
  lo_elem = lo_doc->create_simple_element(
              name   = 'Height'
              parent = lo_global ).
  lo_elem->if_ixml_node~set_value( '360' ).

  lo_default = lo_doc->create_simple_element(
                 name   = 'Defaults'
                 parent = lo_global ).
  " 글꼴 기본값
  lo_elem = lo_doc->create_simple_element(
              name   = 'FontFamily'
              parent = lo_default ).
  lo_elem->if_ixml_node~set_value( 'Arial' ).



  lo_elements = lo_doc->create_simple_element(
                  name   = 'Elements'
                  parent = lo_root ).

  " 제목, 축, 범례 같은 실제 차트 UI 요소들의 상위 노드
  lo_chartel = lo_doc->create_simple_element(
                 name   = 'ChartElements'
                 parent = lo_elements ).

  " 차트 제목
  lo_title = lo_doc->create_simple_element(
               name   = 'Title'
               parent = lo_chartel ).


  lo_elem = lo_doc->create_simple_element(
              name   = 'Caption'
              parent = lo_title ).
  lo_elem->if_ixml_node~set_value( lv_title ).



  " 차트 데이터(숫자)를 어떻게 보여줄지 정의하는 영역
  lo_values = lo_doc->create_simple_element(
                name   = 'Values'
                parent = lo_root ).
  " 각 데이터 시리즈(막대 묶음)의 표시 방식 설정
  " 제품이 여러 개면 시리즈도 여러 개 생긴다
  lo_series = lo_doc->create_simple_element(
                name   = 'Series'
                parent = lo_values ).

  " 데이터 라벨 표시 여부
  lo_elem = lo_doc->create_simple_element(
              name   = 'ShowLabel'
              parent = lo_series ).
  lo_elem->if_ixml_node~set_value( 'true' ).

  " 숫자 표시 형식
  "
  lo_elem = lo_doc->create_simple_element(
              name   = 'Format'
              parent = lo_series ).
  lo_elem->if_ixml_node~set_value( '0' ).

  " 라벨 색상
  lo_elem = lo_doc->create_simple_element(
              name   = 'LineColor'
              parent = lo_series ).
  lo_elem->if_ixml_node~set_value( 'RGB(0,0,0)' ).



  lo_ostream = go_streamfac->create_ostream_xstring( gv_chart_xcust ).
  lo_doc->render( ostream = lo_ostream ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_chart_0120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_chart_0120 .

  CALL METHOD go_chart->set_data
    EXPORTING
      xdata = gv_chart_xdata.

  CALL METHOD go_chart->set_customizing
    EXPORTING
      xdata = gv_chart_xcust.

  CALL METHOD go_chart->render.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form free_chart_0120
*&---------------------------------------------------------------------*
*& 생성된 120번 객체 삭제 로직
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_chart_0120 .

  " 120번 실행 후에만 실행하기 위해
  CHECK sy-dynnr EQ '0120'.

  IF go_chart IS BOUND.
    FREE go_chart.
  ENDIF.

  IF go_container2 IS BOUND.
    CALL METHOD go_container2->free.
  ENDIF.
  FREE go_container2.

  CLEAR: gv_chart_xdata, gv_chart_xcust.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm
*&---------------------------------------------------------------------*
*& 팝업
*&---------------------------------------------------------------------*
*&      --> SY_UCOMM
*&      --> GV_OK
*&---------------------------------------------------------------------*
FORM popup_to_confirm  USING    p_ucomm TYPE sy-ucomm
                                pv_ok   TYPE c.


  CLEAR pv_ok.

  DATA: lv_title    TYPE string,
        lv_question TYPE string,
        lv_answer   TYPE c.

  CASE p_ucomm.
    WHEN 'BT1'.
      " T04 : 검색조건 초기화
      lv_title     = TEXT-t04 .
      " D03 : 검색조건이 초기화됩니다. 실행하시겠습니까?
      lv_question  = TEXT-d03.

    WHEN 'BACK'.
      " T05 : 나가기
      lv_title     = TEXT-t05.
      " D04 : 변경된 데이터가 있습니다. 저장하지 않고 나가시겠습니까?
      lv_question  = TEXT-d04.


    WHEN 'SAVE'.
      " 저장 시점 KPI 모드에서 감지된 이상치 개수 확인하여 띄우기 위한 로직
      IF gv_kpi_on = abap_on.
        DATA: lv_count    TYPE n LENGTH 3.

        LOOP AT gt_display INTO gs_display.
          IF gs_display-cell_color IS NOT INITIAL.
            lv_count += 1.
          ENDIF.
        ENDLOOP.
        " 이상치 감지되면 감지된 개수와 함께 저장 여부 확인
        IF lv_count NE 0.
          " T06 : PKI 모드 이상치 감지
          lv_title = TEXT-t06.
          " D05 : 설정한 판매 계획에 대한 이상치가 &1건 감지되었습니다. 저장하시겠습니까?
          lv_question = TEXT-d05.
          REPLACE '&1' IN lv_question WITH lv_count.
          " 감지되지 않았으면
        ELSE.
          " T07 :저장 확인
          lv_title    = TEXT-t07.
          " D06 : 변경사항을 저장하시겠습니까?
          lv_question = TEXT-d06 .
        ENDIF.
        " KPI 모드가 꺼져 있으면
      ELSE.
        " T07 :저장 확인
        lv_title    = TEXT-t07.
        " D06 : 변경사항을 저장하시겠습니까?
        lv_question = TEXT-d06.
      ENDIF.

    WHEN 'CLEAR_PLAN'.
      " T08 : 검색조건 초기화 확인
      lv_title    = TEXT-t08.
      " D07 : 검색된 데이터의 계획수량이 초기화 됩니다. 실행 하시겠습니까?
      lv_question = TEXT-d07.
    WHEN 'CONT'.
      IF gv_op3 IS NOT INITIAL.
        " T09 : 자동채움 확인
        lv_title    = TEXT-t09.
        " D08 : 수량을 입력하지 않은 셀에 대해 전년도 판매량 기준으로 자동으로 채워집니다. 확인하시겠습니까?
        lv_question = TEXT-d08.
      ELSEIF gv_op4 IS NOT INITIAL.
        " T09 : 자동채움 확인
        lv_title    = TEXT-t09.
        " D10 : 수량을 입력하지 않은 셀에 대해 PIR 기준으로 자동으로 채워집니다. 확인하시겠습니까?
        lv_question = TEXT-d10.
      ELSEIF gv_op5 IS NOT INITIAL.
        " T09 : 자동채움 확인
        lv_title    = TEXT-t09.
        " D11 : 수량을 입력하지 않은 셀에 대해 작년도 판매량과 PIR 합산 기준으로 자동으로 채워집니다. 확인하시겠습니까?
        lv_question = TEXT-d11.
      ENDIF.
    WHEN 'REFRESH'.
      " T10 : 화면 초기화 확인
      lv_title    = TEXT-t10.
      " D09 : 화면이 초기화 됩니다. 실행 하시겠습니까?
      lv_question = TEXT-d09.

  ENDCASE.


  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = lv_title
      text_question         = lv_question
      text_button_1         = '예'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '아니오'
      icon_button_2         = 'ICON_CANCEL'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer.

  " 취소 버튼을 눌렀을 때
  IF lv_answer <> '1'.
    CLEAR pv_ok.
    EXIT.
  ENDIF.

  " 확인 버튼을 눌렀을 때
  pv_ok = abap_true.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_database
*&---------------------------------------------------------------------*
*& DB에 저장하는 로직
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_database .

  CHECK gv_ok IS NOT INITIAL.
  CALL METHOD go_alv_grid->check_changed_data.


  " 데이터 수정 시 실행되는 로직
  IF gv_after_edit = abap_true.

    PERFORM edit_plan.
    CLEAR gv_after_edit.

  ENDIF.

  " 데이터 생성 시 실행되는 로직(단건) -> 단건만 실행했을 때
  IF gv_after_0110 = abap_true AND gv_after_0140 = space.

    PERFORM add_plan.
    CLEAR gv_after_0110.

    " 데이터 생성 시 실행되는 로직(다건) -> 다건만 실행했을 떄
  ELSEIF gv_after_0140 = abap_true AND gv_after_0110 = space.

    PERFORM add_multi_plan.

    CLEAR gv_after_0140.

    " 데이터 생성 시 실행되는 로직 다건 & 단건 둘다 실행 했을 떄
  ELSEIF gv_after_0140 = abap_true AND gv_after_0110 = abap_true.

    PERFORM add_multi_plan.

    CLEAR gv_after_0110.
    CLEAR gv_after_0140.

  ENDIF.

  " 아무것도 바뀐게 없으면
  READ TABLE gt_display INTO gs_display WITH KEY line_color = 'C510'.

  " DB에 반영되지 않은 데이터가 1건이라도 있으면 검증 모드를 실행하지 않는다
  IF sy-subrc <> 0.

    " 905 : 변경된 데이터가 없습니다.
    MESSAGE s905 DISPLAY LIKE 'E'.
    RETURN.

  ENDIF.

  " 데이터 저장 후 다시 바꿀 것을 대비해 다시 정의
  gv_start = abap_true.



ENDFORM.



*&---------------------------------------------------------------------*
*& Form insert_multi_plan_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_multi_plan_item .

  INSERT ztd3sd0005
    FROM TABLE @gt_insert_item.

  IF sy-subrc = 0.
    COMMIT WORK.
    " 023 : 저장되었습니다.
    MESSAGE s023.
  ELSE.
    ROLLBACK WORK.
    " 025 : 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'E'.
  ENDIF.

  REFRESH gt_insert_item.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_multi_plan_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_multi_plan_header .

  INSERT ztd3sd0004
    FROM TABLE @gt_insert_header.

  IF sy-subrc = 0.
    COMMIT WORK.
    " 023 : 저장되었습니다.
    MESSAGE s023.
  ELSE.
    ROLLBACK WORK.
    " 025 : 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'E'.
  ENDIF.

  REFRESH gt_insert_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_for_changed_data2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_for_changed_data2 .

  " 수정 및 생성을 안한 상태일 때
  " 저장을 누르면 클리어 되어서 저장버튼 누른 직후해도 문제 X
  IF gv_after_0110 IS INITIAL AND gv_after_0140 IS INITIAL AND gv_after_edit IS NOT INITIAL.

  ENDIF.


  " SORT gt_display_old BY vkorg plan_month matnr posnr.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form clean_edit_no_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clean_edit_no_change .

  CLEAR gs_display.
  CLEAR gs_display_old.

  CALL METHOD go_alv_grid->check_changed_data.

  "
  LOOP AT gt_display INTO gs_display.

    READ TABLE gt_display_old INTO gs_display_old
      WITH KEY plnnr = gs_display-plnnr
               posnr = gs_display-posnr.

    IF gs_display-menge EQ gs_display_old-menge.
      REFRESH gs_display-celltab.

      MODIFY gt_display FROM gs_display.

    ELSE.
    ENDIF.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_input_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_input_data .

  " 기간에 대한 입력값 설정
  PERFORM set_period.

  " 자재에 대한 입력값 설정
  PERFORM set_matnr.

  " SOP에 대한 입력값 설정
  PERFORM set_plnnr.

  " 영업조직에 대한 입력값 설정
  PERFORM set_vkorg.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_plan_year_so_no_mrp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_plan_year_so_no_mrp .

  CHECK gv_ch1 IS NOT INITIAL.

  " 년 또는 달을 입력 안했을 때를 위한 패턴 매칭을 위한 변수
  DATA: lv_from_period   TYPE ztd3sd0004-plan_month,
        lv_to_period     TYPE ztd3sd0004-plan_month,
        lv_pattern_matnr TYPE string,
        lv_pattern_matnm TYPE string,
        lv_matnm_upper   TYPE string,
        lv_month_from    TYPE c LENGTH 2,
        lv_month_to      TYPE c LENGTH 2,
        lv_year_from     TYPE c LENGTH 4.


  CLEAR: gt_display.

******************************
*  일자에 대한 LIKE 패턴
******************************

  lv_month_from = gv_month_from.
  lv_month_to   = gv_month_to.




  IF lv_month_from IS NOT INITIAL AND strlen( lv_month_from ) = 1.
    lv_month_from = |0{ lv_month_from }|.
  ENDIF.

  IF lv_month_to IS NOT INITIAL AND strlen( lv_month_to ) = 1.
    lv_month_to = |0{ lv_month_to }|.
  ENDIF.



  "--------------------------------------------------
  " 2. 조회 기간 생성 (YYYYMM)
  "--------------------------------------------------

  " 사용자가 기간 다 입력했을 때
  IF lv_month_from IS NOT INITIAL AND lv_month_to IS NOT INITIAL.
    lv_from_period = |{ lv_year_from }{ lv_month_from }|.
    lv_to_period   = |{ lv_year_from }{ lv_month_to }|.


    " 사용자가 시작월만 입력했을 때 : 조회할 시작월부터 끝까지
  ELSEIF lv_month_from IS NOT INITIAL AND lv_month_to IS INITIAL.
    lv_from_period = |{ lv_year_from }{ lv_month_from }|.
    lv_to_period   = |{ lv_year_from }12|.


    " 사용자가 끝월만 입력했을 때 : 000001부터 입력 계획달까지
  ELSEIF lv_month_from IS INITIAL AND lv_month_to IS NOT INITIAL.
    lv_from_period = |{ lv_year_from }01|.
    lv_to_period   = |{ lv_year_from }{ lv_month_to }|.
    " 사용자가 끝월만 입력했을 때 : 000001부터 입력 계획달까지

    " 사용자가 둘다 입력 안했을 때
  ELSEIF lv_month_from IS INITIAL AND lv_month_to IS INITIAL.
    lv_from_period = |{ lv_year_from }01|.
    lv_to_period   = |{ lv_year_from }12|.

  ENDIF.




******************************
*  자재에 대한 LIKE 패턴
******************************


  lv_pattern_matnr = |%{ gv_matnr }%|.
  lv_pattern_matnm = |%{ lv_matnm_upper }%|.

  SELECT
    a~plnnr,
    a~vkorg,
    a~plan_month,
    b~posnr,
    b~matnr,
    c~maktx,
    b~menge,
    b~meins,
    a~mrp_stat,
    b~erdat,
    b~erzzt,
    b~ernam,
    b~aedat,
    b~aezet,
    b~werks,
    b~aenam
  FROM ztd3sd0004 AS a
  INNER JOIN ztd3sd0005 AS b
    ON a~plnnr = b~plnnr
  LEFT OUTER JOIN ztd3mm0001 AS c
    ON b~matnr = c~matnr
*  WHERE ( a~plnnr = @gv_plnnr OR @gv_plnnr IS INITIAL )
*    AND a~lvorm EQ @space
*    AND b~lvorm EQ @space
*    AND c~lvorm EQ @space
*    AND a~mrp_stat IS INITIAL
*    AND ( a~vkorg = @gv_vkorg OR @gv_vkorg IS INITIAL )
*    AND a~plan_month BETWEEN @lv_from_period AND @lv_to_period
*    AND b~matnr LIKE @lv_pattern_matnr
*    AND upper( c~maktx ) LIKE @lv_pattern_matnm
  INTO CORRESPONDING FIELDS OF TABLE @gt_display.

  SORT gt_display BY vkorg plan_month matnr posnr.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_auto_plan_qty_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_auto_plan_qty_last_0140 .

  CHECK gv_ok IS NOT INITIAL.

  DATA lv_month TYPE c LENGTH 2.

  DATA lv_per TYPE p LENGTH 6 DECIMALS 2.

  lv_per = gv_per / 100.


  LOOP AT gt_display4 INTO gs_display4.

    lv_month = |{ gs_display4-plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

    READ TABLE gt_layear_sum INTO gs_layear_sum
         WITH KEY month = lv_month
                  matnr = gs_display4-plan_matnr
                  vkorg = gs_display4-plan_vkorg
         BINARY SEARCH.

    " 이미 판매량을 지정한 자재에 대해서는 자동채움 하지 않는다
    IF sy-subrc = 0 AND gs_display4-plan_menge = 0.
      gs_display4-plan_menge = round(
        val  = gs_layear_sum-kwmeng * lv_per
        dec  = 0
        mode = cl_abap_math=>round_half_up ).
    ENDIF.

    MODIFY gt_display4 FROM gs_display4.

  ENDLOOP.

  " DB에 반영된 건을 저장하는 로직을 실행시기키 위한 bool 세팅
  gv_after_edit  = abap_true.

  " 319 : 자동 채움이 완료되었습니다.
  MESSAGE s319.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reset_row_col
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reset_row_col .

  LOOP AT gt_display INTO gs_display.

    IF gs_display-line_color EQ 'C510'.
      CLEAR gs_display-line_color.

      MODIFY gt_display FROM gs_display.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_db_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_db_data .

  REFRESH gt_plan_all.

  SELECT
    a~plnnr,
    a~vkorg,
    a~plan_month,
    b~posnr,
    b~matnr,
    c~maktx,
    b~menge,
    b~meins,
    a~mrp_stat,
    b~erdat,
    b~erzzt,
    b~ernam,
    b~aedat,
    b~aezet,
    b~werks,
    b~aenam
  FROM ztd3sd0004 AS a
  INNER JOIN ztd3sd0005 AS b
    ON a~plnnr = b~plnnr
  LEFT OUTER JOIN ztd3mm0001 AS c
    ON b~matnr = c~matnr
  WHERE c~lvorm = @space                                        " 삭제플래그
    AND a~lvorm = @space
    AND b~lvorm = @space
  INTO CORRESPONDING FIELDS OF TABLE @gt_plan_all.

  gv_count = lines( gt_plan_all ).

  " 검색된 결과가 없으면
  IF gv_no_count IS NOT INITIAL.
    gv_count = 0.
    CLEAR gv_no_count.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM append_data .
  IF gv_after_0110 IS NOT INITIAL.
    APPEND LINES OF gt_plan_new TO gt_display.
  ENDIF.
  IF gv_after_0140 IS NOT INITIAL.
    APPEND LINES OF gt_plan_new TO gt_display.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv_0110 .

  CLEAR gv_plnnr.
  CLEAR gv_plan_matnm.
  CLEAR gv_plan_mtart.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_plan_new
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_plan_new .

  REFRESH gt_plan_new.
  CLEAR   gs_plan_new.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_last_year_month_so2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_last_year_month_so2 .

  DATA: lv_year      TYPE n LENGTH 4,
        lv_year_from TYPE sydatum,
        lv_year_to   TYPE sydatum.

  REFRESH gt_layear_sum2.

  lv_year = sy-datum(4) - 1.

  lv_year_from = |{ lv_year }0101|.
  lv_year_to   = |{ lv_year }1231|.

  SELECT substring( a~audat, 5, 2 ) AS month,
         b~matnr,
         SUM( b~kwmeng )            AS kwmeng
    FROM ztd3sd0006 AS a INNER JOIN ztd3sd0007 AS b
      ON a~vbeln EQ b~vbeln
   WHERE a~audat BETWEEN @lv_year_from
     AND @lv_year_to
   GROUP BY substring( a~audat, 5, 2 ), b~matnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_layear_sum2.

  SORT gt_layear_sum2 BY month matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_gv_lines
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_COUNT
*&---------------------------------------------------------------------*
FORM del_gv_lines  CHANGING    pv_count.

  DATA : lv_mrp_count TYPE i.

  SELECT COUNT( * )
    FROM ztd3sd0004 AS a RIGHT OUTER JOIN ztd3sd0005 AS b
         ON a~plnnr EQ b~plnnr
   WHERE a~mrp_stat EQ 'X'
     AND a~lvorm EQ @space
     AND b~lvorm EQ @space
    INTO @lv_mrp_count.

  pv_count -= lv_mrp_count.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM handle_data_changed USING po_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA: ls_mod_cell TYPE lvc_s_modi,
        lv_re_menge TYPE ztd3sd0005-menge.

  LOOP AT po_changed->mt_mod_cells INTO ls_mod_cell.

    CASE ls_mod_cell-fieldname.

      WHEN 'MENGE'.

        READ TABLE gt_display INTO gs_display INDEX ls_mod_cell-row_id.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        lv_re_menge = gs_display-menge.

        TRY.
            gs_display-menge = ls_mod_cell-value.

          CATCH cx_sy_conversion_no_number.
            CALL METHOD po_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZPD3_MSG'
                i_msgty     = 'E'
                i_msgno     = '090'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.

            CALL METHOD po_changed->modify_cell
              EXPORTING
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = ls_mod_cell-fieldname
                i_value     = lv_re_menge.

            CONTINUE.
        ENDTRY.

        " 음수 입력 불가
        IF gs_display-menge < 0.

          CALL METHOD po_changed->add_protocol_entry
            EXPORTING
              i_msgid     = 'ZPD3_MSG'
              i_msgty     = 'W'      " 경고
              i_msgno     = '334'    " 음수 입력은 불가능합니다.
              i_fieldname = ls_mod_cell-fieldname
              i_row_id    = ls_mod_cell-row_id.

          CALL METHOD po_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
              i_value     = lv_re_menge.

          CONTINUE.

        ENDIF.

        gs_display-line_color = 'C510'.

        MODIFY gt_display FROM gs_display INDEX ls_mod_cell-row_id
          TRANSPORTING menge line_color.

      WHEN 'PLAN_MENGE'.

        READ TABLE gt_display4 INTO gs_display4 INDEX ls_mod_cell-row_id.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        DATA(lv_old_plan_menge) = gs_display4-plan_menge.

        TRY.
            gs_display4-plan_menge = ls_mod_cell-value.

          CATCH cx_sy_conversion_no_number.
            CALL METHOD po_changed->add_protocol_entry
              EXPORTING
                i_msgid     = 'ZPD3_MSG'
                i_msgty     = 'E'
                i_msgno     = '090'
                i_fieldname = ls_mod_cell-fieldname
                i_row_id    = ls_mod_cell-row_id.

            CALL METHOD po_changed->modify_cell
              EXPORTING
                i_row_id    = ls_mod_cell-row_id
                i_fieldname = ls_mod_cell-fieldname
                i_value     = lv_old_plan_menge.

            CONTINUE.
        ENDTRY.

        " 음수 입력 불가
        IF gs_display4-plan_menge < 0.

          CALL METHOD po_changed->add_protocol_entry
            EXPORTING
              i_msgid     = 'ZPD3_MSG'
              i_msgty     = 'W'      " 경고
              i_msgno     = '334'    " 음수 입력은 불가능합니다.
              i_fieldname = ls_mod_cell-fieldname
              i_row_id    = ls_mod_cell-row_id.

          CALL METHOD po_changed->modify_cell
            EXPORTING
              i_row_id    = ls_mod_cell-row_id
              i_fieldname = ls_mod_cell-fieldname
              i_value     = lv_re_menge.

          CONTINUE.

        ENDIF.

        MODIFY gt_display4 FROM gs_display4 INDEX ls_mod_cell-row_id
          TRANSPORTING plan_menge.

    ENDCASE.

  ENDLOOP.

  gv_after_edit = abap_true.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_deleted_plan_rows
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_deleted_plan_rows .

  " ALV 화면에서 수정된 값 내부테이블에 반영
  IF go_alv_grid4 IS BOUND.
    go_alv_grid4->check_changed_data( ).
  ENDIF.

  " 이전 화면 데이터 기준으로 비교
  LOOP AT gt_display4_old INTO gs_display4_old.

    " 현재 화면에 동일 데이터가 있는지 확인
    READ TABLE gt_display4 TRANSPORTING NO FIELDS
      WITH KEY plan_vkorg = gs_display4_old-plan_vkorg
               plan_matnr = gs_display4_old-plan_matnr
               plan_year  = gs_display4_old-plan_year
               plan_month = gs_display4_old-plan_month.
    " 없으면 사용자가 삭제한 데이터
    IF sy-subrc <> 0.
      " 이미 삭제 이력에 있는지 확인 ( 중복 방지 )
      READ TABLE gt_plan_deleted TRANSPORTING NO FIELDS
        WITH KEY plan_vkorg = gs_display4_old-plan_vkorg
                 plan_matnr = gs_display4_old-plan_matnr
                 plan_year  = gs_display4_old-plan_year
                 plan_month = gs_display4_old-plan_month.

      " 없으면 삭제 이력 테이블에 저장
      IF sy-subrc <> 0.
        APPEND gs_display4_old TO gt_plan_deleted.
      ENDIF.

    ENDIF.

  ENDLOOP.
  " 현재 상태를 다시 이전 데이터로 저장 (다음 비교용)
  gt_display4_old = gt_display4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exception_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exception_data .

  " PERFORM set_data_exception_0100.

  PERFORM set_no_count_0100.

ENDFORM.
**&---------------------------------------------------------------------*
**& Form set_data_exception_0100
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM set_data_exception_0100 .
*  CHECK gv_valid_bool IS NOT INITIAL.
*
*  " 328 : 조회 시작 달이 조회 종료 달보다 큽니다.
*  MESSAGE s328 DISPLAY LIKE 'E'.
*
*  CLEAR gv_valid_bool.
*
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_no_count_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_no_count_0100 .
  CHECK gv_no_count IS NOT INITIAL.

  " 301 : 검색된 결과가 없습니다.
  MESSAGE s301 DISPLAY LIKE 'E'.

  CLEAR gv_no_count.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_already_refresh
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_already_refresh .

  IF  gv_ch1        IS INITIAL
  AND gv_ch2        IS INITIAL
  AND gv_year_to    EQ sy-datum(4)
  AND gv_year_from  EQ sy-datum(4)
  AND gv_month_to   EQ '12'
  AND gv_month_from EQ |{ sy-datum+4(2) ALIGN = RIGHT WIDTH = 2 PAD = '0' }|
  AND gv_matnr_to   IS INITIAL
  AND gv_matnr_from IS INITIAL
  AND gv_vkorg_to   IS INITIAL
  AND gv_vkorg_from IS INITIAL
  AND gt_display    IS INITIAL.

    gv_already = abap_true.
    " 088 : 이미 화면이 초기화면 상태입니다.
    MESSAGE s088.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_sh_op_already_refresh
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_sh_op_already_refresh .

  IF  gv_ch1        IS INITIAL
  AND gv_ch2        IS INITIAL
  AND gv_year_to    EQ sy-datum(4)
  AND gv_year_from  EQ sy-datum(4)
  AND gv_month_to   EQ '12'
  AND gv_month_from EQ |{ sy-datum+4(2) ALIGN = RIGHT WIDTH = 2 PAD = '0' }|
  AND gv_matnr_to   IS INITIAL
  AND gv_matnr_from IS INITIAL
  AND gv_vkorg_to   IS INITIAL
  AND gv_vkorg_from IS INITIAL.

    gv_already = abap_true.
    " 089 : 이미 검색조건이 초기 상태입니다.
    MESSAGE s089.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_refresh_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_refresh_0110 .

  CLEAR gv_plan_mtart.
  CLEAR gv_plan_matnm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_plan_vkorg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_plan_werks .

  CLEAR gv_plan_werks.

  SELECT SINGLE werks
    FROM ztd3mm0002
   WHERE matnr EQ @gv_plan_matnr
    INTO @gv_plan_werks.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_vktxt_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_vktxt_0140 .

  IF gs_display-vkorg EQ '1010'.
    " 수도권
    gs_display-vktxt = TEXT-s01.
  ELSEIF gs_display-vkorg EQ '1020'.
    "비수도권
    gs_display-vktxt = TEXT-s02.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_pir_data_0150
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_pir_data.

  REFRESH gt_pir.
  CLEAR gs_pir.

  CLEAR gs_display.

  SELECT matnr,
         bdter,
         werks,
         plnmg,
         meins
FROM zcds_d3_sd_0015
INTO CORRESPONDING FIELDS OF TABLE @gt_pir.

  SORT gt_pir BY bdter matnr.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_auto_plan_qty_pir
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_auto_plan_qty_pir_0100.

  CHECK gv_ok IS NOT INITIAL.

  DATA lv_plan_month TYPE i.

  LOOP AT gt_display INTO gs_display.

    lv_plan_month = gs_display-plan_month.

    READ TABLE gt_pir INTO gs_pir
         WITH KEY bdter = gs_display-plan_month
                  matnr = gs_display-matnr
                  werks = gs_display-werks
         BINARY SEARCH.

    " 이미 판매량을 지정한 자재에 대해서는 자동채움 하지 않는다
    IF sy-subrc = 0 AND gs_display-menge = 0 AND lv_plan_month GT sy-datum(6).
      gs_display-menge = gs_pir-plnmg.

      " 변경된 데이터임을 알리기 위한 행 색깔 지정
      gs_display-line_color = 'C510'.
    ENDIF.




    MODIFY gt_display FROM gs_display.

  ENDLOOP.

  " DB에 반영된 건을 저장하는 로직을 실행시기키 위한 bool 세팅
  gv_after_edit  = abap_true.

  " 319 : 자동 채움이 완료되었습니다.
  MESSAGE s319.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_auto_plan_qty_pir_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_auto_plan_qty_pir_0140 .

  CHECK gv_ok IS NOT INITIAL.

  DATA lv_plan_month TYPE c LENGTH 6.

  LOOP AT gt_display4 INTO gs_display4.

    lv_plan_month = |{ gs_display4-plan_year }{ gs_display4-plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

    READ TABLE gt_pir INTO gs_pir
         WITH KEY bdter = lv_plan_month
                  matnr = gs_display4-plan_matnr
                  werks = gs_display4-plan_werks
         BINARY SEARCH.

    " 이미 판매량을 지정한 자재에 대해서는 자동채움 하지 않는다
    IF gs_display4-plan_menge = 0.
      gs_display4-plan_menge = gs_pir-plnmg.
    ENDIF.

    MODIFY gt_display4 FROM gs_display4.

  ENDLOOP.

  " DB에 반영된 건을 저장하는 로직을 실행시기키 위한 bool 세팅
  gv_after_edit  = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_auto_plan_qty_la_pir_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_auto_plan_qty_la_pir_0100 .

  CHECK gv_ok IS NOT INITIAL.

  DATA lv_month TYPE c LENGTH 2.
  DATA lv_count TYPE i.


  LOOP AT gt_display INTO gs_display.

    lv_month = gs_display-plan_month+4(2).

    " 작년도 판매량 데이터를 불러온다
*    READ TABLE gt_layear_sum INTO gs_layear_sum
*         WITH KEY month = lv_month
*                  matnr = gs_display-matnr
*                  vkorg = gs_display-vkorg
*         BINARY SEARCH.

    " 올해 PIR 데이터를 불러온다
    lv_plan_month = gs_display-plan_month.

    READ TABLE gt_pir INTO gs_pir
         WITH KEY bdter = gs_display-plan_month
                  matnr = gs_display-matnr
                  werks = gs_display-werks
         BINARY SEARCH.



    " 이미 판매량을 지정한 이번달 포함한 날짜의 자재에 대해서는 자동채움 하지 않는다
    " mrp 반영된 데이터에 대해서 자동채움 하지 않는다
    IF gs_display-menge = 0 AND gs_display-plan_month GT sy-datum(6) AND gs_display-mrp_stat IS INITIAL.
      gs_display-menge += gs_layear_sum-kwmeng.
      gs_display-menge += gs_pir-plnmg.

      " 변경된 데이터임을 알리기 위한 행 색깔 지정
      gs_display-line_color = 'C510'.
      lv_count += 1.
    ENDIF.


    MODIFY gt_display FROM gs_display.

  ENDLOOP.

  " DB에 반영된 건을 저장하는 로직을 실행시기키 위한 bool 세팅
  gv_after_edit  = abap_true.

  IF lv_count GT 0.
    " 319 : 자동 채움이 완료되었습니다.
    MESSAGE s319.
  ELSE.
    " 변경된 데이터가 없습니다.
    MESSAGE s905 DISPLAY LIKE 'W'.
  ENDIF.





ENDFORM.

*&---------------------------------------------------------------------*
*& Form fill_auto_plan_qty_la_pir_0140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_auto_plan_qty_la_pir_0140 .

  CHECK gv_ok IS NOT INITIAL.

  DATA lv_plan_month TYPE c LENGTH 6.
  DATA lv_month TYPE c LENGTH 6.

  LOOP AT gt_display4 INTO gs_display4.

    lv_plan_month = |{ gs_display4-plan_year }{ gs_display4-plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
    lv_month      = |{ gs_display4-plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.


    " 전년도 판매량
    READ TABLE gt_layear_sum INTO gs_layear_sum
     WITH KEY month = lv_month
              matnr = gs_display4-plan_matnr
              vkorg = gs_display4-plan_vkorg
     BINARY SEARCH.

    " PIR
    READ TABLE gt_pir INTO gs_pir
         WITH KEY bdter = lv_plan_month
                  matnr = gs_display4-plan_matnr
                  werks = gs_display4-plan_werks
         BINARY SEARCH.

    " 이미 판매량을 지정한 자재에 대해서는 자동채움 하지 않는다
    IF gs_display4-plan_menge = 0.
      gs_display4-plan_menge += gs_layear_sum-kwmeng.
      gs_display4-plan_menge += gs_pir-plnmg.
    ENDIF.

    MODIFY gt_display4 FROM gs_display4.

  ENDLOOP.

  " DB에 반영된 건을 저장하는 로직을 실행시기키 위한 bool 세팅
  gv_after_edit  = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_kpi_desc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_kpi_desc .


  gv_kpi_desc = TEXT-d12.

  gv_red    = TEXT-d13.
  gv_yellow = TEXT-d14.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gjahr_listbox_year
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gjahr_listbox_year .

  DATA: lv_min_year TYPE gjahr,
        lv_max_year TYPE gjahr,
        lv_year     TYPE gjahr.

  REFRESH gt_gjahr_year.

  SELECT SINGLE MIN( plan_month )
    FROM ztd3sd0004
    WHERE plan_month IS NOT INITIAL
    INTO @DATA(lv_plan_month).

  IF sy-subrc = 0.
    lv_min_year = lv_plan_month+0(4).
  ELSE.
    lv_min_year = sy-datum+0(4).
  ENDIF.

  lv_max_year = sy-datum+0(4) + 1.

  lv_year = lv_min_year.

  WHILE lv_year <= lv_max_year.

    CLEAR gs_gjahr_year.

    gs_gjahr_year-key  = |{ lv_year }|.
    gs_gjahr_year-text = |{ lv_year }|.

    APPEND gs_gjahr_year TO gt_gjahr_year.

    lv_year += 1.

  ENDWHILE.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_YEAR_FROM'
      values = gt_gjahr_year.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_YEAR_TO'
      values = gt_gjahr_year.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_period
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_period .

  " 사용자가 계획 기간 입력 안했을 때 혹은 다 지웠을 때
  IF gv_year_from IS INITIAL AND gv_year_to IS INITIAL AND gv_month_from IS INITIAL AND gv_month_to IS INITIAL.

    gv_year_from  = sy-datum(4).
    gv_year_to    = sy-datum(4) + 1.
    gv_month_from = '01'.
    gv_month_to   = 12.


  ENDIF.


  " 한자리 수의 월을 입력했을 때 세팅
  IF gv_month_from IS NOT INITIAL AND strlen( gv_month_from ) = 1.
    gv_month_from = |0{ gv_month_from }| .
  ENDIF.

  IF gv_month_to IS NOT INITIAL AND strlen( gv_month_to ) = 1.
    gv_month_to = |0{ gv_month_to }|.
  ENDIF.


  gv_ym_from = |{ gv_year_from }{ gv_month_from }|.
  gv_ym_to   = |{ gv_year_to }{ gv_month_to }|.

  " 이번달 이후의 데이터 체크 안했을 때
  IF gv_ch2 IS INITIAL.
    " 사용자가 시작 일자만 입력했을 때
    " 해당 달만 조회
    IF gv_year_from IS NOT INITIAL AND gv_month_from IS NOT INITIAL
   AND gv_year_to IS INITIAL AND gv_month_to IS INITIAL.

      gv_ym_to = gv_ym_from.

      " 사용자가 끝 일자만 입력했을 때
      " 해당 달까지 조회
    ELSEIF ( gv_year_from IS INITIAL OR gv_year_from EQ '0000')
       AND ( gv_month_from IS INITIAL OR gv_year_from EQ '00')
   AND gv_year_to IS NOT INITIAL AND gv_month_to IS NOT INITIAL.

      gv_ym_from = |{ '0000' }{ '01' }|.
    ENDIF.


    " 사용자가 이번달 이후 일자만 선택했을 때
  ELSEIF gv_ch2 IS NOT INITIAL.

    DATA : lv_month TYPE c LENGTH 2.

    lv_month = |{ sy-datum+4(2) WIDTH = 2 ALIGN = LEFT PAD = '0' }|.

    " 만약 현재 달이 12월이면 조회 시작일을 내년 1월로 설정하기 위한 로직
    IF lv_month EQ 12.

      lv_month = '01'.

      gv_ym_from = |{ sy-datum(4) + 1 }{ lv_month }|.

    ELSE.
      gv_ym_from = |{ sy-datum(4) }{ lv_month + 1 WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
    ENDIF.

    gv_year_from = gv_ym_from(4).
    gv_month_from = gv_ym_from+4(2).

    IF gv_month_to IS INITIAL AND gv_year_to IS INITIAL.

      " 다음달 이후 전체 데이터가 조회됩니다.
      MESSAGE TEXT-m12 TYPE 'S'.
      gv_ym_to = |{ sy-datum(4) + 1 }{ '12' }|.


    ENDIF.


  ENDIF.

  " 사용자가 시작 년도만 입력했을 때
  IF  gv_year_from IS NOT INITIAL AND gv_month_from IS INITIAL
  AND gv_year_to   IS INITIAL     AND gv_month_to   IS INITIAL.
    " 해당 년도 전체가 조회됩니다.
    MESSAGE TEXT-m11 TYPE 'S'.
    gv_ym_from = |{ gv_year_from }{ '01' }|.
    gv_ym_to   = |{ gv_year_from }{ '12' }|.

  ENDIF.


  " 사용자가 종료 년도만 입력했을 때
  IF  gv_year_from IS INITIAL     AND gv_month_from IS INITIAL
  AND gv_year_to   IS NOT INITIAL AND gv_month_to   IS INITIAL.
    " 해당 년도 전체가 조회됩니다.
    MESSAGE TEXT-m11 TYPE 'S'.
    gv_ym_from = |{ gv_year_to }{ '01' }|.
    gv_ym_to   = |{ gv_year_to }{ '12' }|.

  ENDIF.






ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_matnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_matnr .

  gv_mn_from = gv_matnr_from.
  gv_mn_to   = gv_matnr_to.

  " 둘다 입력 안했을 때
  " 전체 조회
  IF gv_mn_from IS INITIAL AND gv_mn_to IS INITIAL.

    SELECT SINGLE MAX( matnr )
      FROM ztd3mm0001
      INTO @gv_mn_to
     WHERE matnr LIKE '00002%'.


    SELECT SINGLE MIN( matnr )
      FROM ztd3mm0001
      INTO @gv_mn_from
     WHERE matnr LIKE '00002%'.



    " 종료만 입력했을 때
    " 종료 자재까지의 자재 검색
  ELSEIF gv_mn_from IS INITIAL AND gv_mn_to IS NOT INITIAL.

    SELECT SINGLE MIN( matnr )
     FROM ztd3mm0001
     INTO @gv_mn_from
    WHERE matnr LIKE '00002%'.


    " 시작만 입력했을 때
    " 해당 자재만 검색
  ELSEIF gv_mn_from IS NOT INITIAL AND gv_mn_to IS INITIAL.
    gv_mn_to = gv_mn_from.

  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_plnnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_plnnr .

  gv_pn_from = gv_plnnr_from.
  gv_pn_to   = gv_plnnr_to.

  " 둘다 입력 안했을 때
  IF gv_pn_from IS INITIAL AND gv_pn_to IS INITIAL.

    SELECT SINGLE MAX( plnnr )
      FROM ztd3sd0004
      INTO @gv_pn_to.


    SELECT SINGLE MIN( plnnr )
      FROM ztd3sd0004
      INTO @gv_pn_from.



    " 종료만 입력했을 때
    " 종료까지의 SOP 번호 검색
  ELSEIF gv_pn_from IS INITIAL AND gv_pn_to IS NOT INITIAL.

    SELECT SINGLE MIN( plnnr )
      FROM ztd3sd0004
      INTO @gv_pn_from.

    " 시작만 입력했을 때
    " 해당 SOP만 검색
  ELSEIF gv_pn_from IS NOT INITIAL AND gv_pn_to IS INITIAL.
    gv_pn_to = gv_pn_from.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_vkorg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_vkorg .

  gv_vk_from = gv_vkorg_from.
  gv_vk_to   = gv_vkorg_to.

  " 둘다 입력 안했을 때
  IF gv_vk_from IS INITIAL AND gv_vk_to IS INITIAL.

    SELECT SINGLE MAX( vkorg )
      FROM ztd3sd0004
      INTO @gv_vk_to.


    SELECT SINGLE MIN( vkorg )
      FROM ztd3sd0004
      INTO @gv_vk_from.


    " 종료만 입력했을 댸
    " 해당 영업조직까지의 범위 검색
  ELSEIF gv_vk_from IS INITIAL AND gv_vk_to IS NOT INITIAL.

    SELECT SINGLE MIN( vkorg )
      FROM ztd3sd0004
      INTO @gv_vk_from.

    " 시작만 입력했을 때
    " 해당 영업조직만 검색
  ELSEIF gv_vk_from IS NOT INITIAL AND gv_vk_to IS INITIAL.
    gv_vk_to = gv_vk_from.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form reselect_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reselect_data .

  " 입력값 보정
  PERFORM set_input_data.
  " 데이터 가져오는 로직
  PERFORM select_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_data .

  LOOP AT gt_display INTO gs_display.

    " 아이템번호 필드 형식 맞추기 위한 로직
    PERFORM set_posnr.

    MODIFY gt_display FROM gs_display TRANSPORTING posnr.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_posnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_posnr .

  gs_display-posnr = |{ CONV i( gs_display-posnr ) WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form kpi_setting
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM kpi_setting .
  CALL METHOD go_alv_grid->check_changed_data.


  " 검증 모드가 꺼져있으면
  IF gv_kpi_on = abap_false.

    " 160번 스크린을 통한 팝업 띄우기
    CALL SCREEN 0160 STARTING AT 60 10
                     ENDING   AT 110 14.

    " 160번 화면에서 CANC를 안눌렀으면
    IF gv_kpi_no IS INITIAL.

      gv_kpi_on = abap_true.

      " 행 색깔 설정
      PERFORM create_kpi.

    ENDIF.


    " 검증 모드가 켜져있다면
    " 검증 모드 끄기
  ELSE.

    "CLEAR gv_kpi_no.

    gv_kpi_on = abap_false.

    " 행 색깔 초기화
    PERFORM clear_kpi.

    " 설정한 kpi 모드 클리어
    CLEAR gv_kpi_on.

  ENDIF.

  CLEAR gv_kpi_no.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_toolbar USING    po_object TYPE REF TO cl_alv_event_toolbar_set.

  IF gv_edit = abap_true.

    DELETE po_object->mt_toolbar
      WHERE function = cl_gui_alv_grid=>mc_fc_loc_insert_row.

    DELETE po_object->mt_toolbar
      WHERE function = cl_gui_alv_grid=>mc_fc_loc_delete_row.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_tree_data
*&---------------------------------------------------------------------*
FORM init_tree_data .

  DATA : lv_count       TYPE i,
         lv_plan_year   TYPE c LENGTH 4,
         lv_plan_month  TYPE c LENGTH 2,
         lt_vkorg       TYPE TABLE OF ztd3sd0004-vkorg,
         lv_plan_vkorg  TYPE ztd3sd0004-vkorg,
         lv_plan_plant  TYPE ztd3sd0005-werks,
         lv_matnm       TYPE ztd3mm0001-maktx,
         ls_outtab_line TYPE ztd3mm0001.

  SELECT SINGLE maktx
    FROM ztd3mm0001
   WHERE matnr EQ @gs_tree_map-matnr
     AND lvorm EQ @space
    INTO @lv_matnm.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF gs_tree_map-matnr BETWEEN '0000200001' AND '0000200007'.
    lv_plan_plant = 'P00002'.
  ELSEIF gs_tree_map-matnr BETWEEN '0000200008' AND '0000200010'.
    lv_plan_plant = 'P00001'.
  ENDIF.

  lv_count      = 3.
  lv_plan_year  = sy-datum(4).
  lv_plan_month = sy-datum+4(2) + 1.
  lt_vkorg = VALUE #( ( '1010' ) ( '1020' ) ).

  DO lv_count TIMES.

    LOOP AT lt_vkorg INTO lv_plan_vkorg.

      READ TABLE gt_display4 TRANSPORTING NO FIELDS
        WITH KEY plan_vkorg = lv_plan_vkorg
                 plan_matnr = gs_tree_map-matnr
                 plan_year  = lv_plan_year
                 plan_month = lv_plan_month.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      READ TABLE gt_plan_all TRANSPORTING NO FIELDS
        WITH KEY vkorg      = lv_plan_vkorg
                 matnr      = gs_tree_map-matnr
                 plan_month = |{ lv_plan_year }{ lv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      READ TABLE gt_plan_all TRANSPORTING NO FIELDS
        WITH KEY plan_month = |{ lv_plan_year }{ lv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|
                 matnr      = gs_tree_map-matnr
                 mrp_stat   = 'X'.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      READ TABLE gt_plan_deleted TRANSPORTING NO FIELDS
        WITH KEY plan_vkorg = lv_plan_vkorg
                 plan_matnr = gs_tree_map-matnr
                 plan_month = |{ lv_plan_year }{ lv_plan_month WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.

      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      CLEAR gs_display4.

      gs_display4-plan_vkorg = lv_plan_vkorg.
      gs_display4-plan_matnr = gs_tree_map-matnr.
      gs_display4-plan_matnm = lv_matnm.
      gs_display4-plan_year  = lv_plan_year.
      gs_display4-plan_month = lv_plan_month.
      gs_display4-plan_meins = 'EA'.
      gs_display4-plan_werks = lv_plan_plant.

      APPEND gs_display4 TO gt_display4.

    ENDLOOP.

    lv_plan_month += 1.

    IF lv_plan_month GE 13.
      lv_plan_month = 1.
      lv_plan_year += 1.
    ENDIF.

  ENDDO.

  IF go_alv_grid4 IS BOUND.
    go_alv_grid4->refresh_table_display( ).
    gt_display4_old = gt_display4.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_per_obli
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_gv_per .

  DATA lv_per TYPE p LENGTH 6 DECIMALS 2.

  CHECK ok_code = 'CONT'.

  " 작년도 판매량 기준일 때만 퍼센트 필수
  IF gv_op3 = abap_true.

    IF gv_per IS INITIAL.
      " 퍼센테이지 입력 필수입니다.
      MESSAGE w444.
      LEAVE to SCREEN 150.
    ENDIF.

    TRY.
        lv_per = gv_per.

      CATCH cx_sy_conversion_no_number.
        " 퍼센테이지는 숫자만 입력 가능합니다.
        MESSAGE w445.
        LEAVE to SCREEN 150.
    ENDTRY.

  ENDIF.


ENDFORM.
