with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_Io;
--  with GNAT.OS_Lib;

package body Manager_task is

  task body Management is

    Address  : Sock_Addr_Type;
    Server   : Socket_Type;
    Socket   : Socket_Type;
    Channel  : Stream_Access;
    Dane     : Integer := 0;
    Queue    : Manager_task.Int_Array(1..10);
    Position : Integer := 1;

  begin

    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);

    Address.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port = ("&Image(Address)&")");
    Create_Socket (Server);
    Set_Socket_Option (Server, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server, Address);
    Listen_Socket (Server);
    Accept_Socket (Server, Socket, Address);


    Channel := Stream (Socket);

loop

    Dane := Integer'Input (Channel);

    if Dane = 1 then

        Queue (Position) := Position;


--      for Idx in Queue'First .. (Queue'Last) loop
--          Put_Line ("Element(" & Idx'Img & ") = " & Queue (Idx)'Img);
--      end loop;


        Integer'Output (Channel, (Queue(Position)));
        Position := Position+1;

    else
        Integer'Output (Channel, 0);

    end if;

end loop;

  end Management;

end Manager_task;