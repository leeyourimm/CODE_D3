PROCESS BEFORE OUTPUT.
  MODULE status_0110.

  MOdule set_alv_0110.

  MODULE dync_alv_0110.

  MODULE clear_ok_code.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_plan_year.
    FIELD gv_plan_vkorg.
    FIELD gv_plan_month.
    FIELD gv_plan_matnr.
    FIELD gv_plan_menge.
    MODULE check_required_0110.
  ENDCHAIN.


  MODULE user_command_0110.

" 서치헬프 선택에 따라 다른 필드 자동으로 채워짐
" 자재 번호에 따른 자재명, 자재 유형
PROCESS ON VALUE-REQUEST.
  FIELD gv_plan_matnr MODULE f4_gv_plan_matnr.
