with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_Io;
--  with GNAT.OS_Lib;

package body Manager_task is




  task body Management is

    Address_terminal  : Sock_Addr_Type;
    Server_terminal   : Socket_Type;
    Socket_terminal   : Socket_Type;
    Channel_terminal  : Stream_Access;
    Dane     : Integer := 0;
    Queue    : Manager_task.Int_Array(1..10); -- queue as array
    Position_array : Integer := 1; -- position in array
    Position_queue : Integer := 1; -- position in queue

    Special_Queue       : Manager_task.Int_Array(1..10); -- special queue as array
    Position_spec_array : Integer := 1; -- position in array
    Position_spec_queue : Integer := 1; -- position in queue
    --------
--          Address_counter  : Sock_Addr_Type;
--          Server_counter   : Socket_Type;
--          Socket_counter   : Socket_Type;
--          Channel_counter  : Stream_Access;
--          Dane2     : Integer := 0;

  begin
--            Address_counter.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
--
--            Address_counter.Port := 5875;
--            Put_Line("Host: "&Host_Name);
--            Put_Line("Adres:port = ("&Image(Address_counter)&")");
--            Create_Socket (Server_counter);
--            Set_Socket_Option (Server_counter, Socket_Level, (Reuse_Address, True));
--            Bind_Socket (Server_counter, Address_counter);
--            Listen_Socket (Server_counter);
--            Accept_Socket (Server_counter, Socket_counter, Address_counter);
--
--            Channel_counter := Stream (Socket_counter);

    Address_terminal.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);

    Address_terminal.Port := 5876;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port = ("&Image(Address_terminal)&")");
    Create_Socket (Server_terminal);
    Set_Socket_Option (Server_terminal, Socket_Level, (Reuse_Address, True));
    Bind_Socket (Server_terminal, Address_terminal);
    Listen_Socket (Server_terminal);
    Accept_Socket (Server_terminal, Socket_terminal, Address_terminal);


    Channel_terminal := Stream (Socket_terminal);

loop

    Dane := Integer'Input (Channel_terminal);



    if Position_array = 10 then -- renew enumeration in array when got max
        Position_array := 1;
    end if;

    if Dane = 1 then -- check input, if not 1 or 2 -- repeat

        Queue (Position_array) := Position_array;


--      for Idx in Queue'First .. (Queue'Last) loop
--          Put_Line ("Element(" & Idx'Img & ") = " & Queue (Idx)'Img);
--      end loop;


        Integer'Output (Channel_terminal, Position_queue);

        Position_array := Position_array+1;
        Position_queue := Position_queue+1;

    elsif Dane = 2 then

        Special_Queue (Position_spec_array) := Position_spec_array;

        Integer'Output (Channel_terminal, Position_spec_queue);

        Position_spec_array := Position_spec_array+1;
        Position_spec_queue :=  Position_spec_queue+1;
        Position_queue := Position_queue+1;

    else
        Integer'Output (Channel_terminal, 0);

    end if;

end loop;

  end Management;

end Manager_task;