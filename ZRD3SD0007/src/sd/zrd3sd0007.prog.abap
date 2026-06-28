*&---------------------------------------------------------------------*
*& Report ZRD3SD9007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
* 서치헬프 연관된 데이터 고려해보기

REPORT zrd3sd0007 MESSAGE-ID zpd3_msg.

INCLUDE ZRD3SD0007_TOP.
INCLUDE ZRD3SD0007_SCR.
INCLUDE ZRD3SD0007_CLS.
INCLUDE ZRD3SD0007_PBO.
INCLUDE ZRD3SD0007_PAI.
INCLUDE ZRD3SD0007_F01.

INITIALIZATION.

  PERFORM set_init_data.

AT SELECTION-SCREEN ON pa_mrow.
  PERFORM check_max_row.

START-OF-SELECTION.

  PERFORM select_data.

  PERFORM modify_data.

  PERFORM display_data.
