*&---------------------------------------------------------------------*
*& Include          ZRD3SD9010_TOP
*&---------------------------------------------------------------------*
TABLES : ztd3sd0010.  " 대금청구 헤더
TABLES : ztd3sd0011.  " 대금청구 아이템
TABLES : ztd3sd0001.  " 고객 마스터
TABLES : ztd3fi0004.  " 전표 아이템
TABLES : ztd4fi0002.  " 회사 마스터
TABLES : ztd3sd0006.  " 판매오더 헤더
TABLES : ztd3sd0008.  " 배송오더 헤더

DATA : ok_code           TYPE sy-ucomm.
DATA : gv_title          TYPE text50.
DATA : gv_alv_title      TYPE text50.   " 헤더 ALV
DATA : gv_DEL_TITLE      TYPE text50.
DATA : gv_alv_item_title TYPE text50.   " 아이템 ALV

TYPES : BEGIN OF ty_display1.
          INCLUDE STRUCTURE zsd3sd0010.
TYPES :   get_price  TYPE ztd3sd0010-netwr,          " 회수된 금액
          ng_price   TYPE ztd3sd0010-netwr,          " 미회수된 금액
          line_color TYPE c LENGTH 4,               " 색상
          status     TYPE icon-name,                " 대금 청구 상태 아이콘 표시
        END OF ty_display1.

TYPES : BEGIN OF ty_display2.
          INCLUDE STRUCTURE zsd3sd0011.
TYPES :   tax_price TYPE ztd3sd0010-netwr,          " 세금 금액
          mwtxt     TYPE text10,                    " 세금코드 텍스트
        END OF ty_display2.

" 데이터 가공용 테이블
DATA : gt_billing TYPE TABLE OF ty_display1 WITH NON-UNIQUE KEY vbeln.
DATA : gs_billing LIKE LINE OF gt_billing.
DATA : gt_billing_item TYPE TABLE OF ty_display2 WITH NON-UNIQUE KEY vbeln posnr.
DATA : gs_billing_item LIKE LINE OF gt_billing_item.

" 판매오더 변수
DATA : gt_so TYPE TABLE OF ztd3sd0006 WITH NON-UNIQUE KEY vbeln.
DATA : gs_so LIKE LINE OF gt_so.

" 배송오더 변수
DATA : gt_do TYPE TABLE OF ztd3sd0008 WITH NON-UNIQUE KEY dlrno.
DATA : gs_do LIKE LINE OF gt_do.

" 화면 조회용 테이블
" 헤더
DATA : gt_display TYPE TABLE OF ty_display1 WITH NON-UNIQUE KEY vbeln.
DATA : gs_display LIKE LINE OF gt_display.

" 아이템
DATA : gt_detail  TYPE TABLE OF ty_display2 WITH NON-UNIQUE KEY vbeln posnr.
DATA : gs_detail LIKE LINE OF gt_display.

" 전표번호를 위한 ALV
DATA : gt_statement  TYPE TABLE OF ztd3fi0004.
DATA : gs_statement LIKE LINE OF gt_statement.

" 대금청구 헤더를 위한 ALV
DATA : go_container TYPE REF TO cl_gui_container.
DATA : go_alv_grid  TYPE REF TO cl_gui_alv_grid.

" 대금청구 아이템을 위한 ALV
DATA : go_container2 TYPE REF TO cl_gui_container.
DATA : go_alv_grid2  TYPE REF TO cl_gui_alv_grid.



" Docking Container
DATA : go_custom_container TYPE REF TO cl_gui_custom_container.
DATA : go_splitter TYPE REF TO cl_gui_splitter_container.

DATA : gs_layout    TYPE lvc_s_layo,
       gs_layout2   TYPE lvc_s_layo,
       gs_variant   TYPE disvariant,
       gv_save      TYPE c,
       gs_variant2  TYPE disvariant,
       gv_save2     TYPE c,
       gs_fieldcat  TYPE lvc_s_fcat,
       gt_fieldcat  TYPE lvc_t_fcat,
       gt_fieldcat2 TYPE lvc_t_fcat.



DATA: b1 TYPE c LENGTH 1,
      b2 TYPE c LENGTH 1,
      b3 TYPE c LENGTH 1.

* 토글버튼 제어를 위한 변수
DATA: gs_butn_info  TYPE smp_dyntxt,              " 동적 버튼 제어용 변수
      gv_dock_state TYPE abap_bool VALUE abap_on. " 현재 컨테이너 상태 (X:열림)
* CHECK HIDE CONDITION
DATA: gv_check_hide_cond TYPE abap_bool.


* 조회 조건 출력을 위한 Container 관련 변수
DATA: go_dock_top TYPE REF TO cl_gui_docking_container,
      go_doc      TYPE REF TO cl_dd_document.




**************************************************************
* 110
**************************************************************
DATA : gv_belnr TYPE ztd3fi0004-belnr,    " 전표번호
       gv_bildt TYPE ztd3sd0010-fkdat,    " 대금청구일
       gv_duedt TYPE ztd3fi0004-due_date, " 순액만기일
       gv_bilpr TYPE ztd3fi0004-wrbtr,    " 청구 금액
       gv_suppr TYPE ztd3fi0004-wrbtr,    " 공급가액
       gv_ngtpr TYPE ztd3fi0004-wrbtr,    " 미수 금액
       gv_getpr TYPE ztd3fi0004-wrbtr,    " 받은 금액
       gv_kunnr TYPE ztd3fi0004-kunnr,    " 고객코드
       waers    TYPE ztd3fi0004-waers,    " 통화코드1
       gv_waers TYPE ztd3fi0004-waers,    " 통화코드2
       gv_txt   TYPE text30,              " 연체일
       gv_zttxt TYPE text30,              " 지급조건 텍스트
       gv_butxt TYPE ztd3fi0002-butxt,    " 회사명
       gv_vktxt TYPE text30.              " 지급조건 텍스트

**************************************************************
* 120
**************************************************************
DATA : gv_kunnm TYPE ztd3sd0001-butxt.

**************************************************************
* 130
**************************************************************
" TYPE 텍스트
DATA : gv_tytxt TYPE text30.
DATA : gv_wetxt TYPE text30.
DATA : gv_vstxt TYPE text30.
DATA : gv_litxt TYPE text30.

DATA gv_do1 TYPE ztd3sd0008-dlrno.
DATA gv_do2 TYPE ztd3sd0008-dlrno.
DATA gv_d1txt TYPE c LENGTH 10.
DATA gv_d2txt TYPE c LENGTH 10.



* 검색 결과가 0건인 경우 100번 화면으로 안넘어가기 위한 bool
DATA : gv_no_data type bool.
