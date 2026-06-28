*&---------------------------------------------------------------------*
*& Report ZRD3SD9010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

* 배송번호에 따른 핫스팟로직 하기
REPORT zrd3sd0010 MESSAGE-ID zpd3_msg.

INCLUDE zrd3sd0010_top.
INCLUDE zrd3sd0010_scr.
INCLUDE zrd3sd0010_cls.
INCLUDE zrd3sd0010_pbo.
INCLUDE zrd3sd0010_pai.
INCLUDE zrd3sd0010_f01.


INITIALIZATION.
  PERFORM set_init_data.

AT SELECTION-SCREEN ON pa_mrow.
  PERFORM check_max_row.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_vb-low.
  PERFORM f4_vbeln.

START-OF-SELECTION.

  PERFORM select_data.

  PERFORM modify_data.

  PERFORM display_data.
