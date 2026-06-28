*&---------------------------------------------------------------------*
*& Include          ZRD3SD9007_F01
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


  " 전체 오더 선택 시
  IF pa_all IS NOT INITIAL.

    PERFORM select_all_data.

    " 일반 오더 선택 시
  ELSEIF pa_ge IS NOT INITIAL.

    PERFORM select_ge_data.

    " 교환 오더 선택 시
  ELSEIF pa_re IS NOT INITIAL.

    PERFORM select_re_data.

  ENDIF.


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
*& Form set_alv_data_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_data_0100 .


  " 판매오더 헤더를 위한 ALV
  go_alv_grid->set_table_for_first_display(
  EXPORTING
    i_structure_name              = 'ZSD3SD0008'              " Internal Output Table Structure Name
    is_variant                    = gs_variant              " Layout
    i_save                        = gv_save                 " Save Layout
    is_layout                     = gs_layout                 " Layout
  CHANGING
    it_outtab                     = gt_display                " Output Table
    it_fieldcatalog               = gt_fieldcat               " Field Catalog
    it_sort                       = gt_sort
  EXCEPTIONS
    OTHERS                        = 1
).
  IF sy-subrc <> 0.

    " &1 Custom Container 생성에 실패하였습니다.
    MESSAGE s006 DISPLAY LIKE 'A'.
  ENDIF.

  " 판매오더 아이템을 위한 ALV
  go_alv_grid2->set_table_for_first_display(
  EXPORTING
    i_structure_name              = 'ZSD3SD0009'              " Internal Output Table Structure Name
      is_variant                    = gs_variant2              " Layout
      i_save                        = gv_save2                 " Save Layout
      is_layout                     = gs_layout2                " Layout
  CHANGING
    it_outtab                     = gt_detail               " Output Table
      it_fieldcatalog             = gt_fieldcat2               " Field Catalog
  EXCEPTIONS
    OTHERS                        = 1
).
  IF sy-subrc <> 0.
    " &1 ALV Grid 생성에 실패하였습니다.
    MESSAGE s008 DISPLAY LIKE 'A'.
  ENDIF.



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

  "gs_layout-cwidth_opt = abap_true.
  gs_layout-zebra      = abap_true.
  gs_layout-sel_mode   = 'D'.
  gs_layout-info_fname = 'LINE_COLOR'.
  gs_layout-no_merging = space.
  gs_layout-grid_title = gv_alv_title1.


  "gs_layout2-cwidth_opt = abap_true.
  gs_layout2-zebra      = abap_true.
  gs_layout2-totals_bef = abap_true.
  gs_layout2-sel_mode   = 'D'.
  gs_layout2-grid_title = gv_alv_title2.

  gs_variant-report = sy-cprog.
  gs_variant-handle = 'H1'.
  gv_save           = 'A'.

  gs_variant2-report = sy-cprog.
  gs_variant2-handle = 'H2'.
  gv_save2           = 'A'.



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
*************************************************
* 헤더
*************************************************
  DEFINE _set_fieldcat_h.
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname = &1.
    gs_fieldcat-coltext   = &2.
    gs_fieldcat-outputlen = &3.
    gs_fieldcat-key       = &4.
    gs_fieldcat-no_out    = &5.
    APPEND gs_fieldcat TO gt_fieldcat.
  END-OF-DEFINITION.


  "                  fieldname    coltext          outputlen   key    no_out
  _set_fieldcat_h  'ICON'         '상태'           3           ''      ''.
  _set_fieldcat_h  'VBELN'        '판매오더번호'   10          ''      ''.
  _set_fieldcat_h  'DLRNO'        '출고요청 번호'  10          'X'     ''.
  _set_fieldcat_h  'WERKS'        '플랜트번호'     7           ''      ''.
  _set_fieldcat_h  'WETXT'        '플랜트명'       15          ''      ''.
  _set_fieldcat_h  'TYPE'         '출고요청 유형'  10          ''      ''.
  _set_fieldcat_h  'TYTXT'        '유형 텍스트'    10          ''      ''.
  _set_fieldcat_h  'LISTAT'       '출고요청 상태'  10          ''      ''.
  _set_fieldcat_h  'LITXT'        '상태 텍스트'     8          ''      ''.
  _set_fieldcat_h  'WSDAT'        '출고 예정일'    8           ''      ''.
  _set_fieldcat_h  'WADAT'        '실제 출고일'    8           ''      ''.
  _set_fieldcat_h  'LFDAT'        '납기 일자'      8           ''      ''.
  _set_fieldcat_h  'VSBED'        '배송조건'       6           ''      ''.
  _set_fieldcat_h  'VSTXT'        '조건 텍스트'    10          ''      ''.
  _set_fieldcat_h  'TYPE_SORT'    '조건 텍스트'    10          ''      'X'.



*************************************************
* 아이템
*************************************************
  DEFINE _set_fieldcat_i.
    CLEAR gs_fieldcat.
    gs_fieldcat-fieldname = &1.
    gs_fieldcat-coltext   = &2.
    gs_fieldcat-outputlen = &3.
    gs_fieldcat-key       = &4.
    APPEND gs_fieldcat TO gt_fieldcat2.
  END-OF-DEFINITION.

  "                 fieldname   coltext           outputlen   key
  _set_fieldcat_i 'DLRNO'     '출고요청 번호'   11          'X'.
  _set_fieldcat_i 'MATNM'     '자재명'          20          ''.
  _set_fieldcat_i 'POSNR'     '아이템번호'      6           'X'.

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

  " 딜리버리 헤더 데이터를 조회용 헤더 테이블로 옮긴다
  MOVE-CORRESPONDING gt_delivery TO gt_display.



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

  CLEAR ls_button.
  ls_button-butn_type = 3.
  APPEND ls_button TO po_object->mt_toolbar.

  " 배송오더 타입 전체를 조회하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'ALL'.
  ls_button-text     = '전체'.
  APPEND ls_button TO po_object->mt_toolbar.

  CLEAR ls_button.
  ls_button-butn_type = 3.
  APPEND ls_button TO po_object->mt_toolbar.



  " 배송오더 승인 대기를 조회하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'NOT_APPR'.
  ls_button-text     = '승인 대기'.
  ls_button-icon     = icon_fast_entry.
  APPEND ls_button TO po_object->mt_toolbar.

  " 배송오더 승인 대기를 조회하기 위한 버튼
  "CLEAR ls_button.
  "ls_button-function = 'WILL'.
  "ls_button-text     = '출하 전'.
  "ls_button-icon     = icon_pm_insert.
  "APPEND ls_button TO po_object->mt_toolbar.

  " 배송오더 배송 중을 조회하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'ING'.
  ls_button-text     = '출하 중'.
  ls_button-icon     = icon_delivery.
  APPEND ls_button TO po_object->mt_toolbar.

  " 배송오더 배송 완료를 조회하기 위한 버튼
  CLEAR ls_button.
  ls_button-function = 'END'.
  ls_button-text     = '출하 완료'.
  ls_button-icon     = icon_visit.
  APPEND ls_button TO po_object->mt_toolbar.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_delivery_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM handle_double_click     USING    po_row      TYPE lvc_s_row
                                      po_column   TYPE lvc_s_col
                                      p_roid      TYPE lvc_s_roid.

  CLEAR gs_display.

  READ TABLE gt_display INTO gs_display INDEX po_row-index.

  " 딜리버리 오더 아이템 조회
  PERFORM select_delivery_item USING po_row
                                     po_column.

  " 선택한 행 컬러 처리
  PERFORM set_selected_color   USING po_row
                                     po_column
                                     p_roid.

  " 데이터 가공
  PERFORM modify_item_data     USING po_row
                                     po_column.



  MOVE-CORRESPONDING gt_delivery_item TO gt_detail.

  PERFORM refresh_alv_0100.






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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form filter_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM filter_item  USING    po_ucomm.

  CASE po_ucomm.
    WHEN 'ALL'.
      PERFORM clear_filter.
    WHEN 'NOT_APPR'.
      PERFORM set_filter USING 'N'.
    WHEN 'WILL'.
      PERFORM set_filter USING 'W'.
    WHEN 'ING'.
      PERFORM set_filter USING 'I'.
    WHEN 'END'.
      PERFORM set_filter USING 'E'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_filter
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_filter  USING pv_type TYPE c.


  DATA: lt_filter TYPE lvc_t_filt,
        ls_filter TYPE lvc_s_filt,
        ls_stbl   TYPE lvc_s_stbl.

  DATA : lt_fidx  TYPE lvc_t_fidx,
         lv_count TYPE i.

  CLEAR lt_filter.
  CLEAR lv_count.

  ls_filter-fieldname = 'STATUS'.
  ls_filter-sign      = 'I'.
  ls_filter-option    = 'EQ'.
  ls_filter-low       = pv_type.
  APPEND ls_filter TO lt_filter.

  CALL METHOD go_alv_grid->set_filter_criteria
    EXPORTING
      it_filter = lt_filter.

  REFRESH gt_detail.
  CLEAR gv_alv_title2.


  LOOP AT gt_display INTO gs_display WHERE status EQ pv_type.

    lv_count += 1.

  ENDLOOP.

  IF gs_display-status EQ 'N'.
    gv_alv_title1 = |승인 대기 딜리버리 목록({ lv_count })|.
  ELSEIF gs_display-status EQ 'I'.
    gv_alv_title1 = |출하중 딜리버리 목록({ lv_count })|.
  ELSEIF gs_display-status EQ 'E'.
    gv_alv_title1 = |출하 완료 딜리버리 목록({ lv_count })|.
  ENDIF.



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
  DATA : lv_count TYPE i.

  CLEAR lt_filter.

  CALL METHOD go_alv_grid->set_filter_criteria
    EXPORTING
      it_filter = lt_filter.

  REFRESH gt_detail.
  CLEAR gv_alv_title2.

  lv_count = lines( gt_display ).

  IF pa_all IS NOT INITIAL.
    gv_alv_title1 = |전체 딜리버리 목록({ lv_count })|.
  ELSEIF pa_ge IS NOT INITIAL.
    gv_alv_title1 = |일반 딜리버리 목록({ lv_count })|.
  ELSEIF pa_re IS NOT INITIAL.
    gv_alv_title1 = |교환 딜리버리 목록({ lv_count })|.
  ENDIF.

  PERFORM refresh_alv_0100.

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

  LOOP AT gt_delivery INTO gs_delivery.
    " 플랜트명 필드 채우기
    PERFORM fill_wetxt.

    " 배송상태 필드 채우기
    PERFORM fill_status.

    " 출고요청 타입 텍스트 필드 채우기
    PERFORM fill_tytxt.

    " 배송 타입 텍스트 필드 채우기
    PERFORM fill_vstxt.

    " 출고요청 상태 텍스트 필드 채우기
    PERFORM fill_litxt.

    " 출고 유형에 따른 Sort 하기 위한 로직
    PERFORM fill_sort_type.

    MODIFY gt_delivery FROM gs_delivery.

  ENDLOOP.

  SORT gt_delivery BY vbeln type_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_status .


  CLEAR gs_delivery-status.

  " 실제 출고일 필드가 비워져 있으면
  IF gs_delivery-wadat IS INITIAL.

    gs_delivery-status = 'N'.   " 승인 대기
    gs_delivery-icon   = icon_fast_entry.

    " 실제 출고일 필드가  MM의 입출고 승인으로 인해 채워지고,
    " 아직 납기일 일자가 비워져 있다면
  ELSEIF gs_delivery-wadat IS NOT INITIAL AND gs_delivery-lfdat IS INITIAL.

    gs_delivery-status = 'W'.   " 배송 전
    gs_delivery-icon   =     icon_pm_insert.

    " 실제 출고일 필드가  MM의 입출고 승인으로 인해 채워지고,
    " 오늘 날짜보다 납기 일자와 같거나 크다면 : 배송 완료라면
  ELSEIF gs_delivery-wadat IS NOT INITIAL AND gs_delivery-lfdat IS NOT INITIAL AND sy-datum GE gs_delivery-lfdat.

    gs_delivery-status = 'E'.   " 배송 완료
    gs_delivery-icon   = icon_visit.

    " 실제 출고일 필드가  MM의 입출고 승인으로 인해 채워지고,
    " 납기 일자가 오늘 날짜보다 크다면 : 아직 배송 완료가 아니라면
    " 납기 예정 >
  ELSEIF gs_delivery-wadat IS NOT INITIAL AND gs_delivery-wadat LT sy-datum.

    gs_delivery-status = 'I'.   " 배송 중
    gs_delivery-icon   = icon_delivery.


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

* 최대 조회 건수
  pa_mrow = 100.

* app toolbar
  gs_butn_info-icon_text = TEXT-hid. " 조건 닫기
  gs_butn_info-icon_id   = icon_collapse.


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
        extension = 65               " Control Extension
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
*& Form select_delivery_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_ROW
*&      --> PO_COLUMN
*&---------------------------------------------------------------------*
FORM select_delivery_item  USING    po_row    TYPE lvc_s_row
                                    po_column TYPE lvc_s_col.

  DATA : lv_count TYPE i.

  SELECT a~dlrno,
         a~posnr,
         a~matnr,
         a~lfimg,
         a~kwmeng,
         a~meins
    FROM ztd3sd0009       AS a
   INNER JOIN ztd3sd0008 AS b
      ON a~dlrno EQ b~dlrno
   WHERE b~vbeln EQ @gs_display-vbeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_delivery_item.

    lv_count = lines( gt_delivery_item ).

    gv_alv_title2 = | 딜리버리 아이템 목록({ lv_count })|.

    SORT gt_delivery_item BY dlrno.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form selected_row_color
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_ROW
*&      --> PO_COLUMN
*&---------------------------------------------------------------------*
FORM set_selected_color  USING    p_row    TYPE lvc_s_row
                                  p_column TYPE lvc_s_col
                                  p_roid   TYPE lvc_s_roid.

  LOOP AT gt_display INTO gs_display.

    IF sy-tabix = p_roid-row_id.
      gs_display-line_color = 'C500'.
    ELSE.
      CLEAR gs_display-line_color.
    ENDIF.

    MODIFY gt_display FROM gs_display INDEX sy-tabix.

  ENDLOOP.

  PERFORM refresh_alv_0100.

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

  ls_stable-row = 'X'.
  ls_stable-col = 'X'.

  gs_layout-grid_title  = gv_alv_title1.
  gs_layout2-grid_title = gv_alv_title2.

  CALL METHOD go_alv_grid->set_frontend_layout
    EXPORTING
      is_layout = gs_layout.

  CALL METHOD go_alv_grid2->set_frontend_layout
    EXPORTING
      is_layout = gs_layout2.



  go_alv_grid->refresh_table_display( is_stable = ls_stable ).
  go_alv_grid2->refresh_table_display( is_stable = ls_stable ).

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

  DATA: lv_html   TYPE string,
        lv_dl_txt TYPE string,     " 출고요청 번호
        lv_po_txt TYPE string,     " 판매오더번호
        lv_wa_txt TYPE string,     " 실제출고일
        lv_lf_txt TYPE string.     " 납기일자

  PERFORM get_range_text USING so_dl[]  CHANGING lv_dl_txt.        " 출고요청 번호
  PERFORM get_range_text USING so_po[]  CHANGING lv_po_txt.        " 판매오더번호
  PERFORM get_range_text USING so_wa[]  CHANGING lv_wa_txt.        " 실제출고일
  PERFORM get_range_text USING so_lf[]  CHANGING lv_lf_txt.        " 납기일자


  lv_html =
  '<html>' &&
  '<body style="font-family:Malgun Gothic, Arial, sans-serif; font-size:10pt; margin:0;">' &&

  '<div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">' &&
  '<span style="font-size:22px;">🔍</span>' &&
  '<span style="font-size:16pt; font-weight:bold;">조회 조건</span>' &&
  '</div>' &&

  '<table style="border-collapse:collapse; width:100%; font-size:10pt;">' &&

  '<tr>' &&
  '<td style="font-weight:bold; padding:3px 8px; width:130px;">출고요청 번호</td>' &&
  '<td style="padding:3px 8px;">' && lv_dl_txt && '</td>' &&
  '<td style="font-weight:bold; padding:3px 8px; width:130px;">판매오더번호</td>' &&
  '<td style="padding:3px 8px;">' && lv_po_txt && '</td>' &&
  '</tr>' &&

  '<tr>' &&
  '<td style="font-weight:bold; padding:3px 8px;">실제출고일</td>' &&
  '<td style="padding:3px 8px;">' && lv_wa_txt && '</td>' &&
  '<td style="font-weight:bold; padding:3px 8px;">납기일자</td>' &&
  '<td style="padding:3px 8px;">' && lv_lf_txt && '</td>' &&
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
*&      <-- LV_BUKR_TXT
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
*& Form fill_tytxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_tytxt .

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


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_delivery-type.

  gs_delivery-tytxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_vstxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_vstxt .

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


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_delivery-vsbed.

  gs_delivery-vstxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_matnm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PO_ROW
*&      --> PO_COLUMN
*&---------------------------------------------------------------------*
FORM modify_item_data  USING    p_row    TYPE lvc_s_row
                                p_column TYPE lvc_s_col.

  LOOP AT gt_delivery_item INTO gs_delivery_item.
    " 자재명 조회
    PERFORM select_maktx.



    MODIFY gt_delivery_item FROM gs_delivery_item.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_maktx
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_ROW
*&---------------------------------------------------------------------*
FORM select_maktx.


  SELECT SINGLE maktx
    FROM ztd3mm0001
   WHERE matnr EQ @gs_delivery_item-matnr
    INTO @gs_delivery_item-matnm.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_wetxt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_wetxt .

  CASE gs_delivery-werks.
    WHEN 'P00001'.

      SELECT SINGLE lgobe
        FROM ztd3mm0003
       WHERE werks EQ @gs_delivery-werks
         AND lgort EQ 'S10002'
        INTO @gs_delivery-wetxt.
      WHEN 'P00002'.

        SELECT SINGLE lgobe
          FROM ztd3mm0003
         WHERE werks EQ @gs_delivery-werks
           AND lgort EQ 'S20002'
          INTO @gs_delivery-wetxt.

      ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_all_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_all_data .

  DATA : lv_count TYPE i.


  SELECT dlrno,
         vbeln,
         werks,
         type,
         wsdat,
         wadat,
         lfdat,
         vsbed,
         listat
    FROM ztd3sd0008
   WHERE dlrno IN @so_dl
     AND vbeln IN @so_po
     AND wadat IN @so_wa
     AND lfdat IN @so_lf
     AND substring( dlrno, 3, 1 ) NE '8'
     AND substring( vbeln, 3, 1 ) NE '8'
   ORDER BY PRIMARY KEY
    INTO CORRESPONDING FIELDS OF TABLE @gt_delivery
   UP TO @pa_mrow ROWS.

    SORT gt_delivery BY vbeln.

    lv_count = lines( gt_delivery ).

    gv_alv_title1 = |전체 딜리버리 목록({ lv_count })|.

    IF sy-subrc NE 0.
      gv_no_data = abap_true.
      " 052 : 조회된 데이터가 0건 입니다.
      MESSAGE s052 DISPLAY LIKE 'A'.
    ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_ge_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_ge_data .

  DATA : lv_count TYPE i.


  SELECT dlrno,
         vbeln,
         werks,
         type,
         wsdat,
         wadat,
         lfdat,
         vsbed,
         listat
    FROM ztd3sd0008 AS a
   WHERE dlrno IN @so_dl
     AND vbeln IN @so_po
     AND wadat IN @so_wa
     AND lfdat IN @so_lf
     AND type  EQ 'N'
     AND substring( dlrno, 3, 1 ) NE '8'
     AND substring( vbeln, 3, 1 ) NE '8'
     AND NOT EXISTS (
         SELECT *
           FROM ztd3sd0008 AS b
          WHERE b~vbeln = a~vbeln
            AND b~type  <> 'N'
     )
   ORDER BY vbeln, dlrno
    INTO CORRESPONDING FIELDS OF TABLE @gt_delivery
      UP TO @pa_mrow ROWS.


    SORT gt_delivery BY vbeln.

    lv_count = lines( gt_delivery ).

    gv_alv_title1 = |'일반 딜리버리 목록({ lv_count })'|.

    IF sy-subrc NE 0.
      gv_no_data = abap_true.
      " 052 : 조회된 데이터가 0건 입니다.
      MESSAGE s052 DISPLAY LIKE 'A'.
    ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_re_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_re_data .

  CHECK pa_re IS NOT INITIAL.

  DATA : lv_count TYPE i.

  SELECT dlrno,
         vbeln,
         werks,
         type,
         wsdat,
         wadat,
         lfdat,
         vsbed,
         listat
    FROM ztd3sd0008 AS a
   WHERE dlrno IN @so_dl
     AND vbeln IN @so_po
     AND wadat IN @so_wa
     AND lfdat IN @so_lf
     AND substring( dlrno, 3, 1 ) NE '8'
     AND substring( vbeln, 3, 1 ) NE '8'
     AND EXISTS (
         SELECT *
           FROM ztd3sd0008 AS b
          WHERE b~vbeln = a~vbeln
            AND b~type  = 'E'
     )
   ORDER BY vbeln, dlrno
    INTO CORRESPONDING FIELDS OF TABLE @gt_delivery
      UP TO @pa_mrow ROWS.

    SORT gt_delivery BY vbeln.

    lv_count = lines( gt_delivery ).

    gv_alv_title1 = |교환 딜리버리 목록({ lv_count })|.

    IF sy-subrc NE 0.
      gv_no_data = abap_true.
      " 052 : 조회된 데이터가 0건 입니다.
      MESSAGE s052 DISPLAY LIKE 'A'.
    ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_litxt.

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


  READ TABLE lt_dom INTO ls_dom WITH KEY domvalue_l = gs_delivery-listat.

  gs_delivery-litxt = ls_dom-ddtext.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_sort_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_sort_0100 .

  CLEAR gs_sort.
  gs_sort-fieldname = 'VBELN'.
  gs_sort-up        = abap_true.
  APPEND gs_sort TO gt_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_sort_type
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_sort_type .

  CASE gs_delivery-type.
    WHEN 'N'. " 일반오더
      gs_delivery-type_sort = 1.
    WHEN 'R'. " 회수오더
      gs_delivery-type_sort = 2.
    WHEN 'E'. " 교환오더
      gs_delivery-type_sort = 3.
  ENDCASE.


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
