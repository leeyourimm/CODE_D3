*&---------------------------------------------------------------------*
*& Include          ZRD3FI9010_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.

  PARAMETERS : pa_buk LIKE ztd3sd0001-bukrs OBLIGATORY.

  SELECTION-SCREEN SKIP.

  SELECT-OPTIONS : so_gja FOR ztd3fi0013-gjahr NO INTERVALS NO-EXTENSION DEFAULT sy-datum(4).
  SELECT-OPTIONS : so_exn FOR ztd3fi0013-exnum MATCHCODE OBJECT zshd3fi0013,
                   so_bel FOR ztd3fi0013-belnr MATCHCODE OBJECT zshd3fi0014,
                   so_bud FOR ztd3fi0013-bldat NO-EXTENSION,
                   so_kun FOR ztd3sd0001-kunnr,
                   so_but FOR ztd3sd0001-butxt .



  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN SKIP.

  PARAMETERS : pa_mrow  TYPE i DEFAULT 100 .


SELECTION-SCREEN END OF BLOCK b01.
