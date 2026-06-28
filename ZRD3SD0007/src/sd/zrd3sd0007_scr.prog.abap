*&---------------------------------------------------------------------*
*& Include          ZRD3SD9007_SCR
*&---------------------------------------------------------------------*

" b01 : 기본 검색 조건
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.

  SELECTION-SCREEN SKIP.
  SELECT-OPTIONS : so_dl FOR ztd3sd0008-dlrno MATCHCODE OBJECT zshd3sd0008,
                   so_po FOR ztd3sd0008-vbeln MATCHCODE OBJECT zshd3sd0006,
                   so_wa FOR ztd3sd0008-wadat NO-EXTENSION,
                   so_lf FOR ztd3sd0008-lfdat NO-EXTENSION.

  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN SKIP.
  PARAMETERS: pa_mrow TYPE i. "최대 조회 건수


SELECTION-SCREEN END OF BLOCK b1.

" b02 : 상세 검색 조건
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.

  PARAMETERS : pa_all  TYPE c RADIOBUTTON GROUP g1 DEFAULT 'X'.
  PARAMETERS : pa_ge   TYPE c RADIOBUTTON GROUP g1.
  PARAMETERS : pa_re   TYPE c RADIOBUTTON GROUP g1.

SELECTION-SCREEN END OF BLOCK b2.
