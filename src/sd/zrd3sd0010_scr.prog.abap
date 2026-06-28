*&---------------------------------------------------------------------*
*& Include          ZRD3SD9010_SCR
*&---------------------------------------------------------------------*

************************************************************************
*회사코드 :
*대금 청구 번호 :
*고객코드 :
*고객명 :
*대금청구 일자  :
************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.



  SELECT-OPTIONS : so_bu FOR ztd3sd0010-bukrs  NO INTERVALS NO-EXTENSION DEFAULT 1000.
  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS : so_vb FOR ztd3sd0010-vbeln,
                   so_vs FOR ztd3sd0010-vbeln_so,
                   so_vd FOR ztd3sd0010-dlrno,
                   so_cu FOR ztd3sd0010-kunnr    MATCHCODE OBJECT zshd3sd0001,
                   so_bd FOR ztd3sd0010-fkdat NO-EXTENSION.

  SELECTION-SCREEN SKIP.

  PARAMETERS: pa_mrow TYPE i DEFAULT 100 .

SELECTION-SCREEN END OF BLOCK b01.
