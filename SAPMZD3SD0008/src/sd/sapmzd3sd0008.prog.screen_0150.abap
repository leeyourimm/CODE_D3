PROCESS BEFORE OUTPUT.
  MODULE status_0150.

  MODULE set_screen_0150.


  MODULE clear_ok_code.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_per.
    FIELD gv_op3.
    FIELD gv_op3.
    MODULE check_required_0150.
  ENDCHAIN.

  MODULE user_command_0150.
