*&---------------------------------------------------------------------*
*& Include ZD3SD0008TOP                             - Module Pool      SAPMZD3SD9008
*&---------------------------------------------------------------------*
PROGRAM sapmzd3sd0008 MESSAGE-ID zpd3_msg.
CLASS lcl_event_handler DEFINITION DEFERRED.

*---------------------------------------------------------------------*
* TABLES
*---------------------------------------------------------------------*
TABLES : ztd3sd0005. " 판매계획 아이템 테이블
TABLES : ztd3sd0004. " 판매계획 헤더 테이블
TABLES : ztd3mm0001. " 자재 마스터 테이블
TABLES : ztd3sd0006. " 판매오더 헤더 테이블
TABLES : ztd3sd0007. " 판매오더 아이템 테이블
TABLES : ztd3pp0006. " PIR 헤더
TABLES : ztd3pp0007. " PIR 아이템


DATA : ok_code LIKE sy-ucomm.




" 100번 화면 ALV 변수
TYPES : BEGIN OF ty_display.
          INCLUDE TYPE zsd3sd0004.
TYPES :   vktxt      TYPE c LENGTH 10,             " 영업조직 텍스트
          cell_color TYPE lvc_t_scol,              " 셀 색상
          line_color TYPE c LENGTH 4,              " 행 색상
          celltab    TYPE lvc_t_styl,
          icon       TYPE icon_d,
        END OF ty_display.

DATA: gt_display     TYPE STANDARD TABLE OF ty_display,
      gs_display     LIKE LINE  OF gt_display,

      " 데이터 바뀜 유무를 확인하기 위한 변수
      " 바뀐 데이터를 통해 나가기 버튼 누를 시, 팝업을 띄우기 위해 필요
      gt_display_old TYPE STANDARD TABLE OF ty_display,          " 변경 전 데이터를 저장하기 위한 임시 ITAB.
      gs_display_old LIKE LINE  OF gt_display_old.               " 변경 전 데이터를 저장하기 위한 임시 ST.

" DB에 저장 + 새로 생성된 아직 저장 안된 판매계획을 담을 변수
" 140번 화면에서 해당 변수를 통해 ALV에 띄울 데이터를 결정하기 위해 필요
DATA : gt_plan_all TYPE STANDARD TABLE OF ty_display,
       gs_plan_all LIKE LINE OF gt_plan_all.

" DB에 저장 안된 새로 생성된 아직 저장 안된 판매계획을 담을 변수
" 새로 추가된 데이터임을 알리기 위해 필요
DATA : gt_plan_new TYPE STANDARD TABLE OF ty_display,
       gs_plan_new LIKE LINE OF gt_plan_all.

" 테이블 개수를 저장하기 위한 변수
DATA : gv_count TYPE i.


" 작년 판매량 타입 지정
TYPES  : BEGIN OF ty_layear_sum,
           month  TYPE c LENGTH 2,
           matnr  TYPE ztd3sd0007-matnr,
           vkorg  TYPE ztd3sd0001-vkorg,
           kwmeng TYPE ztd3sd0007-kwmeng,
         END OF ty_layear_sum.

" 전체 제품의 작년 판매량 합계를 위한 변수
DATA : gt_layear_sum TYPE TABLE OF ty_layear_sum.
DATA : gs_layear_sum LIKE LINE OF gt_layear_sum.

TYPES  : BEGIN OF ty_layear_sum2,
           month  TYPE c LENGTH 2,
           matnr  TYPE ztd3sd0007-matnr,
           kwmeng TYPE ztd3sd0007-kwmeng,
         END OF ty_layear_sum2.

" 전페 제품의 작년 판매량(영업조직 합계) 합계를 위한 변수
DATA : gt_layear_sum2 TYPE TABLE OF ty_layear_sum2.
DATA : gs_layear_sum2 LIKE LINE OF gt_layear_sum2.



" 판매계획번호가 존재하는 날짜만 저장하는 변수
DATA : gt_year TYPE TABLE OF gjahr.

" 선택한 제품의 작년 판매량 합계를 위한 변수
DATA : gt_sel_layear_sum TYPE TABLE OF ty_layear_sum.
DATA : gs_sel_layear_sum LIKE LINE OF gt_layear_sum.

" 입력값을 저장하기 위한 변수
DATA : gv_year_from TYPE gjahr.
DATA : gv_year_to   TYPE gjahr.
DATA : gv_month_from TYPE c LENGTH 2.    " 조회 시작 월
DATA : gv_month_to   TYPE c LENGTH 2.    " 조회 끝 월
DATA : gv_matnr_from TYPE ztd3mm0001-matnr.
DATA : gv_matnr_to   TYPE ztd3mm0001-matnr.
DATA : gv_plnnr_from TYPE ztd3sd0004-plnnr.
DATA : gv_plnnr_to TYPE ztd3sd0004-plnnr.
DATA : gv_vkorg_from TYPE ztd3sd0004-vkorg.
DATA : gv_vkorg_to TYPE ztd3sd0004-vkorg.

DATA : gv_plnnr TYPE ztd3sd0004-plnnr.
DATA : gv_matnr TYPE ztd3mm0001-matnr.


****************************************************
* 플래그
****************************************************
" ALV에 값이 바뀌면 true로 전환, DB에 반영되면 false로 전환하기 위한 BOOL
" 값이 true이면 뒤로가기 전에 팝업을 띄우기 위한 변수
DATA : gv_change_alv TYPE abap_bool.

" 110번 화면에서 생성한 데이터를 DB에 저장하기 위한 BOOL
DATA : gv_after_0110 TYPE bool.

" ALV 내 변경된 데이터를 DB에 업데이트를 하기 위한 BOOL
DATA : gv_after_edit TYPE bool.

" kpi 모드 on/off 설정하기 위한 BOOL
DATA : gv_kpi_on TYPE bool.

" 데이터 수정/조회 설정하기 위한 BOOL
DATA : gv_edit TYPE bool.

" 프로그램 처음 시작 시와 끝날 시 gt_display_db의 값 반영 여부를 보기 위해 처음 한번만 gt_display_db에 데이터를 넣기 위한 BOOL
DATA : gv_start TYPE bool.

" 140번 화면에서 생성한 데이터를 DB에 저장하기 위한 BOOL
DATA : gv_after_0140 TYPE bool.

" 검색된 결과가 없다는 것을 알리기 위한 Bool
DATA : gv_no_count TYPE bool.

" 이미 리프레시 됐다는 것을 알리기 위한 Bool
DATA : gv_already TYPE bool.

" 입력 결과가 잘못됐다는 것을 알리기 위한 Bool
DATA : gv_sherr TYPE bool.

" KPI 확인했다는 것을 알리기 위한 Bool
DATA : gv_kpi_ok TYPE bool.

" 퍼센테이지 필수 bool
DATA : gv_per_ob TYPE bool.



" 스크린 리스트박스
TYPE-POOLS: vrm.


" 데이터베이스에 저장하기 위한 변수
DATA : gt_insert_header TYPE TABLE OF ztd3sd0004.
DATA : gs_insert_header LIKE LINE OF  gt_insert_header.
DATA : gt_insert_item   TYPE TABLE OF ztd3sd0005.
DATA : gs_insert_item   LIKE LINE OF  gt_insert_item.


**************************************************
* 100
**************************************************
" 프로그램 실행 시 1번만 실행시키기 위한 변수
DATA : gv_vrm_init TYPE bool.

DATA : gv_ym_from TYPE c LENGTH 6.
DATA : gv_ym_to   TYPE c LENGTH 6.

DATA : gv_mn_from TYPE ztd3mm0001-matnr.
DATA : gv_mn_to TYPE ztd3mm0001-matnr.

DATA : gv_pn_from TYPE ztd3sd0004-plnnr.
DATA : gv_pn_to TYPE ztd3sd0004-plnnr.

DATA : gv_vk_from TYPE ztd3sd0004-vkorg.
DATA : gv_vk_to TYPE ztd3sd0004-vkorg.

" 년도 스크린 리스트박스(조회용-전체)
DATA: gt_gjahr_year TYPE vrm_values,
      gs_gjahr_year TYPE vrm_value.

" 월 스크린 리스트박스(조회용-전체)
DATA: gt_gjahr_month TYPE vrm_values,
      gs_gjahr_month TYPE vrm_value.

" 판매계획을 위한 ALV
DATA : go_container TYPE REF TO cl_gui_custom_container.
DATA : go_alv_grid  TYPE REF TO cl_gui_alv_grid.


DATA : gs_layout TYPE   lvc_s_layo.
DATA : gs_fieldcat TYPE lvc_s_fcat.
DATA : gt_fieldcat TYPE lvc_t_fcat.
DATA : gs_variant  TYPE disvariant.
DATA : gv_save     TYPE c.

" MRP 조회 미반영
DATA : gv_ch1      TYPE c.
" 이번달까지의 데이터 조회 미반영
DATA : gv_ch2      TYPE c.


" 제목 설정
DATA : gv_title LIKE sy-title.
DATA : gv_alv_title  TYPE text30.



**************************************************
* 110
**************************************************
" 자재 스크린 리스트박스
DATA: gt_list_mantr TYPE vrm_values,
      gs_list_mantr TYPE vrm_value.

" 영업조직 스크린 리스트박스
DATA: gt_gjahr_vkorg TYPE vrm_values,
      gs_gjahr_vkorg TYPE vrm_value.


" 스크린 리스트박스(생성용-다음달부터)
DATA : gv_plan_month TYPE c LENGTH 2.        " 계획 월
DATA : gv_plan_year  TYPE c LENGTH 4.        " 계획년도
DATA : gv_plan_vkorg TYPE ztd3sd0004-vkorg.  " 영업조직
DATA : gv_plan_matnr TYPE ztd3mm0001-matnr.  " 자재번호
DATA : gv_plan_menge TYPE ztd3sd0005-menge.  " 계획수량
DATA : gv_plan_meins TYPE ztd3sd0005-meins.  " 수량단위
DATA : gv_plan_matnm TYPE ztd3mm0001-maktx.  " 자재명
DATA : gv_plan_mtart TYPE ztd3mm0001-mtart.  " 자재 유형
DATA : gv_plan_werks TYPE ztd3sd0005-werks.  " 플랜트 번호


" 프로그램 실행 시 1번만 실행시키기 위한 변수 "
DATA : gv_vrm_init2 TYPE bool.  " 월
DATA : gv_vrm_init3 TYPE bool.  " 자재번호
DATA : gv_vrm_init4 TYPE bool.  " 영업번호




*****************************************************
* 120
****************************************************
TYPES: BEGIN OF ty_chart,
         month  TYPE c LENGTH 2,
         vkorg  TYPE ztd3sd0006-vkorg,
         kwmeng TYPE kwmeng,
       END OF ty_chart.

DATA: gt_chart TYPE STANDARD TABLE OF ty_chart,
      gs_chart TYPE ty_chart.

DATA : gv_chart_matnr  TYPE ztd3mm0001-matnr.
DATA : gv_chart_vkorg  TYPE ztd3sd0006-vkorg.
DATA : gv_chart_maktx  TYPE ztd3mm0001-maktx.

*" 차트를 위한 ALV
DATA : go_container2 TYPE REF TO cl_gui_custom_container,
       go_chart      TYPE REF TO cl_gui_chart_engine,
       go_ixml       TYPE REF TO if_ixml,
       go_streamfac  TYPE REF TO if_ixml_stream_factory.

DATA: gv_chart_xdata TYPE xstring,
      gv_chart_xcust TYPE xstring.


******************************************************************
* 130
******************************************************************
DATA: gv_op1 TYPE c LENGTH 1, " 단건 조회
      gv_op2 TYPE c LENGTH 1. " 다건 조회

******************************************************************
* 140
******************************************************************
DATA: go_custom_container TYPE REF TO cl_gui_custom_container,
      go_splitter         TYPE REF TO cl_gui_splitter_container,
      go_container3       TYPE REF TO cl_gui_container,
      go_container4       TYPE REF TO cl_gui_container,
      go_tree             TYPE REF TO cl_gui_alv_tree,
      go_alv_grid4        TYPE REF TO cl_gui_alv_grid.

DATA: gt_mat TYPE TABLE OF ztd3mm0001,
      gs_mat LIKE LINE OF gt_mat.



DATA: gs_hierarchy_header TYPE treev_hhdr.

" 판매계획을 위한 디스플레이
TYPES : BEGIN OF ty_display2,
          plan_vkorg TYPE ztd3sd0004-vkorg,       " 영업조직
          plan_year  TYPE ztd3sd0004-plan_month,  " 계획 년도
          plan_month TYPE ztd3sd0004-plan_month,  " 계획 달
          plan_matnr TYPE ztd3sd0005-matnr,       " 계획 자재번호
          plan_matnm TYPE ztd3mm0001-maktx,       " 계획 자재명
          plan_menge TYPE ztd3sd0005-menge,       " 계획 수량
          plan_meins TYPE ztd3sd0005-meins,       " 계확 수량 단위
          plan_werks TYPE ztd3sd0005-werks,
          cell_color TYPE lvc_t_scol,              " 셀 색상
        END OF ty_display2.


DATA: gt_display4 TYPE STANDARD TABLE OF ty_display2,
      gs_display4 LIKE LINE  OF gt_display4.

" 행 삭제될 때 비교할 변수
DATA: gt_display4_old TYPE STANDARD TABLE OF ty_display2,
      gs_display4_old LIKE LINE OF gt_display4_old.

" 일부 행 삭제할 때 삭제 버퍼
DATA: gt_plan_deleted TYPE STANDARD TABLE OF ty_display2,
      gs_plan_deleted LIKE LINE OF gt_plan_deleted.
"
DATA: go_event_handler TYPE REF TO lcl_event_handler.

DATA : gt_fieldcat3 TYPE lvc_t_fcat.
DATA : gt_fieldcat4 TYPE lvc_t_fcat.
DATA : gs_layout4   TYPE lvc_s_layo.
DATA : gs_variant4  TYPE disvariant.
DATA : gv_save4 TYPE c.

DATA : gt_dummy TYPE STANDARD TABLE OF ztd3mm0001.



TYPES: BEGIN OF ty_tree_map,
         node_key TYPE lvc_nkey,
         matnr    TYPE ztd3mm0001-matnr,
       END OF ty_tree_map.

DATA: gt_tree_map TYPE STANDARD TABLE OF ty_tree_map,
      gs_tree_map TYPE ty_tree_map.



" 변경 확인 팝업에 대한 확인 버튼을 눌렀을 때를 저장하기 위한 Bool
DATA : gv_ok  TYPE c.


" 사용자 입력값 확인을 위한 BOOL
DATA : gv_valid_bool TYPE c.

**********************************************************************
* 150
**********************************************************************
DATA : gv_before_dynnr TYPE i.
DATA : gv_op3 TYPE c. " 작년도 판매량 기준
DATA : gv_op4 TYPE c. " PIR 기준
DATA : gv_op5 TYPE c. " 작년도 + PIR 반반

DATA : gt_pir TYPE TABLE OF zsd3sd0025.
DATA : gs_pir LIKE LINE OF gt_pir.

" 전년도 대비 퍼센트 비율
DATA : gv_per TYPE i.

**********************************************************************
* 160
**********************************************************************
DATA : gv_kpi_desc TYPE string.
DATA : gv_yellow   TYPE string.
DATA : gv_red      TYPE string.

DATA : gv_kpi_no   TYPE bool.
