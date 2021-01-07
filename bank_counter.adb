with System;
with Bank_counter_task; pragma Unreferenced(Bank_counter_task);
with Ada.Text_IO;
use  Ada.Text_IO;

procedure Bank_counter is
  pragma Priority (System.Priority'First);
begin
  null;
end Bank_counter;