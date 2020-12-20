with System;
with Terminal_task; pragma Unreferenced(Terminal_task);
with Ada.Text_IO;
use  Ada.Text_IO;

procedure Terminal is
  pragma Priority (System.Priority'First);
begin
  loop
    null;
  end loop;
end Terminal;