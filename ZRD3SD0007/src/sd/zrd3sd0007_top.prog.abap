*&---------------------------------------------------------------------*
*& Include          ZRD3SD9007_TOP
*&---------------------------------------------------------------------*

TABLES : ztd3sd0008.  " 출고요청 헤더
TABLES : ztd3sd0009.  " 출고요청 아이템

DATA : ok_code LIKE sy-ucomm.
DATA gv_title TYPE text50.


TYPES : BEGIN OF ty_display.
          INCLUDE STRUCTURE zsd3sd0008.
TYPES :   status     TYPE c,           " 배송 상태 (W/I/E)
          line_color TYPE c LENGTH 4,  " 클릭한 행
          icon       TYPE icon-name.  " 클릭한 행
TYPES : END OF ty_display.


TYPES : BEGIN OF ty_display2.
          INCLUDE STRUCTURE zsd3sd0009.
TYPES :END OF ty_display2.

DATA : gt_delivery TYPE TABLE OF ty_display WITH NON-UNIQUE KEY dlrno.
DATA : gs_delivery LIKE LINE OF gt_delivery.


DATA : gt_delivery_item TYPE TABLE OF ty_display2 WITH NON-UNIQUE KEY dlrno posnr.
DATA : gs_delivery_item LIKE LINE OF gt_delivery_item.


DATA : gt_display TYPE TABLE OF ty_display WITH NON-UNIQUE KEY dlrno.
DATA : gs_display LIKE LINE OF gt_display.

* DATA : gt_display TYPE TABLE OF zsd3sd0008 WITH NON-UNIQUE KEY dlrno.
DATA : gt_detail  TYPE TABLE OF zsd3sd0009 WITH NON-UNIQUE KEY dlrno posnr.
DATA : gs_detail  LIKE LINE OF gt_detail.

" 딜리버리 헤더를 위한 ALV
DATA : go_container TYPE REF TO cl_gui_container.
DATA : go_alv_grid  TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout   TYPE lvc_s_layo,
       gs_variant  TYPE disvariant,
       gv_save     TYPE c,
       gs_fieldcat TYPE lvc_s_fcat,
       gt_fieldcat TYPE lvc_t_fcat,
       gt_sort     TYPE lvc_t_sort,
       gs_sort     TYPE lvc_s_sort.

DATA : gv_alv_title1 TYPE c LENGTH 20.

" 딜리버리 아이템을 위한 ALV
DATA : go_container2 TYPE REF TO cl_gui_container.
DATA : go_alv_grid2  TYPE REF TO cl_gui_alv_grid.
DATA : gs_layout2   TYPE lvc_s_layo,
       gs_variant2  TYPE disvariant,
       gv_save2     TYPE c,
       gt_fieldcat2 TYPE lvc_t_fcat.

DATA : gv_alv_title2 TYPE c LENGTH 20.

****************************************
*Docking Container
****************************************
DATA : go_custom_container TYPE REF TO cl_gui_custom_container.
DATA : go_splitter TYPE REF TO cl_gui_splitter_container.

* 토글버튼 제어를 위한 변수
DATA: gs_butn_info  TYPE smp_dyntxt,              " 동적 버튼 제어용 변수
      gv_dock_state TYPE abap_bool VALUE abap_on. " 현재 컨테이너 상태 (X:열림)
* CHECK HIDE CONDITION
DATA: gv_check_hide_cond TYPE abap_bool.


* 조회 조건 출력을 위한 Container 관련 변수
DATA: go_dock_top TYPE REF TO cl_gui_docking_container,
      go_doc      TYPE REF TO cl_dd_document.

* 검색 결과가 0건인 경우 100번 화면으로 안넘어가기 위한 bool
DATA : gv_no_data type bool.
