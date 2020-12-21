with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_Io;

package body Bank_counter_task is


   protected type Semaphore_Int (Init_Sem : Integer) is -- counting semaphore
       entry Take_place;
       procedure Free_place;
    private
       Count : Integer := Init_Sem;
    end Semaphore_Int;

   protected body Semaphore_Int is

      entry Take_place when Count > 0 is
       begin
          Count := Count - 1; -- odejmujemy jedno z "miejsc" jezeli zostało zajęto zadaniem
       end Take_place;

      procedure Free_place is
       begin
          Count := Count + 1; -- dodajemy do licznika "miejsce" jak jedno z zadań skońcy działanie
       end Free_place;

   end Semaphore_Int;

    S : Semaphore_Int (2);



    procedure Okno1(K : Integer) is

    begin
      S.Take_place;
      Put_Line("Okno "& K'Img &", zajęty" );
      delay 1.0;
      Put_Line("Okno "& K'Img &", wolny");
      S.Free_place;
      end Okno1;


  task body Counter is

  --      Address : Sock_Addr_Type;
  --      Socket  : Socket_Type;
  --      Channel : Stream_Access;
  begin

--  Put_Line ("OK");

    loop
    Okno1(12);
    end loop;


--      Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
--
--      Address.Port := 5875;
--      Put_Line("Host: "&Host_Name);
--      Put_Line("Adres:port => ("&Image(Address)&")");
--      Create_Socket (Socket);
--      Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
--      Connect_Socket (Socket, Address);
--
--
--      Channel := Stream (Socket);
--  loop
--      Put_Line ("wysyłam ");
--      Integer'Output (Channel, 1234);
--
--
--
--    end loop;

  end Counter;

end Bank_counter_task;