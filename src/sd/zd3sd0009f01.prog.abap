*&---------------------------------------------------------------------*
*& Include          ZD3SD0009F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form select_so_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_delivery_header_data .

  DATA : lv_lines TYPE i.

  REFRESH gt_display1.

  CHECK gv_lfdat_valid IS INITIAL.

  " 판매오더 승인 상태인 데이터만 가져온다.
  SELECT FROM zcds_d3_sd_0010
    FIELDS
      bukrs,
      vbeln,
      kunnr,
      vbeln_so,
      butxt,
      repnm,
      vkorg,
      netwr,
      gross_so,
      lfdat,
      audat,
      waers,
      zterm,
      type,
      wsdat,
      wadat
    WHERE ( bukrs = @gv_bukrs OR @gv_bukrs IS INITIAL )
      AND ( type  = @gv_type  OR @gv_type  IS INITIAL )
      AND kunnr    BETWEEN @gv_ku_from AND @gv_ku_to
      AND vbeln_so BETWEEN @gv_vb_from AND @gv_vb_to
      AND audat    BETWEEN @gv_au_from AND @gv_au_to
      AND lfdat    BETWEEN @gv_lf_from AND @gv_lf_to
     INTO CORRESPONDING FIELDS OF TABLE @gt_delivery_header.

  lv_lines = lines( gt_delivery_header ).

  IF lv_lines EQ 0.
    gv_no_data = abap_true.
    " 조회된 데이터가 0건 입니다.
    MESSAGE s052 DISPLAY LIKE 'A'.
  ENDIF.


  gv_alv_title = | 대금청구 목록 ({ lv_lines }) |.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_data .

  MOVE-CORRESPONDING gt_delivery_header TO gt_display1.

  SORT gt_display1 BY sta_sort  dlrno.

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
  go_container = NEW cl_gui_custom_container( 'CCON1' ).

  go_alv_grid = NEW cl_gui_alv_grid( go_container ).

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

  " gs_layout-cwidth_opt = abap_on. " 컬럼 넓이 최적화
  gs_layout-zebra = abap_on.      " 얼룩 무늬
  gs_layout-sel_mode = 'D'.
  gs_layout-stylefname = 'CELLTAB'.
  gs_layout-ctab_fname = 'CELL_COLOR'.
  gs_layout-grid_title = gv_alv_title.

  gs_variant-report = sy-repid.
  gv_save = 'A'.
  gs_variant-handle = 'H1'.



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

  DEFINE _set_fieldcat.
    CLEAR gs_fieldcat.
    gs_fieldcat-key        = &1.
    gs_fieldcat-fieldname  = &2.
    gs_fieldcat-coltext    = &3.
    gs_fieldcat-icon       = &4.
    gs_fieldcat-cfieldname = &5.
    gs_fieldcat-no_out     = &6.
    gs_fieldcat-outputlen  = &7.
    APPEND gs_fieldcat TO gt_fieldcat.



  END-OF-DEFINITION.

  REFRESH gt_fieldcat.
*                key    fieldname   coltext            icon      cfieldname    no_out    outputlen
  _set_fieldcat  ''     'STATUS'    '상태'             'X'       ''            ''        3 .
  _set_fieldcat  ''     'BUKRS'     '회사코드'         space     ''            'X'       6 .
  _set_fieldcat  'X'    'VBELN_SO'  '판매 오더 번호'        space     ''            ''        10 .
  _set_fieldcat  ''     'KUNNR'     '고객 코드'        space     ''            ''        6 .
  _set_fieldcat  ''     'BUTXT'     '고객명'           space     ''            ''        30 .
  _set_fieldcat  ''     'REPNM'     '대표자명'         space     ''            ''        6 .
  _set_fieldcat  ''     'TYPE'      '출고요청 유형'    space     ''            'X'        8 .
  _set_fieldcat  ''     'TYTXT'     '출고요청 유형'    space     ''            ''        9 .
  _set_fieldcat  ''     'AUDAT'     '주문 일자'        space     ''            ''        8 .
  _set_fieldcat  ''     'GROSS_SO'  '총액'        space     'WAERS'       ''        10 .
  _set_fieldcat  ''     'WAERS'     '통화코드'         space     ''            ''        6 .
  "  _set_fieldcat  ''     'WSDAT'     '출고 예정 일자'   space      ''  .
  "  _set_fieldcat  ''     'WADAT'     '실제 출고 일자'   space      ''  .
  _set_fieldcat  ''     'LFDAT'     '납기 일자'        space     ''            ''        8 .
  _set_fieldcat  ''     'FKDAT'     '청구 날짜'        space     ''            ''        8 .
  _set_fieldcat  ''     'RE_DATE'   '수금 예정 날짜'   space     ''            ''        10 .
  _set_fieldcat  ''     'MAKE_BILL' '청구 실행'        space     ''            ''        8 .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_handler_event
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_handler_event .

  SET HANDLER lcl_event_handler=>on_double_click FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_toolbar FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_user_command FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_button_click FOR go_alv_grid.

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

  go_alv_grid->set_table_for_first_display(
    EXPORTING
*      i_buffer_active               =                  " Buffering Active
*      i_bypassing_buffer            =                  " Switch Off Buffer
*      i_consistency_check           =                  " Starting Consistency Check for Interface Error Recognition
*      i_structure_name              =                  " Internal Output Table Structure Name
       is_variant                    = gs_variant       " Layout
       i_save                        = gv_save
*      i_default                     = 'X'              " Default Display Variant
      is_layout                      = gs_layout        " Layout
*      is_print                      =                  " Print Control
*      it_special_groups             =                  " Field Groups
*      it_toolbar_excluding          =                  " Excluded Toolbar Standard Functions
*      it_hyperlink                  =                  " Hyperlinks
*      it_alv_graphics               =                  " Table of Structure DTC_S_TC
*      it_except_qinfo               =                  " Table for Exception Quickinfo
*      ir_salv_adapter               =                  " Internal Usage only !!! - obsolete
    CHANGING
      it_outtab                      = gt_display1      " Output Table
      it_fieldcatalog                = gt_fieldcat      " Field Catalog
*      it_sort                       =                  " Sort Criteria
*      it_filter                     =                  " Filter Criteria
*    EXCEPTIONS
*      invalid_parameter_combination = 1                " Wrong Parameter
*      program_error                 = 2                " Program Errors
*      too_many_lines                = 3                " Too many Rows in Ready for Input Grid
*      others                        = 4
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
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

  IF gv_lfdat_to EQ '99991231'.
    CLEAR gv_lfdat_to.
  ENDIF.

  gs_layout-grid_title = gv_alv_title.

  IF gv_lfdat_valid IS NOT INITIAL.
    REFRESH gt_display1.
  ENDIF.

  go_alv_grid->refresh_table_display( ).

  CALL METHOD go_alv_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form make_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM make_button .

  DATA : ls_styl TYPE lvc_s_styl.
  DATA : ls_date TYPE c LENGTH 10.

  LOOP AT gt_display1 INTO gs_display1.

    CLEAR gs_display1-celltab.
    CLEAR gs_display1-make_bill.
    CLEAR ls_date.

    CASE gs_display1-status.

      WHEN icon_led_green.

        " 미청구 건일때
      WHEN icon_led_yellow.
        gs_display1-make_bill = '청구생성'.

        CLEAR ls_styl.
        ls_styl-fieldname = 'MAKE_BILL'.
        ls_styl-style     = cl_gui_alv_grid=>mc_style_button.
        INSERT ls_styl INTO TABLE gs_display1-celltab.

      WHEN icon_change_text.
        gs_display1-make_bill = space.

    ENDCASE.

    MODIFY gt_display1 FROM gs_display1.

  ENDLOOP.



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

  " 배송오더 타입 전체를 조회하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'ALL'.
  ls_button-text = '전체'.
  APPEND ls_button TO po_object->mt_toolbar.

  " 배송오더 타입 일반 배송을 조회하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'WILL'.
  ls_button-text = '미청구'.
  ls_button-icon = icon_led_yellow.
  APPEND ls_button TO po_object->mt_toolbar.

  " 배송오더 교환을 조회하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'END'.
  ls_button-text = '청구 완료'.
  ls_button-icon = icon_led_green.
  APPEND ls_button TO po_object->mt_toolbar.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form search_billing_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM search_billing_status  USING    po_ucomm.

  DATA lv_status TYPE icon-name.

  CASE po_ucomm.
    WHEN 'ALL'.
      PERFORM clear_filter.

    WHEN 'WILL'.
      lv_status = icon_led_yellow.
      PERFORM set_filter USING lv_status.

    WHEN 'END'.
      lv_status = icon_led_green.
      PERFORM set_filter USING lv_status.

  ENDCASE.

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
FORM set_filter  USING pv_type TYPE icon-name.


  DATA: lt_filter TYPE lvc_t_filt,
        ls_filter TYPE lvc_s_filt,
        ls_stbl   TYPE lvc_s_stbl.

  CLEAR: lt_filter, ls_filter.

  ls_filter-fieldname = 'STATUS'.
  ls_filter-sign      = 'I'.
  ls_filter-option    = 'EQ'.
  ls_filter-low       = pv_type.
  APPEND ls_filter TO lt_filter.

  CALL METHOD go_alv_grid->set_filter_criteria
    EXPORTING
      it_filter = lt_filter.

  ls_stbl-row = abap_true.
  ls_stbl-col = abap_true.

  CALL METHOD go_alv_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stbl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form click_create_bill
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM click_create_bill  USING    ps_col_id TYPE lvc_s_col
                                 ps_row_no TYPE lvc_s_roid.
  CLEAR gv_tabnm.

  READ TABLE gt_display1 INTO gs_display1  INDEX ps_row_no-row_id.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.


  CASE ps_col_id.
    WHEN 'MAKE_BILL'.

      gv_tabnm = sy-tabix.

      " 노란불: 출고 미완료
      IF gs_display1-status = icon_led_green.
        RETURN.
      ENDIF.






      CALL SCREEN 0200.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_type_list_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_type_list_0100 .

  REFRESH gt_gjahr_type.

  CLEAR gs_gjahr_type.
  gs_gjahr_type-key  = 'N'. " 드롭다운에 보이는 값
  gs_gjahr_type-text = '일반'. " 선택 후 파라미터에 들어가는 값
  APPEND gs_gjahr_type TO gt_gjahr_type.

  CLEAR gs_gjahr_type.
  gs_gjahr_type-key  = 'E'. " 드롭다운에 보이는 값
  gs_gjahr_type-text = '교환'. " 선택 후 파라미터에 들어가는 값
  APPEND gs_gjahr_type TO gt_gjahr_type.

  CLEAR gs_gjahr_type.
  gs_gjahr_type-key  = 'R'. " 드롭다운에 보이는 값
  gs_gjahr_type-text = '회수'. " 선택 후 파라미터에 들어가는 값
  APPEND gs_gjahr_type TO gt_gjahr_type.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GV_TYPE'
      values = gt_gjahr_type.

  gv_type = 'N'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_customer_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_customer_data .

  SELECT SINGLE * FROM ztd3sd0001
   WHERE kunnr EQ gs_display1-kunnr.

  " 지급조건
  gv_zterm = ztd3sd0001-zterm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_bill_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_so_order_data .

  SELECT SINGLE * FROM ztd3sd0006
   WHERE vbeln EQ gs_display1-vbeln.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_billing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_billing .


  REFRESH gt_delivery_header.

  CHECK gv_ok IS NOT INITIAL.
  CLEAR gv_ok.

  gv_save_bool = abap_true.
  gs_display1-status = icon_change_text.

  MODIFY gt_display1 FROM gs_display1 INDEX gv_tabnm.

  MOVE-CORRESPONDING gt_display1 TO gt_delivery_header.



  " 대금청구 테이블에 배송오더 번호가 이미 있는지 확인
  " 없는거면 미청구된 건
  PERFORM create_billing_header.


  " 대금청구 ITAB에 데이터를 옮기기 위한 로직
  " 대금청구 헤더
  " 대금청구 아이템
  PERFORM create_billing_item.

  " 아이템 테이블에서 생긴 금액 총계를 헤더에 옮기기 위한 로직
  PERFORM move_billing_header_netwr.





ENDFORM.

*&---------------------------------------------------------------------*
*& Form modify_so_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM modify_delivery_header_data .

  " CHECK gv_start IS INITIAL.

  CLEAR gs_delivery_header.

  " 완료된 대금청구 데이터를 담을 로직
  PERFORM get_bill_header_end.

  LOOP AT gt_delivery_header INTO gs_delivery_header.

    " 청구 / 미청구 건에 따른 아이콘 표시 로직
    PERFORM set_bill_status.
    " 청구가 완료된 건에 대한 건을 대금 청구 데이터에서 가져오기 위한 로직
    PERFORM set_fkdat.
    " 수금조건에 따른 수금 일자 세팅 로직
    PERFORM set_redat.
    " 미청구 건인 데이터가 위에 나오게 하기 위해 나올 순서를 정해주는 로직
    PERFORM set_sort_status.
    " 출고 타입에 대한 설명 설정
    PERFORM set_type_text.
    " 출고 예정일과 실제 출고일이 다를 경우에 대한 셀 표시 로직
    PERFORM set_cell_color.
    "


    MODIFY gt_delivery_header FROM gs_delivery_header.

  ENDLOOP.

  gv_start = abap_true.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_zttxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_zttxt .

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


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = ztd3sd0001-zterm.

  gv_zttxt = ls_dom-ddtext.

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
  CHECK gv_ok IS NOT INITIAL.
  CLEAR gv_ok.

  CLEAR gv_kunnr_from.
  CLEAR gv_kunnr_to.
  CLEAR gv_lfdat_from.
  CLEAR gv_lfdat_to.
  CLEAR gv_audat_from.
  CLEAR gv_audat_to.
  CLEAR gv_vbeln_from.
  CLEAR gv_vbeln_to.


  CLEAR gv_type.

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

  " 대금청구 관련 ITAB 초기화
  REFRESH gt_bill_item.
  REFRESH gt_bill_header.
  CLEAR gs_bill_header.
  CLEAR gs_bill_item.

  " 세금계산서 관련 ITAB 초기화
  REFRESH gt_tax_item.
  REFRESH gt_tax_header.
  CLEAR gs_tax_header.
  CLEAR gs_tax_item.


  " 저장할 데이터가 있을 때 실행
  CHECK gv_not_initail IS NOT INITIAL.

  CLEAR gv_kunnr_from.
  CLEAR gv_kunnr_to.
  CLEAR gv_lfdat_from.
  CLEAR gv_lfdat_to.
  CLEAR gv_audat_from.
  CLEAR gv_audat_to.
  CLEAR gv_vbeln_from.
  CLEAR gv_vbeln_to.

  REFRESH gt_display1.

  CALL METHOD go_alv_grid->refresh_table_display.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_bill_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_BILL
*&---------------------------------------------------------------------*
FORM set_bill_status.


  DATA: lt_bill TYPE STANDARD TABLE OF ztd3sd0010.

  " 대금청구 상태 확인용 조회
  SELECT *
    FROM ztd3sd0010
    INTO TABLE @lt_bill.

  DATA: ls_bill TYPE ztd3sd0010.

  " 뭔가 잘못된 건
  IF gs_delivery_header-listat = 'N'.
    gs_delivery_header-status = icon_led_red.
    RETURN.
  ENDIF.

  CLEAR ls_bill.
  READ TABLE lt_bill INTO ls_bill
    WITH KEY vbeln_so = gs_delivery_header-vbeln_so.

  IF sy-subrc = 0.
    gs_delivery_header-status = icon_led_green.   " 대금청구 있음
  ELSE.
    gs_delivery_header-status = icon_led_yellow.     " 대금청구 없음
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_type_text
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_type_text .

  CASE gs_delivery_header-type.
    WHEN 'N'.
      gs_delivery_header-tytxt = '일반출고'.
    WHEN 'R'.
      gs_delivery_header-tytxt = '회수'.
    WHEN 'E'.
      gs_delivery_header-tytxt = '교환'.
    WHEN OTHERS.
      CLEAR gs_delivery_header-tytxt.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_cell_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cell_color .

  DATA: ls_color TYPE lvc_s_scol.

  CLEAR gs_delivery_header-cell_color.

  IF gs_delivery_header-wadat <> gs_delivery_header-wsdat.
    CLEAR ls_color.
    ls_color-fname      = 'WADAT'.
    ls_color-color-col  = 3.
    ls_color-color-int  = 0.
    ls_color-color-inv  = 0.
    APPEND ls_color TO gs_delivery_header-cell_color.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_alv_data_0110
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_data_0200 .

  LOOP AT gt_delivery_item INTO gs_delivery_item.

    " 세액 세팅
    PERFORM set_taxpr.

    " 금액, 할인액 계산
    PERFORM set_ord_and_dis_pr.

    MODIFY gt_delivery_item FROM gs_delivery_item.

  ENDLOOP.

  " 청구일자 세팅
  PERFORM set_gv_bldat.

  " 판매오더번호 세팅
  PERFORM set_gv_vbeln_so.

  " 총 금액 세팅
  PERFORM set_gv_tot_gross.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_bldat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_bldat .

  gv_bldat = sy-datum.
  " move_corresponding할 때 값이 안들어옴
  gs_delivery_header-fkdat = gv_bldat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_retxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_retxt .

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_REGIO'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = ztd3sd0001-regio.

  gv_retxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_kdtxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_kdtxt .

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_KDGRP'   " 예: ZREGION
      text      = 'X'          " Description 같이 가져오기
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = ztd3sd0001-kdgrp.

  gv_kdtxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_latxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_latxt .

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_REGIO'   " 예: ZREGION
      text      = 'X'          " Description 같이 가져오기
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.



  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = ztd3sd0001-land1.

  gv_latxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_lfdat_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_lfdat_0100.

  CLEAR gv_lf_from.
  CLEAR gv_lf_to.

  " 둘다 줬을 때
  IF gv_lfdat_from IS NOT INITIAL AND gv_lfdat_to IS NOT INITIAL.
    gv_lf_from = gv_lfdat_from.
    gv_lf_to   = gv_lfdat_to.
  ENDIF.


  " 납기 종료 일자에만 값 입력했을 때
  IF gv_lfdat_from IS INITIAL AND gv_lfdat_to IS NOT INITIAL.

    " 제일 먼저의 납기일자
    SELECT SINGLE MIN( edatu )
      FROM ztd3sd0006
      INTO @gv_lf_from.

    gv_lf_to = gv_lfdat_to.

  ENDIF.

  " 납기 시작 일자에만 값 입력했을 떄
  IF gv_lfdat_from IS NOT INITIAL AND gv_lfdat_to IS INITIAL.

    gv_lf_from = gv_lfdat_from.
    gv_lf_to = gv_lfdat_from.
  ENDIF.

  " 공백일 때
  IF gv_lfdat_from IS INITIAL AND gv_lfdat_to IS INITIAL.

    " 제일 먼저의 판매오더 번호
    SELECT SINGLE MIN( edatu )
      FROM ztd3sd0006
      INTO @gv_lf_from.

    " 제일 나중의 판매오더 번호
    SELECT SINGLE MAX( edatu )
      FROM ztd3sd0006
      INTO @gv_lf_to.

  ENDIF.






ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_search_opt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_search_opt .

  gv_bukrs = 1000.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form create_object_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0200 .

  go_container2 = NEW cl_gui_custom_container( 'CCON2' ).

  go_alv_grid2  = NEW cl_gui_alv_grid( go_container2 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_0200 .

  "gs_layout2-cwidth_opt = abap_on. " 컬럼 넓이 최적화
  gs_layout2-zebra = abap_on.      " 얼룩 무늬
  gs_layout2-totals_bef = abap_true. " 합계행 위로
  gs_layout2-sel_mode = 'A'.
  gs_layout-no_rowmark = space. " 왼쪽 행 선택 마커 표시
  gs_layout-sel_mode = 'A'.
  gs_layout-zebra = abap_on.      " 얼룩 무늬


  gs_variant2-report = sy-cprog.
  gv_save2 = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0200 .




  DEFINE _set_fieldcat.
    CLEAR gs_fieldcat.
    gs_fieldcat-key         = &1.
    gs_fieldcat-hotspot     = &2.
    gs_fieldcat-fieldname   = &3.
    gs_fieldcat-coltext     = &4.
    gs_fieldcat-cfieldname  = &5.
    gs_fieldcat-qfieldname  = &6.
    gs_fieldcat-outputlen   = &7.

    APPEND gs_fieldcat TO gt_fieldcat2.

  END-OF-DEFINITION.

  REFRESH gt_fieldcat2.

  "               key hotspot fieldname   coltext             cfieldname  dfieldname    outputlen

  _set_fieldcat 'X'   'X'     'VBELN'    '판매오더 번호'         ''              ''            10.
  _set_fieldcat 'X'   ''     'POSNR'    '판매오더 아이템 번호'     ''              ''           13.
  _set_fieldcat ''    ''      'KUNNR'    '고객코드'             ''              ''            6.
  _set_fieldcat ''    ''      'KUNNM'    '고객명'             ''              ''             20.
  _set_fieldcat ''    ''      'VKORG'    '영업조직'             ''              ''            5.
  _set_fieldcat ''    ''      'ORDPR'    '금액'              'WAERS'          ''           12.
  _set_fieldcat ''    ''      'DISPR'    '할인액'              'WAERS'          ''           12.
  _set_fieldcat ''    ''      'NETWR'    '공급가액'              'WAERS'          ''           12.
  _set_fieldcat ''    ''      'TAXPR'    '세액'               'WAERS'          ''           12.
  _set_fieldcat ''    ''      'GROSS'    '총액'               'WAERS'          ''           12.
  _set_fieldcat ''    ''      'WAERS'    '통화코드'             ''               ''           5.
  _set_fieldcat ''    ''      'MWSKZ'    '세금코드'             ''               ''           5.
  _set_fieldcat ''    ''      'ZTERM'    '지급조건'             ''               ''           5.
  _set_fieldcat ''    ''      'MATNR'    '자재코드'             ''               ''           11.
  _set_fieldcat ''    ''      'MATNM'    '자재명'              ''               ''           20.
  _set_fieldcat ''    ''      'KWMENG'   '청구 수량'            ''               'MEINS'      7.
  _set_fieldcat ''    ''      'KWMENG'   '출고 수량'            ''               'MEINS'      7.
  _set_fieldcat ''    ''      'MEINS'    '수량 단위'            ''               ''           5.
  _set_fieldcat ''    ''      'NETPR'    '기준 단가'            'WAERS'          ''           10.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_alv_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_0200 .

  go_alv_grid2->set_table_for_first_display(
    EXPORTING
*      i_buffer_active               =                  " Buffering Active
*      i_bypassing_buffer            =                  " Switch Off Buffer
*      i_consistency_check           =                  " Starting Consistency Check for Interface Error Recognition
*      i_structure_name              =                  " Internal Output Table Structure Name
      is_variant                    = gs_variant2                 " Layout
      i_save                        = gv_save2                 " Save Layout
*      i_default                     = 'X'              " Default Display Variant
      is_layout                     = gs_layout2                 " Layout
*      is_print                      =                  " Print Control
*      it_special_groups             =                  " Field Groups
*      it_toolbar_excluding          =                  " Excluded Toolbar Standard Functions
*      it_hyperlink                  =                  " Hyperlinks
*      it_alv_graphics               =                  " Table of Structure DTC_S_TC
*      it_except_qinfo               =                  " Table for Exception Quickinfo
*      ir_salv_adapter               =                  " Internal Usage only !!! - obsolete
    CHANGING
      it_outtab                     = gt_display2                 " Output Table
      it_fieldcatalog               = gt_fieldcat2                 " Field Catalog
*      it_sort                       =                  " Sort Criteria
*      it_filter                     =                  " Filter Criteria
*    EXCEPTIONS
*      invalid_parameter_combination = 1                " Wrong Parameter
*      program_error                 = 2                " Program Errors
*      too_many_lines                = 3                " Too many Rows in Ready for Input Grid
*      others                        = 4
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_alv_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv_0200 .

  go_alv_grid2->refresh_table_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_to_gt_display2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_to_gt_display2 .

  MOVE-CORRESPONDING gt_delivery_item TO gt_display2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_delivery_item_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_delivery_item_data .

  " 관련 참조오더 번호를 delivery_item에 넣어준다
  PERFORM select_from_so.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_exist_billing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_billing_header .

  " 대금청구 테이블에 해당 배송오더 번호가 있는지 확인
  CLEAR gv_dlrno.
  CLEAR gv_vbeln.


  " 대금청구에 해당하는 대금청구 번호가 있는지 조회
  SELECT SINGLE dlrno FROM ztd3sd0010
   WHERE dlrno EQ @gs_display1-dlrno
    INTO @gv_dlrno.


  CHECK gv_dlrno IS INITIAL.
  " 없다면 number range로 대금청구 번호 생성
  PERFORM get_number_range_billing.
  " 없다면 대금 청구 이력이 없는 배송오더이므로, 대금 청구 헤더에 데이터 추가
  PERFORM create_bill_header.






ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sort_status .

  CASE gs_delivery_header-status.
    WHEN icon_led_red.
      gs_delivery_header-sta_sort = 1.
    WHEN icon_led_green.
      gs_delivery_header-sta_sort = 2.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_fkdat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fkdat .
  " 대금청구 완료인 건에 대해서만 진행한다
  CHECK gs_delivery_header-status = icon_led_green.

  CLEAR gs_bill_header_end.

  READ TABLE gt_bill_header_end INTO gs_bill_header_end
       WITH KEY vbeln_so = gs_delivery_header-vbeln_so.


  gs_delivery_header-fkdat = gs_bill_header_end-fkdat.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_number_range_billing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_number_range_billing.

  DATA lv_number TYPE n LENGTH 8.
  DATA lv_return_code.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'                 " Number range number
      object                  = 'ZNRD3SD10'                 " Name of number range object
    IMPORTING
      number                  = lv_number
    EXCEPTIONS
      interval_not_found      = 1                " Interval not found
      number_range_not_intern = 2                " Number range is not internal
      object_not_found        = 3                " Object not defined in TNRO
      quantity_is_0           = 4                " Number of numbers requested must be > 0
      quantity_is_not_1       = 5                " Number of numbers requested must be 1
      interval_overflow       = 6                " Interval used up. Change not possible.
      buffer_overflow         = 7                " Buffer is full
      OTHERS                  = 8.

  CASE sy-subrc.
    WHEN 0.
      " 정상
    WHEN 1.
      " 031: &1 Number Range 의 번호가 소진되어 채번할 수 없습니다.
      MESSAGE i031(zpd3_msg) DISPLAY LIKE 'E'.
      RETURN.
    WHEN OTHERS.
      " 032: &1 Number Range 를 이용한 채번에 실패하였습니다.
      MESSAGE i032(zpd3_msg) DISPLAY LIKE 'E'.
      RETURN.
  ENDCASE.

  CASE lv_return_code.
    WHEN 0.
      " 정상
    WHEN 2.
      " 033: &1 Number Range 의 마지막 번호가 발급되었습니다.
      MESSAGE i033(zpd3_msg) DISPLAY LIKE 'W'.
    WHEN 3.
      " 034: &1 Number Range 의 남은 번호가 10% 이하입니다.
      MESSAGE i034(zpd3_msg) DISPLAY LIKE 'W'.
    WHEN OTHERS.
      " 035: &1 Number Range 의 남은 번호를 확인해 주세요.
      MESSAGE i035(zpd3_msg) DISPLAY LIKE 'W'.
  ENDCASE.

  gv_vbeln = |BO{ lv_number }|.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_bill_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_DLRNO
*&---------------------------------------------------------------------*
FORM create_bill_header.

  " billing header에 넣을 데이터
  PERFORM insert_bill_header.


  " 생성 이력 저장을 위한 로직
  PERFORM insert_create_log.


  APPEND gs_bill_header TO gt_bill_header_end.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_create_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_create_log .



  gs_bill_header-erdat = sy-datum.  " 생성 날짜
  gs_bill_header-erzzt = sy-uzeit.  " 생성 시간
  gs_bill_header-ernam = sy-uname.  " 생성자



  gs_bill_header-vbstat = 'A'.      " 세금계산서 발행 전


  " 대금청구번호를 가져오기 위한 로직
  SELECT SINGLE dlrno
    FROM ztd3sd0008
   WHERE vbeln EQ @gs_delivery_item-vbeln
    INTO @gs_bill_header-dlrno.

  gs_bill_header-vbeln = gv_VBELN.  " 대금청구번호







ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_billing_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_billing_item .

  " 부여할 대금청구 아이템 번호
  DATA : lv_next_posnr TYPE ztd3sd0011-posnr.
  " 이전에 부여한 대금청구 아이템 번호
  DATA : lv_max_posnr TYPE ztd3sd0011-posnr.

  " 해당 데이터를 지정하지 않으면 lv_max_posnr에 0000000010 식으로 지정되어 값 비교가 되지 않는다
  DATA : lv_max_posnr_i  TYPE i,
         lv_next_posnr_i TYPE i.




  CLEAR lv_next_posnr.
  CLEAR lv_max_posnr.
  CLEAR gs_bill_item.


  LOOP AT gt_delivery_item INTO gs_delivery_item.


    " 대금청구 아이템 번호를 10단위로 가져온다
    IF lv_max_posnr IS INITIAL.
      lv_next_posnr = '0010'.
    ELSE.
      lv_max_posnr_i  = lv_max_posnr.
      lv_next_posnr_i = lv_max_posnr_i + 10.
      lv_next_posnr   = |{ lv_next_posnr_i WIDTH = 4  ALIGN = RIGHT PAD = '0' }|.
    ENDIF.

    lv_max_posnr = lv_next_posnr.


    MOVE-CORRESPONDING gs_delivery_item TO gs_bill_item.

    " 서로 다른 목적의 아이템번호가 동일한 필드명으로 인해 겹쳐 엉뚱한 곳에 데이터가 꽂혔다
    " 이를 해결하기 위해 맞는 데이터로 데이터 형식을 덮어씌운다.
    gs_bill_item-posnr = lv_next_posnr.

    gs_bill_item-vbeln = gv_VBELN.        " 대금청구 번호


    " 청구 수량
    gs_bill_item-fkimg = gs_delivery_item-kwmeng.

    " 수량 단위
    gs_bill_item-vrkme = gs_delivery_item-meins.



    gs_bill_item-erdat = sy-datum.  " 생성 날짜
    gs_bill_item-erzzt = sy-uzeit.  " 생성 시간
    gs_bill_item-ernam = sy-uname.  " 생성자


    APPEND gs_bill_item TO gt_bill_item.


  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form move_billing_header_netwr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_billing_header_netwr .

  CLEAR gs_bill_header-netwr.
  CLEAR gs_bill_header-gross.


  " 헤더에서 못채웠던 순금액을 sum을 통해 다시 채운다
  LOOP AT gt_delivery_item INTO gs_delivery_item.
    gs_bill_header-netwr += gs_delivery_item-netwr.
    gs_bill_header-gross += gs_delivery_item-gross.
  ENDLOOP.


  APPEND gs_bill_header TO gt_bill_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_description_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_description_0200 .
  " 지금조건 Fixed Value의 Description을 가져오는 로직
  PERFORM set_gv_zttxt.

  " 지역코드 Fixed Value의 Description을 가져오는 로직
  PERFORM set_gv_retxt.

  " 고객유형 Fixed Value의 Description을 가져오는 로직
  PERFORM set_gv_kdtxt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_from_so_do
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_from_so.


  REFRESH gt_delivery_item.


  SELECT a~vbeln,
         b~posnr,
         a~kunnr,
         f~butxt AS kunnm,
         a~vkorg,
         b~netwr,
         b~gross,
         a~waers,
         a~zterm,
         b~matnr,
         e~maktx AS matnm,
         b~mwskz,
         b~kwmeng,
         b~meins,
         b~netpr
FROM ztd3sd0006 AS a
INNER JOIN ztd3sd0007 AS b
  ON a~vbeln = b~vbeln
INNER JOIN ztd3mm0001 AS e
  ON b~matnr = e~matnr
INNER JOIN ztd3sd0001 AS f
  ON a~kunnr = f~kunnr
   WHERE a~vbeln = @gs_display1-vbeln_so
    INTO CORRESPONDING FIELDS OF TABLE @gt_delivery_item.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_handler_event_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_handler_event_0200 .

  SET HANDLER lcl_event_handler=>on_hotspot_click FOR go_alv_grid2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_tot_gross
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_tot_gross .

  CLEAR gv_tot_gross.

  LOOP AT gt_delivery_item INTO gs_delivery_item.

    gv_tot_gross += gs_delivery_item-gross.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_redat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_redat .

  CHECK gs_delivery_header-fkdat IS NOT INITIAL.

  " 지급조건이 1이면 대금 청구한 당일에 입금
  IF gs_delivery_header-zterm EQ '0001'.

    gs_delivery_header-re_date = gs_delivery_header-fkdat.

    " 지급조건이 2이면 대금청구한 7일 뒤에 입금
  ELSEIF gs_delivery_header-zterm EQ '0002'.

    gs_delivery_header-re_date = gs_delivery_header-fkdat + 7.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_from_do
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_from_do .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_burks
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_bukrs .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_data_0200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_data_0200 .

  "   MOVE-CORRESPONDING gt_delivery_header to gt_delivery_item.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_price_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_price_change .

  CLEAR gv_price_change.

  DATA : lv_price TYPE ztd3sd0014-kbetr.

  DATA : ls_price TYPE ztd3sd0014.

  LOOP AT gt_delivery_item INTO gs_delivery_item.

    SELECT SINGLE *
      FROM ztd3sd0014
     WHERE matnr EQ @gs_delivery_item-matnr
      INTO @ls_price.

    " 단가 계산
    lv_price = gs_delivery_item-netwr / gs_delivery_item-kwmeng.



    IF ls_price-kbetr NE lv_price.

      gv_price_change = abap_on.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OK_CODE
*&      --> GV_OK
*&---------------------------------------------------------------------*
FORM popup_to_confirm  USING    pv_ok_code TYPE sy-ucomm
                                pv_ok      TYPE bool.

  CHECK gv_not_initail IS NOT INITIAL.

  DATA: lv_title    TYPE string,
        lv_question TYPE string,
        lv_answer   TYPE c.



  CLEAR pv_ok.

  CASE pv_ok_code.

    WHEN 'BT1'.
      lv_title     = '검색조건 초기화'.
      lv_question  = '검색조건이 초기화됩니다. 실행하시겠습니까?'.

    WHEN 'CRE_BILL'.
      IF gv_price_change IS NOT INITIAL.
        lv_title    = '가격 변동 확인'.
        lv_question = '청구 과정에서 해당 제품에 대한 가격이 변동되었습니다. '.
      ELSE.
        lv_title    = '청구 확인'.
        lv_question = '청구 하시겠습니까?'.
      ENDIF.
    WHEN 'SAVE'.
      lv_title    = '저장 확인'.
      lv_question = '저장하시겠습니까? '.
    WHEN 'REFRESH'.
      lv_title    = '화면 초기화 확인'.
      lv_question = '화면이 초기화 됩니다. 실행 하시겠습니까?'.
    WHEN 'BACK'.
      lv_title    = '나가기'.
      lv_question = '저장되지 않은 대금청구 건이 있습니다. 저장하지 않고 나가시겠습니까?'.


  ENDCASE.


  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = lv_title
      text_question         = lv_question
      text_button_1         = '확인'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '취소'
      icon_button_2         = 'ICON_CANCEL'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    EXIT.
  ENDIF.

  " 확인 버튼을 누르면 진행하기 위해 세팅
  pv_ok = abap_true.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_bill
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_bill .

  " 팝업 확인을 눌렀을 때 실행
  CHECK gv_ok IS NOT INITIAL.

  " 저장할 데이터가 있을 때 실행(팝업을 위해)
  CHECK gv_not_initail IS NOT INITIAL.

  " 저장할 데이터가 있을 때 실행(저장을 위해)
  CHECK gv_save_bool IS NOT INITIAL.

  CLEAR gv_save_bool.
  CLEAR gv_ok.


  " 대금청구 헤더 저장
  INSERT ztd3sd0010 FROM TABLE @gt_bill_header.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    " 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'A'.
    EXIT.
  ENDIF.

  " 대금청구 아이템 저장
  INSERT ztd3sd0011 FROM TABLE @gt_bill_item.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    " 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'A'.
    EXIT.
  ENDIF.

  " 전표 생성 로직
  PERFORM set_statement.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    " 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'A'.
    EXIT.
  ENDIF.

  " 세금계산서 전표번호 세팅
  PERFORM set_gt_tax_belnr.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    " 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'A'.
    EXIT.
  ENDIF.

  " 세금계산서 헤더 저장
  INSERT ztd3fi0013 FROM TABLE @gt_tax_header.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    " 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'A'.
    EXIT.
  ENDIF.

  " 세금계산서 아이템 저장
  INSERT ztd3fi0014 FROM TABLE @gt_tax_item.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    " 저장에 실패하였습니다.
    MESSAGE s025 DISPLAY LIKE 'A'.
    EXIT.
  ENDIF.

  COMMIT WORK.

  MESSAGE s023. " 저장되었습니다.



  " 저장 버튼을 누른 후, 여러 번 누르는 것을 막기 위한 클리어
  REFRESH gt_statement.
  REFRESH gt_bill_header.
  REFRESH gt_bill_item.
  REFRESH gt_tax_header.
  REFRESH gt_tax_item.


  " 다시 데이터 재조회 하기 위해
  CLEAR gv_start.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form currency_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_AMOUNT_DISPLAY
*&      --> LV_AMOUNT
*&---------------------------------------------------------------------*

TYPES ty_amount TYPE p LENGTH 8 DECIMALS 4.

FORM currency_change  USING      pv_amount_display TYPE ty_amount
                      CHANGING   pv_amount         TYPE ty_amount.

  CALL FUNCTION 'CURRENCY_AMOUNT_DISPLAY_TO_SAP'
    EXPORTING
      currency        = gs_delivery_item-waers                 " Currency indicator
      amount_display  = pv_amount_display                      " DE-EN-LANG-SWITCH-NO-TRANSLATION
    IMPORTING
      amount_internal = pv_amount                              " Internal Format
    EXCEPTIONS
      internal_error  = 1                " DE-EN-LANG-SWITCH-NO-TRANSLATION
      OTHERS          = 2.
  IF sy-subrc <> 0.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_bill_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_bill_header .

  READ TABLE gt_delivery_header INTO gs_delivery_header
  WITH KEY vbeln_so = gs_delivery_item-vbeln.

  gs_bill_header-bukrs    = gs_delivery_header-bukrs.
  gs_bill_header-kunnr    = gs_delivery_header-kunnr.
  gs_bill_header-vbeln_so = gs_delivery_header-vbeln.
  gs_bill_header-fkdat    = gs_delivery_header-fkdat.
  gs_bill_header-re_date  = gs_delivery_header-re_date.
  gs_bill_header-vkorg    = gs_delivery_header-vkorg.
  gs_bill_header-waers    = gs_delivery_header-waers.
  gs_bill_header-zterm    = gs_delivery_header-zterm.
  gs_bill_header-vbeln_so = gs_delivery_header-vbeln_so.

  " 청구 날짜
  gs_bill_header-fkdat    = sy-datum.

  " 수금 날짜
  IF gs_bill_header-zterm EQ '0001'.
    gs_bill_header-re_date = gs_bill_header-fkdat.
  ELSE.

    DATA : lv_work_date TYPE ztd3sd0010-re_date.

    " 영업일 기준 7일 후로 대금 지급 날짜 가져오기
    PERFORM set_zterm_working_date USING lv_work_date.

    gs_bill_header-re_date = lv_work_date.

  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_bill_header_end
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_bill_header_end .

  SELECT * FROM ztd3sd0010
    INTO TABLE @gt_bill_header_end.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_zterm_working_date
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_BILL_HEADER_RE_DATE
*&---------------------------------------------------------------------*
FORM set_zterm_working_date  CHANGING  pv_work_date TYPE ztd3sd0010-re_date.

  DATA: lv_base_date TYPE sy-datum,
        lv_lead_time TYPE i,
        lv_ret_code  TYPE sy-subrc.

  pv_work_date = sy-datum.
  lv_lead_time = 7.

  " 펑션 모듈 호출
  CALL FUNCTION 'BKK_ADD_WORKINGDAY'
    EXPORTING
      i_date      = pv_work_date  " 기준 날짜
      i_days      = lv_lead_time  " 더할 영업일 수
      i_calendar1 = 'KR'          " 팩토리 캘린더 (대한민국)
    IMPORTING
      e_date      = pv_work_date     " 계산된 날짜
      e_return    = lv_ret_code.  " 결과 코드 (0: 성공, 4: 실패)

  " 결과 판정 및 처리
  IF lv_ret_code = 0 AND pv_work_date IS NOT INITIAL.
  ELSE.
    " 실패 시 Fallback 로직 (단순 날짜 더하기)
    pv_work_date = lv_base_date + lv_lead_time.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_sh_kunnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_sh_kunnr .

*  DATA: ls_shlp   TYPE shlp_descr,
*        lt_return TYPE TABLE OF ddshretval,
*        ls_return TYPE ddshretval,
*        ls_iface  TYPE ddshiface,
*        lt_dynp   TYPE TABLE OF dynpread,
*        ls_dynp   TYPE dynpread.
*
*  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
*    EXPORTING
*      shlpname = 'ZSHD3SD0001'
*      shlptype = 'SH'
*    IMPORTING
*      shlp     = ls_shlp.
*
*  LOOP AT ls_shlp-interface INTO ls_iface.
*    CASE ls_iface-shlpfield.
*      WHEN 'KUNNR' OR 'BUTXT' OR 'REPNM'.
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
*  CLEAR: gv_kunnr_from, gv_kunnr_to, gv_butxt, gv_repnm.
*
*  LOOP AT lt_return INTO ls_return.
*    CASE ls_return-fieldname.
*      WHEN 'KUNNR'.
*        gv_kunnr = ls_return-fieldval.
*      WHEN 'BUTXT'.
*        gv_butxt = ls_return-fieldval.
*      WHEN 'REPNM'.
*        gv_repnm = ls_return-fieldval.
*    ENDCASE.
*  ENDLOOP.
*
*
*  CLEAR lt_dynp.
*  ls_dynp-fieldname  = 'GV_KUNNR'.
*  ls_dynp-fieldvalue = gv_kunnr.
*  APPEND ls_dynp TO lt_dynp.
*
*  CLEAR ls_dynp.
*  ls_dynp-fieldname  = 'GV_BUTXT'.
*  ls_dynp-fieldvalue = gv_butxt.
*  APPEND ls_dynp TO lt_dynp.
*
*  CLEAR ls_dynp.
*  ls_dynp-fieldname  = 'GV_REPNM'.
*  ls_dynp-fieldvalue = gv_repnm.
*  APPEND ls_dynp TO lt_dynp.
*
*  CALL FUNCTION 'DYNP_VALUES_UPDATE'
*    EXPORTING
*      dyname     = sy-repid
*      dynumb     = sy-dynnr
*    TABLES
*      dynpfields = lt_dynp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form see_billing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM see_billing .

  DATA: lt_rows TYPE lvc_t_row,
        ls_row  TYPE lvc_s_row.

  CLEAR gs_display1.

  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.



  IF lines( lt_rows ) GT 1.
    " 데이터를 1건만 선택해 주세요
    MESSAGE s079 DISPLAY LIKE 'W'.
    RETURN.
  ELSEIF lines( lt_rows ) EQ 0.
    " 데이터를 선택해 주세요
    MESSAGE s080 DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  READ TABLE lt_rows INTO ls_row INDEX 1.

  READ TABLE gt_display1 INTO gs_display1 INDEX ls_row-index.

  IF gs_display1-vbeln IS INITIAL.
    " 아직 청구되지 않은 건입니다.
    MESSAGE s086 DISPLAY LIKE 'A'.
    RETURN.
  ENDIF.


  SUBMIT zrd3sd0010
    WITH so_vb        = gs_display1-vbeln
    WITH so_vb-sign   = 'I'
    WITH so_vb-option = 'EQ'
    WITH pa_auto   = abap_true
     AND RETURN.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_taxpr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_taxpr .

  IF gs_delivery_item-mwskz EQ 'A1'.
    gs_delivery_item-taxpr = ( gs_delivery_item-netpr * 10 / 100 ) * gs_delivery_item-kwmeng.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_statement
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_statement .
  DATA : lv_num TYPE string.


  " 여러 건 청구할 경우를 생각하기
  LOOP AT gt_statement INTO gs_statement.

    CALL FUNCTION 'ZFD3FI0005'
      EXPORTING
        iv_bukrs = gs_statement-bukrs      " 회사코드
        iv_budat = gs_statement-budat      " 전기일
        iv_bldat = gs_statement-bldat      " 증빙일
        iv_kunnr = gs_statement-kunnr      " 고객코드
        iv_wrbtr = gs_statement-wrbtr      " 총액(고객에게 청구할 금액)
        iv_waers = gs_statement-waers      " 통화코드
        iv_mwskz = gs_statement-mwskz      " 세금코드(A1-매출부가세 10%)
        iv_zterm = gs_statement-zterm      " 지급조건
        iv_vbeln = gs_statement-vbeln    " 판매오더번호
      IMPORTING
        "ev_belnr =                           " 전표번호
        ev_msg   = lv_num.                   " 전표 생성 결과 전달.

  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_statement
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_statement .

  CLEAR gs_statement.

  MOVE-CORRESPONDING gs_delivery_item TO gs_statement.

  gs_statement-bukrs = gv_bukrs.
  gs_statement-budat = sy-datum.
  gs_statement-bldat = sy-datum.
  gs_statement-wrbtr = gv_tot_gross.

  APPEND gs_statement TO gt_statement.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_gt_initial
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_gt_initial .

  CHECK gt_statement   IS INITIAL
    AND gt_bill_header IS INITIAL
    AND gt_bill_item   IS INITIAL.

  gv_not_initail = abap_false.


  " 저장할 데이터가 없습니다.
  MESSAGE s101 DISPLAY LIKE 'W'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_vbeln_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_vbeln_so .

  gv_vbeln_so = gs_delivery_header-vbeln_so.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_tax
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_tax .

  " 세금 헤더 테이블에 판매오더 번호가 이미 있는지 확인
  " 없는거면 미청구된 건
  PERFORM create_tax_header.


  " 대금청구 ITAB에 데이터를 옮기기 위한 로직
  " 대금청구 헤더
  " 대금청구 아이템
  PERFORM create_tax_item.

  " 아이템 테이블에서 생긴 금액 총계를 헤더에 옮기기 위한 로직
  PERFORM move_tax_header.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_tax_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_tax_header .

  CLEAR gs_tax_header.

  SELECT SINGLE *
    FROM ztd3fi0013
   WHERE vbeln EQ @gs_display1-vbeln_so
    INTO @gs_tax_header.


  CHECK gs_tax_header IS INITIAL.

  " 없다면 number range로 세금계산서 헤더 번호 생성
  PERFORM get_number_range_tax.
  " 없다면 세금계산서 발행 이력이 없는 판매오더이므로, 세금계산서 헤더에 데이터 추가
  PERFORM create_gs_tax_header.
  "로그 저장
  PERFORM create_gs_tax_log.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_number_range_tax
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_number_range_tax .

  DATA lv_number TYPE n LENGTH 8.
  DATA lv_return_code.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'                 " Number range number
      object                  = 'ZNRD3FI13'                 " Name of number range object
    IMPORTING
      number                  = lv_number
    EXCEPTIONS
      interval_not_found      = 1                " Interval not found
      number_range_not_intern = 2                " Number range is not internal
      object_not_found        = 3                " Object not defined in TNRO
      quantity_is_0           = 4                " Number of numbers requested must be > 0
      quantity_is_not_1       = 5                " Number of numbers requested must be 1
      interval_overflow       = 6                " Interval used up. Change not possible.
      buffer_overflow         = 7                " Buffer is full
      OTHERS                  = 8.

  CASE sy-subrc.
    WHEN 0.
      " 정상
    WHEN 1.
      " 031: &1 Number Range 의 번호가 소진되어 채번할 수 없습니다.
      MESSAGE i031(zpd3_msg) DISPLAY LIKE 'E'.
      RETURN.
    WHEN OTHERS.
      " 032: &1 Number Range 를 이용한 채번에 실패하였습니다.
      MESSAGE i032(zpd3_msg) DISPLAY LIKE 'E'.
      RETURN.
  ENDCASE.

  CASE lv_return_code.
    WHEN 0.
      " 정상
    WHEN 2.
      " 033: &1 Number Range 의 마지막 번호가 발급되었습니다.
      MESSAGE i033(zpd3_msg) DISPLAY LIKE 'W'.
    WHEN 3.
      " 034: &1 Number Range 의 남은 번호가 10% 이하입니다.
      MESSAGE i034(zpd3_msg) DISPLAY LIKE 'W'.
    WHEN OTHERS.
      " 035: &1 Number Range 의 남은 번호를 확인해 주세요.
      MESSAGE i035(zpd3_msg) DISPLAY LIKE 'W'.
  ENDCASE.

  gs_tax_header-exnum = |TX{ lv_number }|.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_gs_tax_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_gs_tax_header .

  gs_tax_header-bukrs = gs_bill_header-bukrs.
  gs_tax_header-kunnr = gs_bill_header-kunnr.
  "gs_tax_header-belnr = gs_statement-.
  gs_tax_header-vbeln = gs_bill_header-vbeln_so.
  gs_tax_header-gjahr = sy-datum(4).
  gs_tax_header-bldat = sy-datum.
  gs_tax_header-waers = 'KRW'.
  "gs_tax_header-TOTAL_AMT = .
  "gs_tax_header-VAT_AMT = .
  gs_tax_header-exstat = 'D'.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_tax_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_tax_item .

  " 부여할 세금계산서 아이템 번호
  DATA : lv_next_posnr TYPE ztd3sd0011-posnr.
  " 이전에 부여한 세금계산서 아이템 번호
  DATA : lv_max_posnr TYPE ztd3sd0011-posnr.

  " 해당 데이터를 지정하지 않으면 lv_max_posnr에 0000000010 식으로 지정되어 값 비교가 되지 않는다
  DATA : lv_max_posnr_i  TYPE i,
         lv_next_posnr_i TYPE i.




  CLEAR lv_next_posnr.
  CLEAR lv_max_posnr.
  CLEAR gs_tax_item.
  CLEAR gs_bill_item.

  LOOP AT gt_delivery_item INTO gs_delivery_item.

    " 대금청구 아이템 번호를 10단위로 가져온다
    IF lv_max_posnr IS INITIAL.
      lv_next_posnr = '0010'.
    ELSE.
      lv_max_posnr_i  = lv_max_posnr.
      lv_next_posnr_i = lv_max_posnr_i + 10.
      lv_next_posnr   = |{ lv_next_posnr_i WIDTH = 4  ALIGN = RIGHT PAD = '0' }|.
    ENDIF.

    lv_max_posnr = lv_next_posnr.

    gs_tax_item-exnum = gs_tax_header-exnum.        " 세금계산서 번호
    gs_tax_item-buzei = lv_next_posnr.              " 세금계산서 item 번호
    gs_tax_item-matnr = gs_delivery_item-matnr.     " 자재 코드
    gs_tax_item-maktx = gs_delivery_item-matnm.     " 자재명
    gs_tax_item-menge = gs_delivery_item-kwmeng.    " 수량
    gs_tax_item-meins = gs_delivery_item-meins.     " 단위
    gs_tax_item-hwbas = gs_delivery_item-netwr.     " 공급가액
    gs_tax_item-mwsts = gs_delivery_item-taxpr.     " 세액
    gs_tax_item-taxcd = gs_delivery_item-mwskz.     " 세금코드
    gs_tax_item-erdat = sy-datum.
    gs_tax_item-ernam = sy-uname.
    gs_tax_item-erzzt = sy-uzeit.


    APPEND gs_tax_item TO gt_tax_item.


  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_tax_header
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_tax_header .

  CLEAR gs_tax_header-total_amt.
  CLEAR gs_tax_header-vat_amt.
  CLEAR gs_tax_item.

  LOOP AT gt_tax_item INTO gs_tax_item.

    IF gs_tax_header-exnum EQ gs_tax_item-exnum.

      gs_tax_header-total_amt += gs_tax_item-hwbas.
      gs_tax_header-vat_amt   += gs_tax_item-mwsts.

    ELSE.
      CONTINUE.
    ENDIF.


  ENDLOOP.

  APPEND gs_tax_header TO gt_tax_header.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_gs_tax_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_gs_tax_log .

  gs_tax_header-erdat = sy-datum.
  gs_tax_header-ernam = sy-uname.
  gs_tax_header-erzzt = sy-uzeit.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gt_tax_belnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gt_tax_belnr .

  DATA : lv_belnr TYPE ztd3fi0004-belnr.

  CLEAR gs_statement.

  READ TABLE gt_statement INTO gs_statement
    WITH KEY vbeln = gs_bill_header-vbeln_so.


  CLEAR gs_tax_header.

  LOOP AT gt_tax_header INTO gs_tax_header.

    CLEAR lv_belnr.

    SELECT SINGLE belnr
      FROM ztd3fi0004
     WHERE bschl EQ '1'
       AND vbeln EQ @gs_statement-vbeln
      INTO @lv_belnr.

    CLEAR gs_tax_header-belnr.

    gs_tax_header-belnr = lv_belnr.


    MODIFY gt_tax_header FROM gs_tax_header.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_change_bill_is_initial
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_change_bill_is_initial .

  READ TABLE gt_display1 INTO gs_display1
      WITH KEY status = icon_change_text.

  IF sy-subrc = 0.
    gv_no_save = abap_true.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OK_CODE
*&      --> GV_OK
*&---------------------------------------------------------------------*
FORM popup_to_confirm2  USING    pv_ok_code TYPE sy-ucomm
                                 pv_ok      TYPE bool.

  CHECK gv_not_initail IS NOT INITIAL.

  DATA: lv_title    TYPE string,
        lv_question TYPE string,
        lv_answer   TYPE c.



  CLEAR pv_ok.

  CASE pv_ok_code.

    WHEN 'CRE_BILL'.
      lv_title    = '[SD] 프로그램 이동'.
      lv_question = '대금청구 조회 프로그램으로 이동하시겠습니끼?'.
  ENDCASE.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = lv_title
      text_question         = lv_question
      text_button_1         = '확인'
      icon_button_1         = 'ICON_OKAY'
      text_button_2         = '취소'
      icon_button_2         = 'ICON_CANCEL'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    EXIT.
  ENDIF.

  " 확인 버튼을 누르면 진행하기 위해 세팅
  pv_ok = abap_true.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form move_zrd3sd0010
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM move_zrd3sd0010 .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_ord_and_dis_pr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ord_and_dis_pr .

  gs_delivery_item-ordpr = gs_delivery_item-netpr * gs_delivery_item-kwmeng.
  gs_delivery_item-dispr = gs_delivery_item-ordpr - gs_delivery_item-netwr.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_hotspot_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM handle_hotspot_click  USING    p_row_id    TYPE  lvc_s_row
                                    p_column_id TYPE  LVC_S_col.

  READ TABLE gt_display2 INTO gs_display2 INDEX p_row_id-index.

*     출력용 ITAB에서 선택한 행에 대한 정보를 찾지 못할 경우 중단한다.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

*     선택한 컬럼명의 필드명에 따라 로직을 구현한다.
  CASE p_column_id-fieldname.
    WHEN 'VBELN'. " 판매오더번호

      DATA lt_vbeln TYPE RANGE OF ztd3sd0006-vbeln.

      CLEAR lt_vbeln.

      APPEND VALUE #(
        sign   = 'I'
        option = 'EQ'
        low    = gs_display2-vbeln
      ) TO lt_vbeln.

      SUBMIT zrd3sd0005
        WITH s_vbeln IN lt_vbeln
         AND RETURN.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module SET_ALV_0202 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_alv_0202 OUTPUT.

  IF go_container3 IS INITIAL.
    PERFORM create_object_0202.

    PERFORM set_layout_0202.

    PERFORM set_fieldcat_0202.

    PERFORM display_alv_0202.
  ELSE.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form create_object_0202
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0202 .

  go_container3 = NEW cl_gui_custom_container( 'CCON3' ).

  go_alv_grid3 = NEW cl_gui_alv_grid( go_container3 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_0202
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_0202 .

  go_alv_grid3->set_table_for_first_display(
    EXPORTING
*      i_buffer_active               =                  " Buffering Active
*      i_bypassing_buffer            =                  " Switch Off Buffer
*      i_consistency_check           =                  " Starting Consistency Check for Interface Error Recognition
*      i_structure_name              =                  " Internal Output Table Structure Name
      is_variant                    = gs_variant3                 " Layout
      i_save                        = gv_save3                 " Save Layout
*      i_default                     = 'X'              " Default Display Variant
      is_layout                     = gs_layout3        " Layout
*      is_print                      =                  " Print Control
*      it_special_groups             =                  " Field Groups
*      it_toolbar_excluding          =                  " Excluded Toolbar Standard Functions
*      it_hyperlink                  =                  " Hyperlinks
*      it_alv_graphics               =                  " Table of Structure DTC_S_TC
*      it_except_qinfo               =                  " Table for Exception Quickinfo
*      ir_salv_adapter               =                  " Internal Usage only !!! - obsolete
    CHANGING
      it_outtab                     = gt_delivery       " Output Table
      it_fieldcatalog               = gt_fieldcat3      " Field Catalog
*      it_sort                       =                  " Sort Criteria
*      it_filter                     =                  " Filter Criteria
*    EXCEPTIONS
*      invalid_parameter_combination = 1                " Wrong Parameter
*      program_error                 = 2                " Program Errors
*      too_many_lines                = 3                " Too many Rows in Ready for Input Grid
*      others                        = 4
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_delivery_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_delivery_data .

  READ TABLE gt_display2 INTO gs_display2 INDEX 1.

  SELECT a~dlrno,
         a~vbeln,
         a~werks,
         b~matnr,
         a~type,
         a~wsdat,
         a~wadat,
         a~lfdat
    FROM ztd3sd0008 AS a
   INNER JOIN ztd3sd0009 AS b
      ON a~dlrno EQ b~dlrno
   WHERE vbeln EQ @gs_display2-vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_delivery.

  SORT gt_delivery BY vbeln.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_0202
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0202 .

  DEFINE _set_fieldcat.
    gs_fieldcat3-key       = &1.
    gs_fieldcat3-hotspot   = &2.
    gs_fieldcat3-fieldname = &3.
    gs_fieldcat3-coltext   = &4.
    gs_fieldcat3-cfieldname = &5.
    gs_fieldcat3-qfieldname = &6.
    gs_fieldcat3-outputlen = &7.
    APPEND gs_fieldcat3 TO gt_fieldcat3.
    CLEAR gs_fieldcat.
  END-OF-DEFINITION.

  _set_fieldcat 'X' '' 'DLRNO' '출고요청번호' '' '' 12.
  _set_fieldcat '' '' 'VBELN' '판매오더번호' '' '' 12.
  _set_fieldcat '' '' 'WERKS' '플랜트' '' '' 8.
  _set_fieldcat '' '' 'MATNR' '자재번호' '' '' 10.
  _set_fieldcat '' '' 'TYPE'  '출고유형' '' '' 6.
  _set_fieldcat '' '' 'WSDAT' '출고예정일' '' '' 10.
  _set_fieldcat '' '' 'WADAT' '실제출고일' '' '' 10.
  _set_fieldcat '' '' 'LFDAT' '납기일자' '' '' 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0202
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_0202 .

  gs_layout3-zebra = abap_on.      " 얼룩 무늬
  gs_layout3-totals_bef = abap_true. " 합계행 위로
  gs_layout3-sel_mode = 'A'.

  gs_variant3-report = sy-cprog.
  gv_save3 = 'A'.
  gs_variant3-handle = 'H1'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_icon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_icon .



  gv_icon1 = icon_led_green.
  gv_icon2 = icon_led_green.


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

  " 고객코드 조회 범위 세팅
  PERFORM set_kunnr_0100.

  " 판매오더 조회 범위 세팅
  PERFORM set_vbeln_0100.

  " 주문일자 조회 범위 세팅
  PERFORM set_audat_0100.

  " 납기일자 조회 범위 세팅
  PERFORM set_lfdat_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_vbeln_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_vbeln_0100 .

  CLEAR gv_vb_from.
  CLEAR gv_vb_to.

  IF gv_vbeln_from IS NOT INITIAL AND gv_vbeln_to IS NOT INITIAL.
    gv_vb_from = gv_vbeln_from.
    gv_vb_to = gv_vbeln_to.
  ENDIF.


  " 판매오더 종료 일자에만 값 입력했을 때
  IF gv_vbeln_from IS INITIAL AND gv_vbeln_to IS NOT INITIAL.

    " 제일 먼저의 판매오더 번호
    SELECT SINGLE MIN( vbeln )
      FROM ztd3sd0006
      INTO @gv_vb_from.

    gv_vb_to = gv_vbeln_to.

  ENDIF.

  " 판매오더 시작 일자에만 값 입력했을 떄
  IF gv_vbeln_from IS NOT INITIAL AND gv_vbeln_to IS INITIAL.

    gv_vb_to = gv_vbeln_from.
  ENDIF.

  IF gv_vbeln_from IS INITIAL AND gv_vbeln_to IS INITIAL.

    " 제일 먼저의 판매오더 번호
    SELECT SINGLE MIN( vbeln )
      FROM ztd3sd0006
      INTO @gv_vb_from.

    " 제일 나중의 판매오더 번호
    SELECT SINGLE MAX( vbeln )
      FROM ztd3sd0006
      INTO @gv_vb_to.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_kunnr_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_kunnr_0100 .

  IF gv_kunnr_from IS INITIAL.

    SELECT SINGLE MIN( kunnr )
      FROM ztd3sd0001
      INTO @gv_ku_from.

  ELSE.
    gv_ku_from = gv_kunnr_from.
  ENDIF.

  IF gv_kunnr_to IS INITIAL.

    SELECT SINGLE MAX( kunnr )
      FROM ztd3sd0001
      INTO @gv_ku_to.

  ELSE.
    gv_ku_to = gv_kunnr_to.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_audat_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_audat_0100 .

  CLEAR gv_au_from.
  CLEAR gv_au_to.

  " 둘다 줬을 때
  IF gv_audat_from IS NOT INITIAL AND gv_audat_to IS NOT INITIAL.
    gv_au_from = gv_audat_from.
    gv_au_to   = gv_audat_to.
  ENDIF.


  " 납기 종료 일자에만 값 입력했을 때
  IF gv_audat_from IS INITIAL AND gv_audat_to IS NOT INITIAL.

    " 제일 먼저의 납기일자
    SELECT SINGLE MIN( audat )
      FROM ztd3sd0006
      INTO @gv_au_from.

    gv_au_to = gv_audat_to.

  ENDIF.

  " 납기 시작 일자에만 값 입력했을 떄
  IF gv_audat_from IS NOT INITIAL AND gv_audat_to IS INITIAL.

    gv_au_from = gv_audat_from.
    gv_au_to = gv_audat_from.
  ENDIF.

  " 공백일 때
  IF gv_audat_from IS INITIAL AND gv_audat_to IS INITIAL.

    " 제일 먼저의 판매오더 번호
    SELECT SINGLE MIN( audat )
      FROM ztd3sd0006
      INTO @gv_au_from.

    " 제일 나중의 판매오더 번호
    SELECT SINGLE MAX( audat )
      FROM ztd3sd0006
      INTO @gv_au_to.

  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CHECK_REQUIRED_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_required_0100 INPUT.

  " 고객번호
  PERFORM check_kunnr.

  " 주문일
  PERFORM check_audat.

  " 납기일
  PERFORM check_lfdat.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form check_lfdat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_lfdat .

  IF gv_lfdat_from IS NOT INITIAL AND gv_lfdat_to IS NOT INITIAL.
    " 조회 시작일
    IF gv_lfdat_from NE '00000000'.
      IF gv_lfdat_from LT '20200315'.
        " 103: 회사 설립일( 2020년 3월 15일 ) 이전 데이터는 조회할 수 없습니다.
        MESSAGE s103 DISPLAY LIKE 'E'.
        CLEAR gv_lfdat_from.
        REFRESH gt_display1.

      ENDIF.
    ENDIF.

    " 조회 종료일
    IF gv_lfdat_to NE '00000000'.
      IF gv_lfdat_to LT '20200315'.
        " 103: 회사 설립일( 2020년 3월 15일 ) 이전 데이터는 조회할 수 없습니다.
        MESSAGE s103 DISPLAY LIKE 'E'.
        CLEAR gv_lfdat_to.
        REFRESH gt_display1.

      ENDIF.
    ENDIF.


    IF gv_lfdat_from GT gv_lfdat_to.

      " 104: 조회 시작일이 조회 종료일보다 큽니다.
      MESSAGE s104 DISPLAY LIKE 'E'.
      CLEAR gv_lfdat_to.
      CLEAR gv_lfdat_from.
      REFRESH gt_display1.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_audat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_audat .

  " 조회 시작일
  IF gv_audat_from NE '00000000'.
    IF gv_audat_from LT '20200315'.
      " 103: 회사 설립일( 2020년 3월 15일 ) 이전 데이터는 조회할 수 없습니다.
      MESSAGE w103.
      CLEAR gv_audat_from.
      REFRESH gt_display1.

    ENDIF.
  ENDIF.

  " 조회 종료일
  IF gv_audat_to NE '00000000'.
    IF gv_audat_to LT '20200315'.
      " 103: 회사 설립일( 2020년 3월 15일 ) 이전 데이터는 조회할 수 없습니다.
      MESSAGE w103.
      CLEAR gv_audat_to.
      REFRESH gt_display1.

    ENDIF.
  ENDIF.

  IF gv_audat_from IS NOT INITIAL AND gv_audat_to IS NOT INITIAL.
    IF gv_audat_from GT gv_audat_to.

      " 104: 조회 시작일이 조회 종료일보다 큽니다.
      MESSAGE w104.
      CLEAR gv_audat_to.
      CLEAR gv_audat_from.
      REFRESH gt_display1.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_kunnr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_kunnr .

  IF gv_kunnr_from IS NOT INITIAL AND gv_kunnr_to IS NOT INITIAL.

    IF gv_kunnr_from GT gv_kunnr_to.

      " 335 : 시작 조회조건이 종료 조회조건보다 큽니다.
      MESSAGE w335.



    ENDIF.
  ENDIF.

ENDFORM.
