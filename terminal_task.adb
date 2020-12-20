with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_Io;
--  with GNAT.OS_Lib;

package body Terminal_task is



  task body Position is

    Address : Sock_Addr_Type;
    Socket  : Socket_Type;
    Channel : Stream_Access;
    Get_position : Integer;
    Get_number   : Integer;

  begin


    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);

    Address.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port => ("&Image(Address)&")");
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Connect_Socket (Socket, Address);


    Channel := Stream (Socket);
loop
    Put_Line("Wprowadż 1 żeby dostać numer w kolejce: ");
    Get(Get_number);

    Integer'Output (Channel, Get_number);


    Get_position := Integer'Input (Channel);

    if Get_position /= 0 then
        Put_Line ("Pozycja w kolejce: " & Get_position'Img);
    end if;

end loop;

  end Position;

end Terminal_task;