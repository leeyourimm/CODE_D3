*&---------------------------------------------------------------------*
*& Include          ZRD3FI9010_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CREATE'.

      " 금액 상세 보기 버튼이 기본값으로 보이게
      PERFORM set_gv_amt_detail_default.

      " tab1이 기본값으로 맨 처음에 보이게
      PERFORM clear_activetab.

      " 200번 화면으로 이동
      PERFORM select_index.


  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.

    WHEN 'FC1' OR 'FC2' OR 'FC3' OR 'FC4'.
      tab-activetab = ok_code.
      CLEAR ok_code.
      LEAVE TO SCREEN 200.

    WHEN 'APPROVE'.
      PERFORM popup_to_confirm USING ok_code
                                     gv_ok.
      PERFORM update_tax_db.
      PERFORM update_tax_itab.
      PERFORM refresh_alv_0100.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
