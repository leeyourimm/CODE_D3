*&---------------------------------------------------------------------*
*& Include          ZRD3FI9010_TOP
*&---------------------------------------------------------------------*
TABLES : ztd3sd0001,    " 고객마스터
         ztd3sd0010,    " 대금청구 헤더
         ztd3sd0006,    " 판매오더 헤더
         ztd3fi0013,    " 세금계산서 헤더
         ztd3fi0003,    " 전표 헤더
         ztd3fi0004,    " 전표 아이템
         ztd3fi0002.    " 회사 마스터


TYPES : BEGIN OF ty_display3.
          INCLUDE TYPE ztd3sd0006.
TYPES :   mwsts TYPE ztd3fi0004-mwsts,
        END OF ty_display3.




DATA : gt_tax_header TYPE TABLE OF zsd3fi0013.
DATA : gs_tax_header LIKE LINE OF gt_tax_header.
DATA : gt_tax_item   TYPE TABLE OF ztd3fi0014.
DATA : gs_tax_item   LIKE LINE OF gt_tax_item.

DATA : ok_code TYPE sy-ucomm.

" 팝업 확인 체크를 위한 bool
DATA : gv_ok   TYPE bool.

" 100번 화면에서 선택한 인덱스를 저장할 변수
DATA : gv_index TYPE i.


*******************************************************************
* 100
*******************************************************************
DATA : gt_display1 TYPE TABLE OF zsd3fi0013.
DATA : gs_display1 LIKE LINE OF gt_display1.

DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.


DATA : gs_layout   TYPE lvc_s_layo.
DATA : gs_fieldcat TYPE lvc_s_fcat.
DATA : gt_fieldcat TYPE lvc_t_fcat.
DATA : gs_variant  TYPE disvariant.
DATA : gv_save     TYPE c.

DATA : gv_title TYPE sy-title.
DATA : gv_alv_100_title TYPE c LENGTH 20.

*******************************************************************
* 101 102 103
*******************************************************************
CONTROLS: tab TYPE TABSTRIP.

DATA gv_subscreen TYPE sy-dynnr.

* 101
* 공급자
DATA : gt_company TYPE TABLE OF ztd3fi0002 WITH NON-UNIQUE KEY bukrs.
DATA : gs_company LIKE LINE OF gt_company.

* 공급받는 자
DATA : gt_receiver TYPE TABLE OF zsd3sd0014 WITH NON-UNIQUE KEY bukrs kunnr.
DATA : gs_receiver LIKE LINE OF gt_receiver.

* 102
* 참조 판매오더 헤더
DATA : gt_so    TYPE TABLE OF ty_display3 WITH NON-UNIQUE KEY vbeln.
DATA : gt_so_de TYPE TABLE OF zsd3sd0007  WITH NON-UNIQUE KEY vbeln posnr.

* 참조 판매오더 아이템
DATA : gs_so    LIKE LINE OF gt_so.
DATA : gs_so_de LIKE LINE OF gt_so_de.

DATA : go_container2 TYPE REF TO cl_gui_custom_container,
       go_alv_grid2  TYPE REF TO cl_gui_alv_grid.

DATA : gs_layout2   TYPE lvc_s_layo.
DATA : gt_fieldcat2 TYPE lvc_t_fcat.
DATA : gs_variant2  TYPE disvariant.
DATA : gv_save2     TYPE c.

DATA: gv_amt_detail_open TYPE abap_bool,
      gv_amt_btn         TYPE smp_dyntxt.

" 테이블 라인 수
DATA : gv_lines_bi TYPE i.

***********************************************************
" Docking Container
***********************************************************
DATA: go_dock_top TYPE REF TO cl_gui_docking_container,
      go_doc      TYPE REF TO cl_dd_document.
