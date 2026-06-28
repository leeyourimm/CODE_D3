*&---------------------------------------------------------------------*
*& Include          ZRD3FI9010_F01
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

  PERFORM select_count.


  PERFORM select_tax_data.



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


  IF so_bud-high IS INITIAL.
    CALL SCREEN 0100.
  ELSE.
    IF so_bud-high LT '20200315'.
      " 회사 설립일( 2020년 3월 15일 ) 이전 데이터는 조회할 수 없습니다.
      MESSAGE s103 DISPLAY LIKE 'W'.
      RETURN.
    ELSE.
      CALL SCREEN 0100.
    ENDIF.
  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0100 .

  go_container = NEW cl_gui_custom_container( 'CCON' ).

  go_alv_grid = NEW cl_gui_alv_grid( go_container ).

*--------------------------------------------------------------------*
* 상단에 docking container, doc 생성
*--------------------------------------------------------------------*
  IF go_dock_top IS INITIAL.
    CREATE OBJECT go_dock_top
      EXPORTING
        repid     = sy-repid " REPORT TO WHICH THIS DOCKING CONTROL IS LINKED
        dynnr     = sy-dynnr " SCREEN TO WHICH THIS DOCKING CONTROL IS LINKED
        side      = cl_gui_docking_container=>dock_at_top
        extension = 80               " Control Extension
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
*& Form set_alv_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_0100 .

  go_alv_grid->set_table_for_first_display(
    EXPORTING
      is_variant                    = gs_variant        " Layout
      i_save                        = gv_save           " Save Layout
      is_layout                     = gs_layout         " Layout
"      i_structure_name              = 'ZSD3FI0013'
    CHANGING
      it_outtab                     = gt_display1       " Output Table
      it_fieldcatalog               = gt_fieldcat       " Field Catalog
  ).



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


  DATA : lv_lines TYPE n LENGTH 3.

  lv_lines = lines( gt_tax_header ).


  gv_alv_100_title = | { TEXT-t05 } ({ pa_mrow NUMBER = USER })건 |. " t05: 발생 거래 건수

  gs_layout = VALUE #( sel_mode            = 'D'             " 셀 단위 다중 선택 가능
                       cwidth_opt          = abap_on         " 열 너비 최적화
                       col_opt             = abap_on         " 전체 화면 기준 최적화
                       zebra               = abap_on         " Zebra 적용
                       totals_bef          = abap_on         " 총계 상단 고정
                       grid_title          = gv_alv_100_title ).     " Grid Title 적용

  gs_variant-report = sy-repid.
  gs_variant-handle = 'H1'.

  gv_save = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0100 .


  DEFINE _set_fieldcat.
    CLEAR gs_fieldcat.
    gs_fieldcat-key       = &1.
    gs_fieldcat-fieldname = &2.
    gs_fieldcat-coltext   = &3.
    gs_fieldcat-icon      = &4.
    gs_fieldcat-cfieldname = &5.
    gs_fieldcat-hotspot   = &6.
    gs_fieldcat-no_out    = &7.
    gs_fieldcat-icon      = &8.
    APPEND gs_fieldcat TO gt_fieldcat.
  END-OF-DEFINITION.

  REFRESH gt_fieldcat.

  "             key fieldname    text               icon  cfield    hotspot no_out  icon
  _set_fieldcat 'X' 'EXNUM'      '세금계산서 번호'  ''    ''       ''       ''      ''.
  _set_fieldcat ''  'EXSTAT'     '승인 여부'        ''    ''       ''       'X'      ''.
  _set_fieldcat ''  'STATUS'     '승인 상태'        ''    ''       ''       ''      'X'.
  _set_fieldcat ''  'BUKRS'      '회사코드'         ''    ''       ''       'X'      ''.
  _set_fieldcat ''  'KUNNR'      '고객코드'         ''    ''       ''       ''      ''.
  _set_fieldcat ''  'BUTXT'      '고객명'         ''    ''       ''       ''      ''.
  _set_fieldcat ''  'REPNM'      '대표자명'         ''    ''       ''       ''      ''.
  _set_fieldcat ''  'VBELN_SO'   '판매오더번호'     ''    ''       ''       'X'      ''.
  _set_fieldcat ''  'BLDAT'      '전기일'         ''    ''       ''       ''      ''.
  _set_fieldcat ''  'WAERS'      '통화코드'         ''    ''       ''       ''      ''.
  _set_fieldcat ''  'TOTAL_AMT'  '총공급가액'       ''    'WAERS'  ''       ''      ''.
*  _set_fieldcat ''  'TAXCD'      '세금코드'         ''    ''       ''       ''.
  _set_fieldcat ''  'VAT_AMT'    '총세액'           ''    'WAERS'  ''       ''      ''.
  _set_fieldcat ''  'GROSS'      '총액'             ''    'WAERS'  ''       ''      ''.
  _set_fieldcat ''  'BELNR'      '전표번호'         ''    ''       'X'      ''      ''.
  _set_fieldcat ''  'GJAHR'      '회계년도'         ''    ''       ''       ''      ''.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event_handler_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_event_handler_0100 .

  SET HANDLER lcl_event_handler=>on_hotspot_click FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_toolbar FOR go_alv_grid.
  SET HANDLER lcl_event_handler=>on_user_command FOR go_alv_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_vat_amt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_vat_amt .

*  " 세율
*  DATA : lv_TAXPR TYPE ztd3fi0005-taxpr.
*
*  SELECT SINGLE taxpr
*    FROM ztd3fi0005
*   WHERE taxcd EQ @gs_tax-
*    INTO @lv_taxpr.
*
*  lv_taxpr /= 100.
*
*  gs_tax-vat_amt = gs_tax-netwr * lv_taxpr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_ddtxt.
*
*  DATA: lt_dom TYPE TABLE OF dd07v,
*        ls_dom TYPE dd07v.
*
*  " Fixed Value의 Discription 가져오는 Function
*  CALL FUNCTION 'DD_DOMVALUES_GET'
*    EXPORTING
*      domname   = 'ZDD3_SD_BOSTAT'
*      text      = 'X'
*      langu     = sy-langu
*    TABLES
*      dd07v_tab = lt_dom
*    EXCEPTIONS
*      OTHERS    = 1.
*
*
*  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_bill-vbstat.
*
*  gs_bill-vbtxt = ls_dom-ddtext.

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

  READ TABLE gt_tax_header INTO gs_tax_header INDEX p_row_id-index.

*     출력용 ITAB에서 선택한 행에 대한 정보를 찾지 못할 경우 중단한다.
  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

*     선택한 컬럼명의 필드명에 따라 로직을 구현한다.
  CASE p_column_id-fieldname.
    WHEN 'BELNR'. " 전표번호
      SET PARAMETER ID 'BUK' FIELD gs_tax_header-bukrs.   " 회사코드
      SET PARAMETER ID 'GJR' FIELD gs_tax_header-gjahr.   " 회계연도
      SET PARAMETER ID 'BLN' FIELD gs_tax_header-belnr.   " 전표번호

      CALL TRANSACTION 'ZRD3FI0001' AND SKIP FIRST SCREEN.  " 전표 단일 조회 프로그램 호출

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form print_tax
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_index .

  DATA: lt_rows TYPE lvc_t_row,
        ls_row  TYPE lvc_s_row.

  " 사용자가 ALV에서 수정한 값 먼저 내부테이블에 반영
  CALL METHOD go_alv_grid->check_changed_data.

  " 선택 행 가져오기
  CALL METHOD go_alv_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  " 선택 안 했을 때
  IF lt_rows IS INITIAL.
    " 데이터를 선택해 주세요
    MESSAGE s080 DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  " 여러 행 선택했을 때
  IF lines( lt_rows ) GT 1.
    " 데이터를 1건만 선택해 주세요
    MESSAGE s079 DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  READ TABLE lt_rows INTO ls_row INDEX 1.

  CLEAR gs_display1.
  CLEAR gv_index.

  READ TABLE gt_display1 INTO gs_display1 INDEX ls_row-index.

  gv_index = ls_row-index.

  IF gs_display1-exstat EQ 'P'.
    " 087 : 이미 세금계산서가 승인된 건입니다.
    MESSAGE s087 DISPLAY LIKE 'A'.
    RETURN.
  ENDIF.

  CALL SCREEN 0200.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form no_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_tax_data.

  REFRESH gt_tax_header.

  DATA : lv_BSCHL TYPE ztd3fi0004-bschl.  " 전기키

  lv_bschl = 1.                           " 매출 채권 발생





  SELECT a~exnum,
         a~exstat,
         b~bukrs,
         a~vbeln,
         a~kunnr,
         b~butxt,
         b~repnm,
         a~belnr,
         a~gjahr,
         a~bldat,
         a~waers,
         a~total_amt,
         a~vat_amt
    FROM            ztd3fi0013 AS a
    LEFT OUTER JOIN ztd3sd0001 AS b
      ON a~kunnr = b~kunnr
    INNER JOIN      ztd3sd0010 AS c
      ON a~vbeln = c~vbeln_so
    WHERE a~kunnr IN @so_kun  AND
          b~butxt IN @so_but  AND
          a~exnum IN @so_exn  AND
          a~gjahr IN @so_gja  AND
          a~belnr IN @so_bel  AND
          a~bldat IN @so_bud

    INTO CORRESPONDING FIELDS OF TABLE @gt_tax_header
    UP TO @pa_mrow ROWS.

  SORT gt_tax_header BY kunnr exnum gjahr.

  IF pa_mrow GT lines( gt_tax_header ).
    pa_mrow = lines( gt_tax_header ).
  ENDIF.


  IF gv_lines_bi EQ 0.
    " 조회된 데이터가 0건 입니다.
    MESSAGE s052 DISPLAY LIKE 'E'.
  ENDIF.




ENDFORM.


*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM initialization .

  pa_buk = 1000.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_company
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_company .
  CLEAR gs_company.

  SELECT SINGLE bukrs,    " 회사코드
                butxt,    " 회사명
                stceg,    " 사업자등록번호
                address,  " 주소
                telno,    " 전화번호
                mail      " 이메일
    FROM ztd3fi0002
   WHERE bukrs EQ @pa_buk
    INTO CORRESPONDING FIELDS OF @gs_company.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_receiver
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_receiver .

  CLEAR gs_receiver.

  SELECT SINGLE kunnr,  " 고객코드
                kdgrp,  " 고객 유형 코드
                stceg,  " 사업자 등록 번호
                butxt,  " 고객명
                repnm,  " 대표자명
                stras,  " 주소
                telf1,  " 전화번호
                mail    " 이메일
    FROM ztd3sd0001
   WHERE kunnr EQ @gs_display1-kunnr
     AND bukrs EQ @gs_display1-bukrs
    INTO CORRESPONDING FIELDS OF @gs_receiver.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_so
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_so .

  CLEAR gs_so.

  SELECT SINGLE vbeln,  " 판매오더 번호
                audat,  " 주문일자
                gross,  " 총액
                netwr,  " 순금액
                waers   " 통화코드
    FROM ztd3sd0006
   WHERE vbeln EQ @gs_display1-vbeln
    INTO CORRESPONDING FIELDS OF @gs_so.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_so_de
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_so_de .

  REFRESH gt_so_de.

  SELECT a~vbeln,           " 판매오더 번호
         a~posnr,           " 아이템번호
         a~matnr,           " 자재번호
         c~maktx AS matnm,  " 자재명
         a~kwmeng,          " 청구 수량
         a~meins,           " 수량 단위
         a~mwskz,           " 세금코드
         a~netpr,           " 단가
         a~netwr,           " 공급가액
         a~kbetr,           " 할인율
         a~gross,           " 총액
         b~waers            " 통화코드
    FROM            ztd3sd0007 AS a
    INNER JOIN      ztd3sd0006 AS b ON a~vbeln EQ b~vbeln
    LEFT OUTER JOIN ztd3mm0001 AS c ON a~matnr EQ c~matnr
   WHERE a~vbeln EQ @gs_so-vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_so_de.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_object_0102 .

  go_container2 = NEW cl_gui_custom_container( 'CCON2' ).

  go_alv_grid2  = NEW cl_gui_alv_grid( go_container2 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout_0102 .

  gs_layout2 = VALUE #( sel_mode            = 'D'             " 셀 단위 다중 선택 가능
                        col_opt             = abap_on         " 전체 화면 기준 최적화
                        zebra               = abap_on         " Zebra 적용
                        totals_bef          = abap_on         " 총계 상단 고정
                     ).

  gs_variant2-report = sy-repid.
  gs_variant2-handle = 'H2'.

  gv_save2 = 'A'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fieldcat_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat_0102 .


  DEFINE _set_fieldcat.
    CLEAR gs_fieldcat.
    gs_fieldcat-key        = &1.
    gs_fieldcat-fieldname  = &2.
    gs_fieldcat-coltext    = &3.
    gs_fieldcat-cfieldname = &4.
    gs_fieldcat-qfieldname = &5.
    gs_fieldcat-outputlen  = &6.
    gs_fieldcat-ref_field  = &7.
    gs_fieldcat-ref_table  = &8.
    APPEND gs_fieldcat TO gt_fieldcat2.
  END-OF-DEFINITION.

  REFRESH gt_fieldcat2.

  "             key fieldname text                   cfield   qfield    outputlen ref_field  ref_table
  _set_fieldcat 'X' 'VBELN'   '판매오더번호'         ''       ''        10        ''         ''.
  _set_fieldcat 'X' 'POSNR'   '판매오더 아이템 번호' ''       ''        14        ''         ''.
  _set_fieldcat ''  'MATNR'   '자재 코드'            ''       ''        6         ''         ''.
  _set_fieldcat ''  'MATNM'   '자재명'               ''       ''        30        ''         ''.
  _set_fieldcat ''  'KWMENG'  '주문수량'             ''       'MEINS'   6         ''         ''.
  _set_fieldcat ''  'MEINS'   '단위'                 ''       ''        6         ''         ''.
  _set_fieldcat ''  'MWSKZ'   '세금코드'             ''       ''        6         ''         ''.
  _set_fieldcat ''  'MWSPR'   '세액'                 ''       ''        6         ''         ''.
  _set_fieldcat ''  'NETPR'   '단가'                 'WAERS'  ''        10        ''         ''.
  _set_fieldcat ''  'NETWR'   '순금액'               'WAERS'  ''        10        ''         ''.
  _set_fieldcat ''  'KBETR'   '할인율'               ''       ''        6         ''         ''.
  _set_fieldcat ''  'KBEPR'   '할인 금액'            ''       ''        6         ''         ''.
  _set_fieldcat ''  'GROSS'   '총액'                 'WAERS'  ''        10        ''         ''.
  _set_fieldcat ''  'WAERS'   '통화코드'             ''       ''        6         ''         ''.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_event_handler_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_event_handler_0102 .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_alv_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_0102 .

  go_alv_grid2->set_table_for_first_display(
  EXPORTING
    is_variant                    = gs_variant2        " Layout
    i_save                        = gv_save2           " Save Layout
    i_structure_name              = 'ZSD3SD0007'
    is_layout                     = gs_layout2         " Layout
  CHANGING
    it_outtab                     = gt_so_de       " Output Table
    it_fieldcatalog               = gt_fieldcat2       " Field Catalog
).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form currency_amount_display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM currency_amount_display .




ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_SEARCH_OPT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_SEARCH_OPT .

  CLEAR gv_amt_btn.



  IF gv_amt_detail_open = abap_true.
    gv_amt_btn-text      = TEXT-t02.   " 닫기
    gv_amt_btn-quickinfo = TEXT-t02.
  ELSE.
    gv_amt_btn-text      = TEXT-t01.   " 금액 상세 보기
    gv_amt_btn-quickinfo = TEXT-t01.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.

  CASE ok_code.
    WHEN 'AMT_DETAIL'.
      gv_amt_detail_open = xsdbool( gv_amt_detail_open = abap_false ).

  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Form free_alv_0102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_alv_0102 .

  IF go_alv_grid2 IS BOUND.
    CALL METHOD go_alv_grid2->free.
  ENDIF.
  FREE go_alv_grid2.

  IF go_container2 IS BOUND.
    CALL METHOD go_container2->free.
  ENDIF.
  FREE go_container2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_mwspr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_mwspr .

  " 세액 설정
  IF gs_so_de-mwskz EQ 'A1'.
    " 부가세는 10%
    " 세액 아이템에 넣기(각 자재에 대한 세액)
    gs_so_de-mwspr = gs_so_de-netwr / 10.

    " 세액 헤더에 넣기(세액 총액)
    gs_so-mwsts += gs_so_de-mwspr.

  ELSE.

    " 다른 세금코드에 대한 설정
    " 해당 프로젝트는 부가세에 대해서만 설정하였음
    gs_so_de-mwspr = space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_KBEPR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_KBEPR .

  " 만약 할인율이 존재한다면
  IF gs_so_de-kbetr NE 0.
    " 할인율에 대한 할인액 설정
    gs_so_de-kbepr = gs_so_de-netwr * gs_so_de-kbetr.
  ELSE.
    " 할인율이 없다면 할인액 0으로 설정
    gs_so_de-kbepr = 0.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gv_amt_detail_default
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gv_amt_detail_default .

  " 스크린에 들어올 때마다 상세 보기가 기본값으로 설정되게
  gv_amt_detail_open = abap_false.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_activetab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_activetab .

  CLEAR tab-activetab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_tax_db
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_tax_db .

  CHECK gv_ok IS NOT INITIAL.

  " 세금계산서 상태 승인으로 변경
  UPDATE ztd3fi0013
     SET exstat = 'P'
   WHERE exnum EQ @gs_display1-exnum.

  " 대금청구 상태 세금계산서 발행 완료로 변경
  UPDATE ztd3sd0010
     SET vbstat = 'B'
   WHERE vbeln_so EQ @gs_display1-vbeln.

  IF sy-subrc EQ 0.
    " 세금계산서 승인이 완료되었습니다.
    MESSAGE s240 DISPLAY LIKE 'S'.
    gs_display1-exstat = 'P'.
  ELSE.
    " 세금계산서 승인 실패하였습니다.
    MESSAGE s241 DISPLAY LIKE 'A'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form popup_to_confirm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> OK_CODE
*&---------------------------------------------------------------------*
FORM popup_to_confirm  USING     pv_ok_code  TYPE sy-ucomm
                       CHANGING  pv_ok       TYPE bool.


  DATA: lv_title    TYPE string,
        lv_question TYPE string,
        lv_answer   TYPE c.

  CLEAR pv_ok.

  CASE pv_ok_code.
    WHEN 'APPROVE'.
      lv_title     = '세금계산서 승인'.
      lv_question  = '발생된 거래에 대한 세금계산서를 승인하시겠습니까?'.

  ENDCASE.

  " 팝업 불러오는 함수
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
  pv_ok = abap_true..

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

  gs_layout-grid_title = gv_alv_100_title.  " 먼저 제목 최신값 반영

  CALL METHOD go_alv_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

  go_alv_grid->refresh_table_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form update_tax_itab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_tax_itab .

  MODIFY gt_display1 FROM gs_display1 INDEX gv_index.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_gross
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_gross .

  gs_tax_header-gross = gs_tax_header-total_amt + gs_tax_header-vat_amt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_status_icon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_status_icon .

  CASE gs_display1-exstat.
    WHEN 'D'. " 승인 전
      gs_display1-status = icon_led_yellow.
    WHEN 'P'. " 승인
      gs_display1-status = icon_led_green.
    WHEN 'C'. " 반려
  ENDCASE.

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
  LOOP AT gt_tax_header INTO gs_tax_header.

    " 총액 설정
    PERFORM set_gross.

    MODIFY gt_tax_header FROM gs_tax_header.

  ENDLOOP.

  " 변경된 데이터를 화면에 띄우기 위해 데이터 복사
  gt_display1 = CORRESPONDING #( gt_tax_header ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_kdgrp_txt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_kdgrp_txt .

  DATA: lt_dom TYPE TABLE OF dd07v,
        ls_dom TYPE dd07v.

  " Fixed Value의 Discription 가져오는 Function
  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname   = 'ZDD3_SD_KDGRP'
      text      = 'X'
      langu     = sy-langu
    TABLES
      dd07v_tab = lt_dom
    EXCEPTIONS
      OTHERS    = 1.


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_receiver-kdgrp.

  gs_receiver-kdgrp_txt = ls_dom-ddtext.

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
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_user_command  USING pv_ucomm TYPE sy-ucomm.

  CASE pv_ucomm.
    WHEN 'SHOW_ROW'.
      PERFORM set_show_row.

  ENDCASE.

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

  FIELD-SYMBOLS : <ft_lines>    TYPE i.   " 조회 조건으로 검색한 전체 결과 갯수
  FIELD-SYMBOLS : <ft_max_rows> TYPE i.   " 조회 조건으로 검색한 결과 중 최대 조회 건수 제한에 따라 검색된 갯수


  ASSIGN gv_lines_bi TO <ft_lines>.
  ASSIGN pa_mrow     TO <ft_max_rows>.

*     1. 조회조건에서 입력된 최대 조회 건수를 가져와서 변경한다.
  CALL FUNCTION 'ZFD3PP0004'
    CHANGING
      cv_max_row = <ft_max_rows>.   " Max Row 변수

*     2. 데이터 재조회
  PERFORM select_data.        " 데이터 조회
  PERFORM modify_data.

  gv_alv_100_title = | { TEXT-t05 } ({ pa_mrow NUMBER = USER })건 |. " t05: 발생 거래 건수

*     2. ALV 화면 새로고침
  PERFORM refresh_alv_0100.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_count
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_count .

  SELECT FROM ztd3fi0013     " 세금계산서 헤더
  FIELDS COUNT( * )
    INTO @gv_lines_bi.

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
        lv_gjah_txt TYPE string,     " 회계년도
        lv_exnu_txt TYPE string,     " 세금계산서 번호
        lv_beln_txt TYPE string,     " 전표번호
        lv_blda_txt TYPE string,     " 전기일
        lv_kunn_txt TYPE string,     " 고객코드
        lv_butx_txt TYPE string.     " 고객명

  "PERFORM get_range_text USING so_bu[]  CHANGING lv_bukr_txt.        " 회사코드
  PERFORM get_range_text USING so_gja[]  CHANGING lv_gjah_txt.        " 회계년도
  PERFORM get_range_text USING so_exn[]  CHANGING lv_exnu_txt.        " 세금계산서 번호
  PERFORM get_range_text USING so_bel[]  CHANGING lv_beln_txt.        " 전표번호
  PERFORM get_range_text USING so_bud[]  CHANGING lv_blda_txt.        " 전기일
  PERFORM get_range_text USING so_kun[]  CHANGING lv_kunn_txt.        " 고객코드
  PERFORM get_range_text USING so_but[]  CHANGING lv_butx_txt.        " 고객명



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
  '<td style="padding:3px 8px;">' && pa_buk && '</td>' &&
  '<td style="font-weight:bold; padding:3px 8px; width:130px;">회계년도</td>' &&
  '<td style="padding:3px 8px;">' && lv_gjah_txt && '</td>' &&
  '</tr>' &&

  '<tr>' &&
  '<td style="font-weight:bold; padding:3px 8px;">세금계산서 번호</td>' &&
  '<td style="padding:3px 8px;">' && lv_exnu_txt && '</td>' &&
  '<td style="font-weight:bold; padding:3px 8px;">전표번호</td>' &&
  '<td style="padding:3px 8px;">' && lv_beln_txt && '</td>' &&
  '</tr>' &&

  '<tr>' &&
  '<td style="font-weight:bold; padding:3px 8px;">전기일</td>' &&
  '<td style="padding:3px 8px;">' && lv_blda_txt && '</td>' &&
  '</tr>' &&

  '<tr>' &&
  '<td style="font-weight:bold; padding:3px 8px;">고객코드</td>' &&
  '<td style="padding:3px 8px;">' && lv_kunn_txt && '</td>' &&
  '<td style="font-weight:bold; padding:3px 8px;">고객명</td>' &&
  '<td style="padding:3px 8px;">' && lv_butx_txt && '</td>' &&
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
*&      --> SO_BEL[]
*&      <-- LV_GJAH_TXT
*&---------------------------------------------------------------------*
FORM get_range_text  USING    it_range TYPE STANDARD TABLE
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
*& Form f4_vbeln
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_kunnr_high.

  DATA: lt_return TYPE TABLE OF ddshretval,
        ls_return TYPE ddshretval,
        lt_dynp   TYPE TABLE OF dynpread,
        ls_dynp   TYPE dynpread,
        ls_cust   TYPE ztd3sd0001.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname     = 'ZTD3SD0001'
      fieldname   = 'KUNNR'
      searchhelp  = 'ZSHD3SD0001'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'SO_KUN-HIGH'
    TABLES
      return_tab  = lt_return.

  READ TABLE lt_return INTO ls_return WITH KEY fieldname = 'KUNNR'.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  SELECT SINGLE *
    INTO @ls_cust
    FROM ztd3sd0001
   WHERE kunnr = @ls_return-fieldval.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CLEAR lt_dynp.
  ls_dynp-fieldname  = 'SO_KUN-HIGH'.
  ls_dynp-fieldvalue = ls_cust-kunnr.
  APPEND ls_dynp TO lt_dynp.

  ls_dynp-fieldname  = 'SO_BUT-HIGH'.
  ls_dynp-fieldvalue = ls_cust-butxt.
  APPEND ls_dynp TO lt_dynp.



  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_dynp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_kunnr_low
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_kunnr_low .
  DATA: lt_return TYPE TABLE OF ddshretval,
        ls_return TYPE ddshretval,
        lt_dynp   TYPE TABLE OF dynpread,
        ls_dynp   TYPE dynpread,
        ls_cust   TYPE ztd3sd0001.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname     = 'ZTD3SD0001'
      fieldname   = 'KUNNR'
      searchhelp  = 'ZSHD3SD0001'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'SO_KUN-LOW'
    TABLES
      return_tab  = lt_return.

  READ TABLE lt_return INTO ls_return WITH KEY fieldname = 'KUNNR'.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  SELECT SINGLE *
    INTO @ls_cust
    FROM ztd3sd0001
   WHERE kunnr = @ls_return-fieldval.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CLEAR lt_dynp.
  ls_dynp-fieldname  = 'SO_KUN-LOW'.
  ls_dynp-fieldvalue = ls_cust-kunnr.
  APPEND ls_dynp TO lt_dynp.

  ls_dynp-fieldname  = 'SO_BUT-LOW'.
  ls_dynp-fieldvalue = ls_cust-butxt.
  APPEND ls_dynp TO lt_dynp.



  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_dynp.

ENDFORM.
