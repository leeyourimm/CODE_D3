*&---------------------------------------------------------------------*
*& Include          ZRD3SD9010_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .

  " 대금청구 데이터 Select
  " 입력한 값을 기준으로 검색
  PERFORM select_input_data.

  " 대금청구와 관련된 전표 Select
  PERFORM select_statement_data.


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

  LOOP AT gt_billing INTO gs_billing.

    " 대금청구 상태 세팅
    PERFORM set_vbstat_txt.


    " 대금청구 여부에 따른 아이콘 세팅
    PERFORM set_status.

    MODIFY gt_billing FROM gs_billing.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  IF gv_no_data IS INITIAL.

    CALL SCREEN 0100.

  ELSE.

    RETURN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_alv_data_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_data_0100 .

  " 딜리버리 헤더를 위한 ALV
  go_alv_grid->set_table_for_first_display(
  EXPORTING
    i_structure_name              = 'ZSD3SD0010'              " Internal Output Table Structure Name
      is_variant                  = gs_variant              " Layout
      i_save                      = gv_save                 " Save Layout
    is_layout                     = gs_layout                 " Layout
  CHANGING
    it_outtab                     = gt_display                " Output Table
      it_fieldcatalog             = gt_fieldcat               " Field Catalog
  EXCEPTIONS
    OTHERS                        = 1
).
  IF sy-subrc <> 0.
    " E008 : &1 Custom Container 생성에 실패하였습니다.
    MESSAGE e008.
  ENDIF.

  " 딜리버리 아이템을 위한 ALV
  go_alv_grid2->set_table_for_first_display(
  EXPORTING
    i_structure_name              = 'ZSD3SD0011'              " Internal Output Table Structure Name
      is_variant                  = gs_variant2              " Layout
      i_save                      = gv_save2                 " Save Layout
    is_layout                     = gs_layout2                " Layout
  CHANGING
    it_outtab                     = gt_detail               " Output Table
      it_fieldcatalog             = gt_fieldcat2               " Field Catalog
  EXCEPTIONS
    OTHERS                        = 1
).
  IF sy-subrc <> 0.
    " E008 : &1 Custom Container 생성에 실패하였습니다.
    MESSAGE e008.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_data_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_data_0100 .

  REFRESH gt_display.

  MOVE-CORRESPONDING gt_billing TO gt_display.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fielfcat_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0100 .

  CLEAR gs_fieldcat.
************************************************************************
* 헤더
************************************************************************
  " 대금청구번호
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'VBELN'.
  gs_fieldcat-hotspot   = abap_true.
  gs_fieldcat-key = 'X'.
  gs_fieldcat-outputlen = 13.
  APPEND gs_fieldcat TO gt_fieldcat.

  " 판매오더 번호
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'VBELN_SO'.
  gs_fieldcat-hotspot   = abap_on.
  gs_fieldcat-outputlen = 13.
  APPEND gs_fieldcat TO gt_fieldcat.

  " 배송오더 번호
  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'DLRNO'.
  gs_fieldcat-coltext   = '대표 출고요청 번호'.
  gs_fieldcat-hotspot   = abap_on.
  gs_fieldcat-outputlen = 13.
  APPEND gs_fieldcat TO gt_fieldcat.



  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'NETWR'.
  gs_fieldcat-cfieldname = 'WAERS'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'GROSS'.
  gs_fieldcat-cfieldname = 'WAERS'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'STATUS'.
  gs_fieldcat-coltext   = '수금 상태'.
  gs_fieldcat-icon      = abap_true.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'RE_DATE'.
  gs_fieldcat-coltext   = '순액 만기일'.
  gs_fieldcat-icon      = abap_true.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'GET_PRICE'.
  gs_fieldcat-coltext   = '수금 금액'.
  gs_fieldcat-cfieldname = 'WAERS'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'NG_PRICE'.
  gs_fieldcat-coltext   = '미수 금액'.
  gs_fieldcat-cfieldname = 'WAERS'.
  APPEND gs_fieldcat TO gt_fieldcat.




************************************************************************
* 아이템
************************************************************************

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'VBELN'.
  gs_fieldcat-key = 'X'.
  gs_fieldcat-outputlen = 10.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'POSNR'.
  gs_fieldcat-key = 'X'.
  gs_fieldcat-outputlen = 13.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MATNR'.
  gs_fieldcat-outputlen = 6.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname  = 'FKIMG'.
  gs_fieldcat-qfieldname = 'VRKME'.
  gs_fieldcat-outputlen = 6.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'VRKME'.
  gs_fieldcat-outputlen = 6.
  APPEND gs_fieldcat TO gt_fieldcat2.


  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname  = 'NETWR'.
  gs_fieldcat-cfieldname = 'WAERS'.
  gs_fieldcat-outputlen = 12.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'TAX_PRICE'.
  gs_fieldcat-coltext   = '세금 금액'.
  gs_fieldcat-cfieldname = 'WAERS'.
  gs_fieldcat-outputlen = 12.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname  = 'NETPR'.
  gs_fieldcat-cfieldname = 'WAERS'.
  gs_fieldcat-outputlen = 12.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname  = 'GROSS'.
  gs_fieldcat-coltext    = '총액'.
  gs_fieldcat-cfieldname = 'WAERS'.
  gs_fieldcat-outputlen = 12.
  APPEND gs_fieldcat TO gt_fieldcat2.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MWTXT'.
  gs_fieldcat-coltext   = '세금 텍스트'.
  gs_fieldcat-outputlen = 10.
  APPEND gs_fieldcat TO gt_fieldcat2.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_0100 .

  " gs_layout-cwidth_opt = abap_true.
  gs_layout-zebra      = abap_true.
  gs_layout-sel_mode   = 'D'.
  gs_layout-grid_title = gv_alv_title.
  gs_layout-info_fname = 'LINE_COLOR'.  " 행 색깔
  gs_layout-totals_bef = abap_true.


  " gs_layout2-cwidth_opt = abap_true.
  gs_layout2-zebra      = abap_true.
  gs_layout2-grid_title = gv_alv_item_title.
  gs_layout2-sel_mode   = 'D'.
  gs_layout2-totals_bef = abap_true.

  gs_variant-report = sy-repid.
  gs_variant-handle = 'H1'.
  gv_save           = 'A'.

  gs_variant2-report = sy-repid.
  gs_variant2-handle = 'H2'.
  gv_save2           = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_handler_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_handler_0100 .

  SET HANDLER lcl_event_handler=>on_double_click FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_toolbar FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_user_command FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_hotspot_click FOR go_alv_grid.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_OBJECT
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING    po_object  TYPE REF TO cl_alv_event_toolbar_set.

  DATA ls_button LIKE LINE OF po_object->mt_toolbar.

  " 최대 조회 건수 변경하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'SHOW_ROW'.
  ls_button-butn_type = 0.  " 0: Normal
  ls_button-icon = icon_add_row.
  " D02 : 최대 조회 건수 변경
  ls_button-text = TEXT-d02.
  APPEND ls_button TO po_object->mt_toolbar.


  " 구분선
  CLEAR ls_button.
  ls_button-function = 'ROW'.
  ls_button-butn_type = 3.  " 3: 구분선
  APPEND ls_button TO po_object->mt_toolbar.


  " 필터링 전체
  CLEAR ls_button.
  ls_button-function = 'ALL'.
  ls_button-butn_type = 0.  " 0: Normal
  " D11 : 전체
  ls_button-text = TEXT-d11.
  APPEND ls_button TO po_object->mt_toolbar.

  " 필터링 미수
  CLEAR ls_button.
  ls_button-function = 'NO_RE'.
  ls_button-butn_type = 0.  " 0: Normal
  ls_button-icon = icon_led_red.
  " D07 : 미수금
  ls_button-text = TEXT-d07.
  APPEND ls_button TO po_object->mt_toolbar.

  " 필터링 부분 수금
  CLEAR ls_button.
  ls_button-function = 'SH_RE'.
  ls_button-butn_type = 0.  " 0: Normal
  ls_button-icon = icon_led_yellow.
  " D08 : 부분 수금
  ls_button-text = TEXT-d08.
  APPEND ls_button TO po_object->mt_toolbar.

  " 필터링 수금 완료
  CLEAR ls_button.
  ls_button-function = 'CL_RE'.
  ls_button-butn_type = 0.  " 0: Normal
  ls_button-icon = icon_led_green.
  " D09 : 수금 완료
  ls_button-text = TEXT-d09.
  APPEND ls_button TO po_object->mt_toolbar.

  " 구분선
  CLEAR ls_button.
  ls_button-function = 'ROW'.
  ls_button-butn_type = 3.  " 3: 구분선
  APPEND ls_button TO po_object->mt_toolbar.

  " 필터링 미도래
  CLEAR ls_button.
  ls_button-function = 'LT_RE'.
  ls_button-butn_type = 0.  " 0: Normal
  ls_button-icon = icon_date.
  " D02 : 미도래
  ls_button-text = TEXT-d10.
  APPEND ls_button TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_delivery_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM select_billing_item  USING    po_row    TYPE lvc_s_row
                                   po_column TYPE lvc_s_col.



  DATA : lv_count TYPE i.

  CLEAR gs_display.
  CLEAR gs_billing_item.

  READ TABLE gt_display INTO gs_display INDEX po_row-index.

  SELECT b~vbeln,
         b~posnr,
         b~matnr,
         b~mwskz,
         b~fkimg,
         b~vrkme,
         b~netpr,
         b~netwr,
         a~waers
    FROM ztd3sd0010 AS a INNER JOIN ztd3sd0011 AS b
      ON a~vbeln EQ b~vbeln
   WHERE b~vbeln EQ @gs_display-vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_billing_item.

  READ TABLE gt_billing_item INTO gs_billing_item INDEX 1.

  lv_count = lines( gt_billing_item ).

  gv_alv_item_title = |{ TEXT-t06 } ({ lv_count NUMBER = USER })|.  " &1 아이템 목록
  REPLACE '&1' IN gv_alv_item_title WITH gs_billing_item-vbeln.




ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_statement
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM select_statement  USING    po_row_id    TYPE lvc_s_row
                                po_column_id TYPE lvc_s_col.


  DATA: lv_ar_amt  TYPE ztd3fi0004-wrbtr,      " 발생 채권
        lv_clr_amt TYPE ztd3fi0004-wrbtr,      " 받은 채권
        lv_rem_amt TYPE ztd3fi0004-wrbtr.      " 남은 채권


  CLEAR: gs_billing,
         gv_belnr,
         gv_duedt,   " 순액만기일
         gv_bildt,   " 대금청구일
         gv_suppr,   " 지급 금액
         gv_ngtpr,   " 미수 금액
         gv_bilpr,   " 청구 금액
         gv_getpr,   " 수금 금액
         gv_kunnr,   " 고객 코드
         waers,
         b1, b2, b3,
         lv_ar_amt, lv_clr_amt, lv_rem_amt.

  REFRESH gt_statement.
  CLEAR   gs_statement.

  CLEAR gs_display.

  READ TABLE gt_display INTO gs_display INDEX po_row_id-index.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  gv_bildt = gs_display-fkdat.

  SELECT a~koart,   " 계정유형
         a~bschl,   " 전기키
         a~kunnr,   " 고객코드
         a~wrbtr,   " 거래 통화금액
         a~belnr,   " 전표번호
         a~due_date," 순액 만기일
         a~waers    " 통화코드
    FROM ztd3fi0004 AS a
"   INNER JOIN ztd3sd0008 AS b ON a~vbeln = b~vbeln
   INNER JOIN ztd3sd0010 AS c ON a~vbeln = c~vbeln_so
   WHERE c~vbeln = @gs_display-vbeln
   ORDER BY a~belnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_statement.


  IF gt_statement IS INITIAL.
    RETURN.
  ENDIF.



  LOOP AT gt_statement INTO gs_statement.

    " 고객 채권 발생 라인 (고객 차변)
    " 전기키 마스터 기준: 01 = 고객 차변(매출채권 발생)
    IF gs_statement-koart = 'D'
       AND gs_statement-bschl = 1.

      lv_ar_amt = lv_ar_amt + gs_statement-wrbtr.

      IF gv_belnr IS INITIAL.

        gv_belnr = gs_statement-belnr.
        gv_duedt = gs_display-re_date.
        gv_kunnr = gs_statement-kunnr.
        waers    = gs_statement-waers.
        gv_waers = gs_statement-waers.
      ENDIF.

    ENDIF.

    " 고객 입금/반제 라인 (고객 대변)
    " 전기키 마스터 기준: 11 = 고객 대변(입금/반제)
    IF gs_statement-koart = 'D'
       AND gs_statement-bschl = 11.

      lv_clr_amt = lv_clr_amt + gs_statement-wrbtr.

    ENDIF.

  ENDLOOP.

  " 미수잔액 계산
  lv_rem_amt = lv_ar_amt - lv_clr_amt.
  IF lv_rem_amt < 0.
    lv_rem_amt = 0.
  ENDIF.




  " 화면 표시값
  gv_bilpr = lv_ar_amt.   " 청구금액
  gv_ngtpr = lv_rem_amt.  " 미수 금액
  gv_getpr = lv_clr_amt.  " 받은 금액

  " 지급상태 라디오버튼
  CLEAR: b1, b2, b3.

  IF lv_ar_amt > 0 AND lv_clr_amt = 0.
    b1 = 'X'.   " 미지급
  ELSEIF lv_ar_amt > lv_clr_amt AND lv_clr_amt > 0.
    b2 = 'X'.   " 일부 지급
  ELSEIF lv_ar_amt > 0 AND lv_clr_amt >= lv_ar_amt.
    b3 = 'X'.   " 전액 지급
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_data .
* 프로그램 제목
  gv_title    = sy-title.

* 회사명 기본 1000 입력되게


* APP TOOLBAR
  gs_butn_info-icon_text = TEXT-hid. " 조건 닫기
  gs_butn_info-icon_id   = icon_collapse.

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

  CHECK go_alv_grid IS BOUND.
  CHECK go_alv_grid2 IS BOUND.

  gs_layout-grid_title = gv_alv_title.  " 먼저 제목 최신값 반영
  gs_layout2-grid_title = gv_alv_item_title.  " 먼저 제목 최신값 반영


  CALL METHOD go_alv_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

  CALL METHOD go_alv_grid2->set_frontend_layout
    EXPORTING
      is_layout = gs_layout2.

  go_alv_grid->refresh_table_display( ).
  go_alv_grid2->refresh_table_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_dock_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_dock_status .
* 도킹 컨테이너 상태 변수 변경
  IF gv_dock_state = abap_on.
    gv_dock_state = abap_off.
  ELSE.
    gv_dock_state = abap_on.
  ENDIF.

* 도킹 컨테이너 보이기/숨기기
  IF go_dock_top IS BOUND. " 컨테이너 객체가 생성되어 있다면
    CALL METHOD go_dock_top->set_visible
      EXPORTING
        visible = gv_dock_state.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_btn_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_btn_status .

* 버튼 텍스트/아이콘 동적으로 세팅
  IF gv_dock_state = abap_on. " 열려있을 때
    gs_butn_info-icon_text    = TEXT-hid. " D01: 조건 닫기
    gs_butn_info-icon_id = icon_collapse. " [아이콘] 위로 접기 모양
  ELSE.                   " 닫혀있을 때
    gs_butn_info-icon_text    = TEXT-shw. " D02: 조건 열기
    gs_butn_info-icon_id = icon_expand.   " [아이콘] 아래로 펼치기 모양
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_search_condition
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_search_condition .
*--------------------------------------------------------------------*
* 상단에 docking container, doc 생성
*--------------------------------------------------------------------*
  IF go_dock_top IS INITIAL.
    CREATE OBJECT go_dock_top
      EXPORTING
        repid     = sy-repid " REPORT TO WHICH THIS DOCKING CONTROL IS LINKED
        dynnr     = sy-dynnr " SCREEN TO WHICH THIS DOCKING CONTROL IS LINKED
        side      = cl_gui_docking_container=>dock_at_top
        extension = 63               " Control Extension
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc <> 0.
      MESSAGE e019. " 019: &1 Docking Container 생성에 실패하였습니다.
    ENDIF.

    CREATE OBJECT go_doc
      EXPORTING
        style      = 'ALV_GRID'
        no_margins = 'X'.
  ENDIF.

  PERFORM set_document_data_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING    p_row_id    TYPE lvc_s_row
                                    p_column_id TYPE lvc_s_col.


  READ TABLE gt_display INTO gs_display INDEX p_row_id-index.

* 출력용 ITAB에서 선택한 행에 대한 정보를 찾지 못할 경우 중단한다.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

* 선택한 컬럼명의 필드명에 따라 로직을 구현한다.
  CASE p_column_id-fieldname.
    WHEN 'VBELN_SO'.
      PERFORM select_so        USING p_row_id
                                     p_column_id.

    WHEN 'DLRNO'. " 대금청구번호
      PERFORM select_do        USING p_row_id
                                     p_column_id.

    WHEN 'VBELN'.
      " 전표 조회
      PERFORM select_statement USING p_row_id
                                     p_column_id.

      CALL SCREEN 0110 STARTING AT 10 10 ENDING AT 135 23.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_command  USING pv_ucomm TYPE sy-ucomm.

  DATA lv_status TYPE icon-name.

  CASE pv_ucomm.
    WHEN 'SHOW_ROW'.
      PERFORM set_show_row.
      " 전체 조회
    WHEN 'ALL'.
      PERFORM clear_filter.
      " 미수 조회
    WHEN 'NO_RE'.
      lv_status = icon_led_red.
      PERFORM set_filter USING lv_status.
      " 일부 반제 조회
    WHEN 'SH_RE'.
      lv_status = icon_led_yellow.
      PERFORM set_filter USING lv_status.
      " 전체 반제 조회
    WHEN 'CL_RE'.
      lv_status = icon_led_green.
      PERFORM set_filter USING lv_status.
      " 미도래 조회
    WHEN 'LT_RE'.
      lv_status = icon_date.
      PERFORM set_filter USING lv_status.


  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_input_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_input_data .

  REFRESH gt_billing.

  SELECT b~vbeln,
      b~bukrs,
      b~kunnr,
      a~butxt,
      a~repnm,
      b~vbeln_so,
      b~dlrno,
      b~fkdat,
      b~re_date,
      b~vkorg,
      b~netwr,
      b~gross,
      b~waers,
      b~zterm,
      b~vbstat
  FROM ztd3sd0001 AS a INNER JOIN ztd3sd0010 AS b
  ON a~kunnr EQ b~kunnr
  WHERE b~vbeln  IN @so_vb
    AND substring( b~vbeln, 3, 1 ) NE '8'
  AND b~vbeln_so IN @so_vs
  AND b~dlrno    IN @so_vd
  AND b~bukrs    IN @so_bu
  AND b~kunnr    IN @so_cu
  AND b~fkdat    IN @so_bd
  INTO CORRESPONDING FIELDS OF TABLE @gt_billing
  UP TO @pa_mrow ROWS.

  " 1000번 스크린에서 입력한 조회 조건 개수보다 실제 검색된 데이터가 더 적을 때
  IF pa_mrow GT lines( gt_billing ).
    pa_mrow = lines( gt_billing ).
  ENDIF.


  SORT gt_billing BY fkdat kunnr.

  IF gt_billing IS INITIAL.
    gv_no_data = abap_true.
    " 052 : 조회된 데이터가 0건 입니다.
    MESSAGE s052 DISPLAY LIKE 'A'.
  ENDIF.

  gv_alv_title = | { TEXT-t02 } ({ pa_mrow NUMBER = USER })건 |. " t02: 대금청구 목록


ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_selected_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM set_selected_color  USING    p_row    TYPE lvc_s_row
                                  p_column TYPE lvc_s_col
                                  p_roid   TYPE lvc_s_roid.

  CLEAR gs_display.

  LOOP AT gt_display INTO gs_display.

    IF sy-tabix = p_roid-row_id.
      gs_display-line_color = 'C500'.
    ELSE.
      CLEAR gs_display-line_color.
    ENDIF.

    MODIFY gt_display FROM gs_display INDEX sy-tabix.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_vbstat_txt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_vbstat_txt .


  CLEAR gs_billing-vbstat_txt.

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_BOSTAT'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_billing-vbstat.

  gs_billing-vbstat_txt = ls_dom-ddtext.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_status .

  DATA : lv_rule TYPE c.

  " 만기일 지난 거래
  PERFORM set_icon_rule  USING lv_rule.
  " 만기일 지나지 않은 거래
  PERFORM set_icon_rule2 USING lv_rule.

  CASE lv_rule.
    WHEN 'A'.
      gs_billing-status = icon_led_green.
    WHEN 'B'.
      gs_billing-status = icon_led_yellow.
    WHEN 'C'.
      gs_billing-status = icon_led_red.
    WHEN 'D'.
      gs_billing-status = icon_date.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_statement_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_statement_data .

  REFRESH gt_statement.

  SELECT koart,      " 계정유형
         bschl,      " 전기키
         a~kunnr,    " 고객코드
         wrbtr,      " 거래 통화금액
         belnr,      " 전표번호
         due_date,   " 순액 만기일
         a~waers,    " 통화코드
         a~vbeln     " 발생 전표번호
  FROM ztd3fi0004 AS a
 INNER JOIN ztd3sd0010 AS b ON a~vbeln = b~vbeln_so
 ORDER BY a~belnr
  INTO CORRESPONDING FIELDS OF TABLE @gt_statement.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_icon_rule
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RULE
*&---------------------------------------------------------------------*
FORM set_icon_rule  CHANGING    pv_rule TYPE c.

  CLEAR gs_billing-get_price.
  CLEAR gs_billing-ng_price.

  DATA: lv_ar_amt  TYPE ztd3fi0004-wrbtr,      " 발생 채권
        lv_clr_amt TYPE ztd3fi0004-wrbtr,      " 받은 채권
        lv_rem_amt TYPE ztd3fi0004-wrbtr.      " 남은 채권


  IF gt_statement IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT gt_statement INTO gs_statement
    WHERE vbeln EQ gs_billing-vbeln_so.

    " 고객 채권 발생 라인 (고객 차변)
    " 전기키 마스터 기준: 01 = 고객 차변(매출채권 발생)
    IF gs_statement-koart = 'D'
       AND gs_statement-bschl = 1.

      lv_ar_amt += gs_statement-wrbtr.

    ENDIF.

    " 고객 입금/반제 라인 (고객 대변)
    " 전기키 마스터 기준: 11 = 고객 대변(입금/반제)
    IF gs_statement-koart = 'D'
       AND gs_statement-bschl = 11.

      lv_clr_amt += gs_statement-wrbtr.

    ENDIF.


    " 미수잔액 계산
    lv_rem_amt = lv_ar_amt - lv_clr_amt.
    IF lv_rem_amt < 0.
      lv_rem_amt = 0.
    ENDIF.

    gs_billing-get_price = lv_clr_amt.    " 받은 금액 세팅
    gs_billing-ng_price  = lv_rem_amt.    " 미수 금액 세팅

    CHECK gs_billing-re_date LT sy-datum.

    " 전체 수금 시
    IF lv_rem_amt EQ 0.
      pv_rule = 'A'.
      " 일부 수금 시
    ELSEIF lv_rem_amt NE 0 AND lv_rem_amt LT lv_ar_amt.
      pv_rule = 'B'.
      " 미수금 시
    ELSEIF lv_rem_amt EQ lv_ar_amt.
      pv_rule = 'C'.
      .
    ENDIF.

  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_txt_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_txt_0110 .


  CLEAR gv_txt.

  DATA : lv_days TYPE i.
  DATA : lv_days_txt TYPE n.

  DATA: lv_fact_due   TYPE scal-facdate,
        lv_fact_today TYPE scal-facdate.

  " 영업일 번호 세팅
  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      date                = gv_duedt
      factory_calendar_id = 'KR'
    IMPORTING
      factorydate         = lv_fact_due.

  " 영업일 번호 세팅
  CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
    EXPORTING
      date                = sy-datum
      factory_calendar_id = 'KR'
    IMPORTING
      factorydate         = lv_fact_today.

  lv_days = lv_fact_today - lv_fact_due.

  lv_days_txt = lv_days.

  IF lv_days GT 0 AND gv_ngtpr NE 0.
    " T07 : 연체
    gv_txt = |{ TEXT-t07 } ( D + { lv_days NUMBER = USER } ) |.
    REPLACE '&1' IN gv_txt WITH lv_days_txt.
  ELSEIF lv_days LE 0 AND gv_ngtpr NE 0.
    " T08 : 순액만기일 미도래
    gv_txt = TEXT-t08.
  ELSE.
    " D09 : 수금 완료
    gv_txt = TEXT-d09.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_zttxt_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_zttxt.

  CLEAR gv_zttxt.

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_FI_ZTERM'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_display-zterm.

  gv_zttxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_butxt_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_butxt_0110 .
  CLEAR gv_butxt.

  SELECT SINGLE butxt
    FROM ztd3fi0002
   WHERE bukrs EQ @gs_display-bukrs
    INTO @gv_butxt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_vktxt_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_vktxt_0110 .

  IF gs_display-vkorg EQ '1010'.
    gv_vktxt = '수도권'.
  ELSEIF gs_display-vkorg EQ '1020'.
    gv_vktxt = '비수도권'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_tax_price
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_item.

  LOOP AT gt_billing_item INTO gs_billing_item.



    CASE gs_billing_item-mwskz.
      WHEN 'A1'.
        gs_billing_item-tax_price = gs_billing_item-netwr / 10.
        " 20 : 부가세
        gs_billing_item-mwtxt = TEXT-d20.
    ENDCASE.

    gs_billing_item-gross = gs_billing_item-netwr + gs_billing_item-tax_price.

    MODIFY gt_billing_item FROM gs_billing_item.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_show_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_show_row .

  DATA : lv_number TYPE i.

  FIELD-SYMBOLS : <ft_lines>    TYPE i.   " 조회 조건으로 검색한 전체 결과 갯수
  FIELD-SYMBOLS : <ft_max_rows> TYPE i.   " 조회 조건으로 검색한 결과 중 최대 조회 건수 제한에 따라 검색된 갯수

  lv_number = lines( gt_billing ).

  ASSIGN lv_number   TO <ft_lines>.
  ASSIGN pa_mrow     TO <ft_max_rows>.

*     1. 조회조건에서 입력된 최대 조회 건수를 가져와서 변경한다.
  CALL FUNCTION 'ZFD3PP0004'
    CHANGING
      cv_max_row = <ft_max_rows>.   " Max Row 변수

*     2. 데이터 재조회
  PERFORM select_data.        " 데이터 조회
  PERFORM modify_data.

*     3. display ITAB에 데이터 옮김
  PERFORM move_data_0100.
  REFRESH gt_detail.


*     2. ALV 화면 새로고침
  PERFORM refresh_alv_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_filter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_filter .


  DATA: lt_filter TYPE lvc_t_filt,
        ls_stbl   TYPE lvc_s_stbl.

  CLEAR lt_filter.

  CALL METHOD go_alv_grid->set_filter_criteria
    EXPORTING
      it_filter = lt_filter.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  gv_alv_title = | { TEXT-t02 } ({ pa_mrow NUMBER = USER })건 |. " t02: 대금청구 목록

  gs_layout-grid_title = gv_alv_title.

  CALL METHOD go_alv_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_filter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_filter  USING pv_status TYPE icon-name.


  DATA: lt_filter TYPE lvc_t_filt,
        ls_filter TYPE lvc_s_filt,
        ls_stbl   TYPE lvc_s_stbl.

  DATA : lv_count TYPE i.

  CLEAR: lt_filter, ls_filter.

  ls_filter-fieldname = 'STATUS'.
  ls_filter-sign      = 'I'.
  ls_filter-option    = 'EQ'.
  ls_filter-low       =  pv_status.
  APPEND ls_filter TO lt_filter.

  CALL METHOD go_alv_grid->set_filter_criteria
    EXPORTING
      it_filter = lt_filter.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  " 필터링 건수 계산
  LOOP AT gt_display INTO gs_display
       WHERE status EQ pv_status.

    lv_count = lv_count + 1.

  ENDLOOP.

  gv_alv_title = | { TEXT-t02 } ({ lv_count NUMBER = USER })건 |. " t02: 대금청구 목록

  gs_layout-grid_title = gv_alv_title.

  CALL METHOD go_alv_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.


  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_so USING    po_row_id    TYPE lvc_s_row
                        po_column_id TYPE lvc_s_col.


  CLEAR gs_display.

  READ TABLE gt_display INTO gs_display INDEX po_row_id-index.

  CLEAR gs_so.

  SELECT SINGLE vbeln,
                vgbel,
                kunnr,
                vkorg,
                audat,
                edatu,
                auart,
                netwr,
                gross,
                waers,
                vsbed,
                zterm,
                vstat,
                erdat,
                ernam
    FROM ztd3sd0006
   WHERE vbeln EQ @gs_display-vbeln_so
    INTO CORRESPONDING FIELDS OF @gs_so.

  CALL SCREEN 0120 STARTING AT 10 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_document_data_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_document_data_0100 .

  DATA: lv_html     TYPE string,
        lv_bukr_txt TYPE string,     " 회사코드
        lv_comp_txt TYPE string,     " 임시

        lv_kunn_txt TYPE string,     " 고객코드
        lv_bonm_txt TYPE string,     " 대금청구 번호
        lv_date_txt TYPE string.     " 대금청구 일자

  PERFORM get_range_text USING so_bu[]  CHANGING lv_bukr_txt.        " 회사코드
  PERFORM get_range_text USING so_vb[]  CHANGING lv_bonm_txt.        " 대금청구 번호
  PERFORM get_range_text USING so_cu[]  CHANGING lv_kunn_txt.        " 고객코드
  PERFORM get_range_text USING so_bd[]  CHANGING lv_date_txt.        " 대금청구 일자


  lv_html =
  '<html>' &&
  '<body style="font-family:Malgun Gothic, Arial, sans-serif; font-size:10pt; margin:0;">' &&

  '<div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">' &&
  '<span style="font-size:22px;">🔍</span>' &&
  '<span style="font-size:16pt; font-weight:bold;">조회 조건</span>' &&
  '</div>' &&

  '<table style="border-collapse:collapse; width:100%; font-size:10pt;">' &&

  '<tr>' &&
  '<td style="font-weight:bold; padding:3px 8px; width:130px;">회사 코드</td>' &&
  '<td style="padding:3px 8px;">' && lv_bukr_txt && '</td>' &&
  '<td style="font-weight:bold; padding:3px 8px; width:130px;">고객코드</td>' &&
  '<td style="padding:3px 8px;">' && lv_kunn_txt && '</td>' &&
  '</tr>' &&

  '<tr>' &&
  '<td style="font-weight:bold; padding:3px 8px;">대금청구 번호</td>' &&
  '<td style="padding:3px 8px;">' && lv_bonm_txt && '</td>' &&
  '<td style="font-weight:bold; padding:3px 8px;">대금청구 일자</td>' &&
  '<td style="padding:3px 8px;">' && lv_date_txt && '</td>' &&
  '</tr>' &&


  '</table>' &&
  '<hr style="border:0; border-top:1px solid #999; margin-top:8px;">' &&
  '</body>' &&
  '</html>'.


*--------------------------------------------------------------------*
* 완성된 문서 컨테이너에 띄우기
*--------------------------------------------------------------------*

  go_doc->add_static_html(
    string_with_html = lv_html
  ).


  go_doc->display_document(
    EXPORTING
      parent             = go_dock_top                    " Contain Object Already Exists
    EXCEPTIONS
      OTHERS             = 1
  ).
  IF sy-subrc <> 0.
    " 022: &1 Document 출력에 실패하였습니다.
    MESSAGE a022.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_range_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SO_BU[]
*&      <-- LV_PNUM_TEXT
*&---------------------------------------------------------------------*
FORM get_range_text    USING    it_range TYPE STANDARD TABLE
                       CHANGING cv_text  TYPE string.

  DATA lv_line TYPE string.

  CLEAR cv_text.

  LOOP AT it_range ASSIGNING FIELD-SYMBOL(<ls_range>).

    ASSIGN COMPONENT 'SIGN'   OF STRUCTURE <ls_range> TO FIELD-SYMBOL(<sign>).
    ASSIGN COMPONENT 'OPTION' OF STRUCTURE <ls_range> TO FIELD-SYMBOL(<option>).
    ASSIGN COMPONENT 'LOW'    OF STRUCTURE <ls_range> TO FIELD-SYMBOL(<low>).
    ASSIGN COMPONENT 'HIGH'   OF STRUCTURE <ls_range> TO FIELD-SYMBOL(<high>).

    CLEAR lv_line.

    CASE <option>.
      WHEN 'BT'.
        lv_line = |{ <low> } ~ { <high> }|.
      WHEN 'EQ'.
        lv_line = |{ <low> }|.
      WHEN 'CP'.
        lv_line = |{ <low> }|.
      WHEN OTHERS.
        lv_line = |{ <option> } { <low> } { <high> }|.
    ENDCASE.

    IF <sign> = 'E'.
      lv_line = |제외: { lv_line }|.
    ENDIF.

    IF cv_text IS INITIAL.
      cv_text = lv_line.
    ELSE.
      cv_text = cv_text && `, ` && lv_line.
    ENDIF.

  ENDLOOP.

  IF cv_text IS INITIAL.
    cv_text = '전체'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_do
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_ROW_ID
*&      --> P_COLUMN_ID
*&---------------------------------------------------------------------*
FORM select_do  USING    po_row_id    TYPE lvc_s_row
                         po_column_id TYPE lvc_s_col.

  CLEAR gs_display.


  READ TABLE gt_display INTO gs_display INDEX po_row_id-index.

  CLEAR gt_do.

  SELECT dlrno,
         vbeln,
         werks,
         type,
         wsdat,
         wadat,
         lfdat,
         waers,
         vsbed,
         listat,
         erdat,
         ernam
    FROM ztd3sd0008
   WHERE vbeln EQ @gs_display-vbeln_so
    INTO CORRESPONDING FIELDS OF TABLE @gt_do.

  CALL SCREEN 0130 STARTING AT 10 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0130 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0130 OUTPUT.

  " TYPE FIXED VALUE 가져오는 로직
  PERFORM  get_tytxt_0130.
  " 플랜트명 가져오는 로직
  PERFORM  get_wetxt_0130.
  " 배송조건 FIXED VALUE 가져오는 로직
  PERFORM  get_vstxt_0130.

  PERFORM  get_litxt_0130.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form get_type_txt_0130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_tytxt_0130 .

  CLEAR gv_tytxt.

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_LITYPE'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_do-type.

  gv_tytxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_wetxt_0130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_wetxt_0130 .

  CLEAR gv_wetxt.

  CASE gs_do-werks.
    WHEN 'P00001'.
      SELECT SINGLE lgobe
        FROM ztd3mm0003
       WHERE werks EQ @gs_do-werks
         AND lgort EQ 'S10002'
        INTO @gv_wetxt.
    WHEN 'P00002'.
      SELECT SINGLE lgobe
        FROM ztd3mm0003
       WHERE werks EQ @gs_do-werks
         AND lgort EQ 'S20002'
        INTO @gv_wetxt.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_vstxt_0130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_vstxt_0130 .

  CLEAR gv_vstxt.

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_VSBED'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_do-vsbed.

  gv_vstxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_litxt_0130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_litxt_0130 .

  CLEAR gv_litxt.

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_LISTAT'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_do-listat.

  gv_litxt = ls_dom-ddtext.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_kunnm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_kunnm .

  CLEAR gv_kunnm.

  SELECT SINGLE butxt
    FROM ztd3sd0001
   WHERE kunnr EQ @gs_so-kunnr
    INTO @gv_kunnm.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_icon_rule2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_RULE
*&---------------------------------------------------------------------*
FORM set_icon_rule2  USING    pv_rule.

  CHECK gs_billing-re_date GE sy-datum.

  pv_rule = 'D'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_vbeln
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_vbeln .

  DATA: lt_return TYPE TABLE OF ddshretval,
        ls_return TYPE ddshretval,
        lt_dynp   TYPE TABLE OF dynpread,
        ls_dynp   TYPE dynpread,
        ls_bill   TYPE ztd3sd0010.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname     = 'ZTD3SD0010'
      fieldname   = 'VBELN'
      searchhelp  = 'ZSHD3SD0010'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'SO_VB-LOW'
    TABLES
      return_tab  = lt_return.

  READ TABLE lt_return INTO ls_return WITH KEY fieldname = 'VBELN'.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  SELECT SINGLE *
    INTO @ls_bill
    FROM ztd3sd0010
   WHERE vbeln = @ls_return-fieldval.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CLEAR lt_dynp.

  ls_dynp-fieldname  = 'SO_VB-LOW'.
  ls_dynp-fieldvalue = ls_bill-vbeln.
  APPEND ls_dynp TO lt_dynp.

  ls_dynp-fieldname  = 'SO_VS-LOW'.
  ls_dynp-fieldvalue = ls_bill-vbeln_so.
  APPEND ls_dynp TO lt_dynp.

  ls_dynp-fieldname  = 'SO_VD-LOW'.
  ls_dynp-fieldvalue = ls_bill-dlrno.
  APPEND ls_dynp TO lt_dynp.

  ls_dynp-fieldname  = 'SO_CU-LOW'.
  ls_dynp-fieldvalue = ls_bill-kunnr.
  APPEND ls_dynp TO lt_dynp.

  " 필요하면 판매오더/출고요청도 파라미터 또는 select-options가 있어야 채울 수 있음
  " 예: SO_SO-LOW, SO_DLR-LOW 같은 필드가 있을 때만 가능

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_dynp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_auto_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_auto_0100 .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_max_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_max_row .

  IF pa_mrow LT 0.

    pa_mrow = 100.
    " 017: 최대 조회 건수는 &1건 이하일 수 없습니다.
    MESSAGE s017 DISPLAY LIKE 'E' WITH 0.

  ELSEIF pa_mrow GE 1000 AND pa_mrow LE 3000.
    " 238 : 조회 건수가 많아 조회 시간이 지연될 수 있습니다.
    MESSAGE i238 DISPLAY LIKE 'W'.

  ELSEIF pa_mrow GT 3000.

    pa_mrow = 3000.
    " 018: 최대 조회 건수는 &1건 초과일 수 없습니다.
    MESSAGE i018 DISPLAY LIKE 'E' WITH 3000.

  ENDIF.

  IF pa_mrow EQ 0.
    "238: 조회 건수가 많아 조회 시간이 지연될 수 있습니다.
    MESSAGE i238 DISPLAY LIKE 'W'.

  ENDIF.

ENDFORM.
