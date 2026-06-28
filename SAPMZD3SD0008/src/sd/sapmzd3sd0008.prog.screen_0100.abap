PROCESS BEFORE OUTPUT.
  MODULE status_0100.

  MODULE set_screen_0100.

  "MODULE set_screen_app_bt_0100.

  MODULE set_alv_0100.

  MODULE init_alv_0100.

  MODULE clear_ok_code.





PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_year_from.
    FIELD gv_year_to.
    FIELD gv_month_from.
    FIELD gv_month_to.
    FIELD gv_matnr_from.
    FIELD gv_matnr_to.
    FIELD gv_plnnr_from.
    FIELD gv_plnnr_to.
    FIELD gv_vkorg_from.
    FIELD gv_vkorg_to.
    FIELD gv_ch1.
    FIELD gv_ch2.
    MODULE check_required_0100.
  ENDCHAIN.

  MODULE user_command_0100.
