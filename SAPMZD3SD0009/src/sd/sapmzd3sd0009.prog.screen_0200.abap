PROCESS BEFORE OUTPUT.
  MODULE status_0200.

  MODULE set_alv_0200.

  MODULE init_alv_0200.

  MODULE set_tabstrip_0200.

  CALL SUBSCREEN ref1 INCLUDING sy-repid gv_subscreen.

  MODULE clear_ok_code.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  CALL SUBSCREEN ref1.

  MODULE user_command_0200.
