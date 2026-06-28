*&---------------------------------------------------------------------*
*& Include          ZD3SD0009I01
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
      PERFORM check_change_bill_is_initial.
      IF gv_no_save IS NOT INITIAL.
        PERFORM popup_to_confirm USING ok_code
                                       gv_ok.

        IF gv_ok IS NOT INITIAL.
          LEAVE TO SCREEN 0.
        ELSE.
        ENDIF.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.


    WHEN 'BT1'.
      PERFORM popup_to_confirm USING ok_code
                                     gv_ok.
      PERFORM refresh_search_opt.

    WHEN 'BT2'.
      " 조회 범위 세팅
      PERFORM set_input_data.
      PERFORM select_delivery_header_data.
      PERFORM modify_delivery_header_data.
      PERFORM move_data.
      PERFORM make_button.
      PERFORM refresh_alv_0100.

    WHEN 'REFRESH'.
      PERFORM popup_to_confirm USING ok_code
                               gv_ok.
      PERFORM refresh_screen_0100.

    WHEN 'SAVE'.
      " 저장할 데이터가 없을 때 알려주기 위한 로직
      PERFORM check_gt_initial.
      PERFORM popup_to_confirm USING ok_code
                                     gv_ok.
      PERFORM save_bill.
      PERFORM refresh_screen_0100.

    WHEN 'SEE_BILL'.
      PERFORM see_billing.
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
    WHEN 'FC1' OR 'FC2' OR 'FC3'.
      tab-activetab = ok_code.
      CLEAR ok_code.
      LEAVE TO SCREEN 200.


    WHEN 'CRE_BILL'.

      " 대금청구 당시 가격과 현재 자재 가격 변동 여부로 인한 가격이 일치 안했을 대 알려주기 위한 로직
      PERFORM check_price_change.
      PERFORM popup_to_confirm USING ok_code
                                     gv_ok.
      " 대금청구 DB에 저장할 ITAB 생성
      PERFORM create_billing.
      " 전표 DB에 저장할 ITAB 생성
      PERFORM create_statement.
      " 세금계산서 DB에 저장할 ITAB 생성
      PERFORM create_tax.
      PERFORM make_button.
      PERFORM refresh_alv_0100.



      PERFORM popup_to_confirm  USING ok_code
                                      gv_ok.
      "      PERFORM popup_to_confirm2 USING ok_code
      "                                      gv_ok.

      IF gv_ok IS NOT INITIAL.
        LEAVE TO SCREEN 0.
      ELSE.

      ENDIF.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_GV_KUNNR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_gv_kunnr INPUT.

  PERFORM get_sh_kunnr.

ENDMODULE.
