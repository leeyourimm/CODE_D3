*&---------------------------------------------------------------------*
*& Include          ZD3SD0009TOP
*&---------------------------------------------------------------------*
REPORT zd3sd0009 MESSAGE-ID zpd3_msg.


TABLES : ztd3sd0001, " 고객 마스터
         ztd3sd0006, " 판매 오더 헤더
         ztd3sd0007, " 판매 오더 아이템
         ztd3sd0008, " 출고 요청 헤더
         ztd3sd0009, " 출고 요청 아이템
         ztd3sd0010, " 대금 청구 헤더
         ztd3sd0011, " 대금 청구 아이템
         ztd3sd0014, " 판매가격 관리
         ztd3sd0015, " 할인
         ztd3fi0005, " 세금 마스터
         ztd3sd0012, " 견적서 헤더
         ztd3sd0013, " 견적서 아이템
         ztd3fi0004, " 전표 아이템
         ztd3fi0013, " 세금계산서 헤더
         ztd3fi0014. " 세금계산서 아이템

" 사용자 입력을 위한 변수
DATA : ok_code LIKE sy-ucomm.



TYPES : BEGIN OF ty_display1.
          INCLUDE STRUCTURE ztd3sd0010.
TYPES :   butxt      TYPE ztd3sd0001-butxt,  " 고객명
          repnm      TYPE ztd3sd0001-repnm,  " 대표자명
          audat      TYPE ztd3sd0006-audat,  " 주문일자
          gross_so   TYPE ztd3sd0006-gross,  " 주문총금액
          listat     TYPE ztd3sd0008-listat, " 출고요청 상태
          type       TYPE ztd3sd0008-type,   " 출고요청 타입
          wsdat      TYPE ztd3sd0008-wsdat,  " 출고 예정일
          wadat      TYPE ztd3sd0008-wadat,  " 실제 출고일
          lfdat      TYPE ztd3sd0008-lfdat,  " 납기 일자
          tytxt      TYPE c LENGTH 20,       " 출고 타입 텍스트
          status     TYPE icon-name,         " 대금 청구 상태 아이콘
          sta_sort   TYPE i,                 " 미청구 건에 대해 위로 표시하기 위한 변수
          make_bill  TYPE c LENGTH 10,       " 청구 상태
          cell_color TYPE lvc_t_scol,        " 출고예정일자와 실제 출고일자가 다를 경우 표시할 색깔
          celltab    TYPE lvc_t_styl,        " 버튼으로 표시하기 위한 변수
        END OF ty_display1.


" 200번에 보여줄 ALV 테이블 타입
TYPES : BEGIN OF ty_display2,
          vbeln  TYPE ztd3sd0006-vbeln,   " 판매오더 번호
          dlrno  TYPE ztd3sd0009-dlrno,   " 출고요청 번호
          posnr  TYPE ztd3sd0009-posnr,   " 출고요청 아이템 번호
          kunnr  TYPE ztd3sd0006-kunnr,   " 고객코드
          kunnm  TYPE ztd3sd0001-butxt,   " 고객명
          vkorg  TYPE ztd3sd0006-vkorg,   " 영업조직
          ordpr  TYPE ztd3sd0007-netwr,   " 금액
          dispr  TYPE ztd3sd0007-netwr,   " 할인액
          netwr  TYPE ztd3sd0007-netwr,   " 공급가액
          taxpr  TYPE ztd3sd0007-netwr,   " 세액
          gross  TYPE ztd3sd0007-gross,   " 총액
          waers  TYPE ztd3sd0006-waers,   " 통화코드
          zterm  TYPE ztd3sd0006-zterm,  " 지급조건
          matnr  TYPE ztd3sd0007-matnr,  " 자재코드
          matnm  TYPE ztd3mm0001-maktx,  " 자재명
          mwskz  TYPE ztd3sd0007-mwskz,  " 세금코드
          kwmeng TYPE ztd3sd0009-kwmeng, " 청구 수량
          meins  TYPE ztd3sd0009-meins,  " 수량 단위
          netpr  TYPE ztd3sd0007-netpr,  " 기준 단가
        END OF ty_display2.


" 전표에 보낼 ITAB TYPE
TYPES : BEGIN OF ty_statement,
          bukrs TYPE ztd3fi0004-bukrs,  " 회사코드
          budat TYPE ztd3fi0003-budat,  " 전기일(대금청구 일자)
          bldat TYPE ztd3fi0003-bldat,  " 증빙일(세금계산서 발행 일자)
          kunnr TYPE ztd3fi0004-kunnr,  " 고객코드
          wrbtr TYPE ztd3fi0004-wrbtr,  " 총액
          waers TYPE ztd3fi0004-waers,  " 통화코드
          mwskz TYPE ztd3fi0004-mwskz,  " 세금코드
          zterm TYPE ztd3fi0004-zterm,  " 지급조건
          vbeln TYPE ztd3fi0004-vbeln,  " 판매오더 번호
        END OF ty_statement.

DATA : gt_statement TYPE TABLE OF ty_statement.
DATA : gs_statement LIKE LINE OF gt_statement.


" 데이터 가공할 변수(헤더)
DATA : gt_delivery_header TYPE TABLE OF ty_display1 WITH NON-UNIQUE KEY dlrno.
DATA : gs_delivery_header LIKE LINE OF gt_delivery_header.

" 데이터 가공할 변수(아이템)
DATA : gt_delivery_item TYPE TABLE OF ty_display2 WITH NON-UNIQUE KEY dlrno.
DATA : gs_delivery_item LIKE LINE OF gt_delivery_item.

" 대금 청구 헤더 테이블(생성될 데이터를 담을 테이블)
DATA : gt_bill_header TYPE TABLE OF ztd3sd0010 WITH NON-UNIQUE KEY vbeln.
DATA : gs_bill_header LIKE LINE OF gt_bill_header.

" 대금 청구 헤더 테이블(이미 생성된 데이터를 담을 테이블)
DATA : gt_bill_header_end TYPE TABLE OF ztd3sd0010 WITH NON-UNIQUE KEY vbeln.
DATA : gs_bill_header_end LIKE LINE OF gt_bill_header_end.

" 대금 청구 아이템 테이블
DATA : gt_bill_item   TYPE TABLE OF ztd3sd0011 WITH NON-UNIQUE KEY vbeln posnr.
DATA : gs_bill_item   LIKE LINE OF gt_bill_item.

" 세금계산서 헤더 테이블
DATA : gt_tax_header   TYPE TABLE OF ztd3fi0013 WITH NON-UNIQUE KEY exnum.
DATA : gs_tax_header   LIKE LINE OF  gt_tax_header.

" 세금계산서 아이템 테이블
DATA : gt_tax_item   TYPE TABLE OF ztd3fi0014 WITH NON-UNIQUE KEY exnum buzei.
DATA : gs_tax_item   LIKE LINE OF  gt_tax_item.

" 데이터가 없다는 것을 알리기 위한 bool.
DATA : gv_no_data TYPE bool.

" 처음 전표 생성할 때 해당 판매오더가 존재하는지 확인하기 위한 bool
DATA : gv_sta_exist TYPE bool.




************************************************
* 검색 조건
************************************************
DATA : gv_bukrs      TYPE ztd3sd0001-bukrs.
DATA : gv_butxt      TYPE ztd3sd0001-butxt.
DATA : gv_repnm      TYPE ztd3sd0001-repnm.
DATA : gv_kunnr_from TYPE ztd3sd0001-kunnr.      " 고객 코드
DATA : gv_kunnr_to   TYPE ztd3sd0001-kunnr.      " 고객 코드
DATA : gv_type       TYPE ztd3sd0008-type.       "
DATA : gv_vbeln_from TYPE ztd3sd0006-vbeln.
DATA : gv_vbeln_to   TYPE ztd3sd0006-vbeln.
DATA : gv_audat_from TYPE ztd3sd0006-audat.
DATA : gv_audat_to   TYPE ztd3sd0006-audat.
DATA : gv_lfdat_from TYPE ztd3sd0008-lfdat.
DATA : gv_lfdat_to   TYPE ztd3sd0008-lfdat.

DATA : gv_ku_from TYPE ztd3sd0001-kunnr.      " 고객 코드
DATA : gv_ku_to   TYPE ztd3sd0001-kunnr.      " 고객 코드
DATA : gv_vb_from TYPE ztd3sd0006-vbeln.
DATA : gv_vb_to   TYPE ztd3sd0006-vbeln.
DATA : gv_au_from TYPE ztd3sd0006-audat.
DATA : gv_au_to   TYPE ztd3sd0006-audat.
DATA : gv_lf_from TYPE ztd3sd0008-lfdat.
DATA : gv_lf_to   TYPE ztd3sd0008-lfdat.


**********************************************************
* 100
**********************************************************
" 화면에 보여줄 ALV 변수
" 출고 요약
DATA : gt_display1 TYPE TABLE OF ty_display1 WITH NON-UNIQUE KEY dlrno.
DATA : gs_display1 LIKE LINE OF gt_display1.

" ALV 제목
DATA : gv_alv_title TYPE c LENGTH 15.

* 100번 화면을 위한 변수
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_alv_grid  TYPE REF TO cl_gui_alv_grid.

DATA : gs_layout   TYPE lvc_s_layo.
DATA : gs_fieldcat TYPE lvc_s_fcat.
DATA : gt_fieldcat TYPE lvc_t_fcat.
DATA : gs_variant  TYPE disvariant.
DATA : gv_save     TYPE c.

DATA : gv_title TYPE sy-title.

" 타입 리스트 박스
DATA: gt_gjahr_type TYPE vrm_values,
      gs_gjahr_type TYPE vrm_value.




**********************************************************
* 200
**********************************************************
" 화면 200에서 띄울 ALV 변수
DATA : go_container2 TYPE REF TO cl_gui_custom_container.
DATA : go_alv_grid2  TYPE REF TO cl_gui_alv_grid.

DATA : gt_display2 TYPE TABLE OF ty_display2.
DATA : gs_display2 LIKE LINE OF gt_display2.

DATA : gs_layout2   TYPE lvc_s_layo.
DATA : gt_fieldcat2 TYPE lvc_t_fcat.
DATA : gs_variant2  TYPE disvariant.
DATA : gv_save2     TYPE c.


" 전표에 보낼 청구일자 변수
DATA : gv_bldat TYPE ztd3sd0010-fkdat.
" 공급가액
DATA : gv_netwr TYPE ztd3sd0011-netwr.
" 세액
DATA : gv_tax   TYPE ztd3sd0011-netwr.
" 할인코드
DATA : gv_cond_id TYPE ztd3sd0013-cond_id.
" 세금코드
DATA : gv_taxcd   TYPE ztd3sd0013-mwskz.
" 지역코드 텍스트
DATA : gv_retxt TYPE c LENGTH 20.
" 고객유형 텍스트
DATA : gv_kdtxt TYPE c LENGTH 20.
" 국가코드 텍스트
DATA : gv_latxt TYPE c LENGTH 20.
" 지급조건 텍스트
DATA : gv_zttxt TYPE c LENGTH 20.
" 대금청구 번호
DATA : gv_VBELN TYPE ztd3sd0010-vbeln.
" 판매오더 번호
DATA : gv_vbeln_so TYPE ztd3sd0006-vbeln.
" 배송오더 번호
DATA : gv_dlrno TYPE ztd3sd0008-dlrno.
" 영업조직
DATA : gv_vkorg TYPE ztd3sd0006-vkorg.
" 세금코드
DATA : gv_waers TYPE ztd3sd0006-waers.
" 지급조건
DATA : gv_zterm TYPE ztd3sd0001-zterm.
" 대금청구 상태
DATA : gv_vbstat TYPE ztd3sd0010-vbstat.
" 세후 금액
DATA : gv_gross TYPE ztd3sd0006-gross.
" 세전 금액
DATA : gv_net   TYPE ztd3sd0011-netwr.
" 총 금액
DATA : gv_tot_gross TYPE ztd3sd0010-gross.

" 대금청구 시점과 견적 시점 사이에 가격 변동 시, 띄울 팝얼을 위한 BOOL
DATA : gv_price_change TYPE bool.

" 팝업에 대한 확인 버튼을 클릭 시, 다음 로직을 실행하기 위한 BOOL
DATA : gv_ok TYPE bool.

" 실제 DB에 저장하기 위한 BOOL
DATA : gv_save_bool TYPE bool.

" 청구 생성 버튼 누른 행 저장을 위한 변수
DATA : gv_tabnm TYPE sy-tabix.

" 처음 프로그램 시작할 때만 데이터를 ITAB에 저장하기 위한 변수
DATA : gv_start TYPE bool.

" 저장할 데이터가 없을 때 알려주기 위한 로직
DATA : gv_not_initail TYPE bool.

" 지급조건 기간 범위 세팅 변수
DATA : gv_lfdat_valid TYPE bool.

" 실제 DB에 반영되었는지 체크하는 Bool
DATA : gv_no_save TYPE bool.

" 다른 프로그램으로 넘어가기 위한 bool
DATA : gv_move_pro TYPE bool.

*******************************************************************
* 201 202 203
*******************************************************************
CONTROLS: tab TYPE TABSTRIP.

DATA gv_subscreen TYPE sy-dynnr.

TYPES : BEGIN OF ty_display4.
          INCLUDE STRUCTURE ztd3sd0008.
TYPES :   matnr TYPE ztd3sd0009-matnr,  " 고객명
        END OF ty_display4.


* 202
DATA gt_delivery TYPE TABLE OF ty_display4.
DATA gs_delivery LIKE LINE OF gt_delivery.

DATA : go_container3 TYPE REF TO cl_gui_custom_container,
       go_alv_grid3  TYPE REF TO cl_gui_alv_grid.

DATA : gs_layout3   TYPE lvc_s_layo.
DATA : gs_fieldcat3 TYPE lvc_s_fcat.
DATA : gt_fieldcat3 TYPE lvc_t_fcat.
DATA : gs_variant3  TYPE disvariant.
DATA : gv_save3     TYPE c.

DATA : gv_icon1      TYPE icon_d.
DATA : gv_icon2      TYPE icon_d.
