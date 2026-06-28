PROCESS BEFORE OUTPUT.
  MODULE status_0100.

  MODULE set_alv_0100.

  MODULE init_alv_0100.

  MODULE clear_ok_code.
*
PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_kunnr_from.
    FIELD gv_kunnr_to.
    FIELD gv_vbeln_from.
    FIELD gv_vbeln_to.
    FIELD gv_audat_from.
    FIELD gv_audat_to.
    FIELD gv_lfdat_from.
    FIELD gv_lfdat_to.
    MODULE check_required_0100.
  ENDCHAIN.

  MODULE user_command_0100.
