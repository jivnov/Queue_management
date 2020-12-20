with System;
with Manager_task; pragma Unreferenced(Manager_task);
with Ada.Text_IO;
use  Ada.Text_IO;

procedure Manager is
  pragma Priority (System.Priority'First);
begin
  loop
    null;
  end loop;
end Manager;