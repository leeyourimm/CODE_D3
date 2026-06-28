*&---------------------------------------------------------------------*
*& Report ZRDFI9010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* 세금계산서 헤더 내의 상태
* 기능
* 세금계산서 출력되면 대금청구 테이블에 상태 필드 변경되게


REPORT zrd3fi9010 MESSAGE-ID zpd3_msg.

INCLUDE zrd3fi9010_top. " 전역변수
INCLUDE zrd3fi9010_scr. " Selection Screen
INCLUDE zrd3fi9010_cls. " Local Class
INCLUDE zrd3fi9010_pbo. " PBO 모듈
INCLUDE zrd3fi9010_pai. " PAI 모듈
INCLUDE zrd3fi9010_f01. " Subroutines

*&---------------------------------------------------------------------*
*& ABAP Event
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
INITIALIZATION.
*--------------------------------------------------------------------*
  PERFORM initialization.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_mrow.
*--------------------------------------------------------------------*

  PERFORM check_max_row.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_kun-low.
  PERFORM f4_kunnr_low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_kun-high.
  PERFORM f4_kunnr_high.

*--------------------------------------------------------------------*
START-OF-SELECTION.
*--------------------------------------------------------------------*

  PERFORM select_data.
  PERFORM modify_data.
  PERFORM display_data.
