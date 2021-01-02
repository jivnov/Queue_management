with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_Io;

package body Bank_counter_task is
    NextInQueue : Natural := 0;
    Gen: Generator;

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




    procedure ServeClient(K : Natural; Cl : Natural) is
       DelayTime : Float := 1.0;
    begin
      Reset(Gen);
      DelayTime := Random(Gen) * 4.0 + 1.0; -- klient moze byc obslugiwany przez od 1 do 5 sekund
      S.Take_place;
      Put_Line("Operator "& K'Img &", obsluguję klienta nr. " & Cl'Img);
      delay Standard.Duration(DelayTime);
      Put_Line("Operator "& K'Img &", wolny");
      S.Free_place;
    end ServeClient;


    task body Operator is
--          ClientID: Natural;
        BreakAfter: Integer := 20;
        isFree : Boolean := True;
    begin
        Reset(Gen);
        BreakAfter := Integer(Random(Gen) * 10.0 + 5.0);
        accept Start;
        Put_Line("Operator " & OperatorID'Img & " rozpoczął pracę.");
        loop
            if BreakAfter > 0 then
                select
                    accept TakeClient(Pos: Natural) do
                        ServeClient(OperatorID, Pos);
                        BreakAfter := BreakAfter - 1;
                    end TakeClient;
                or
                    accept Finish;
                    exit;
                end select;
            else
                -- TRZEBA TO PRZEROBIC ZEBY 2 OPERATORY NA RAZ NIE MIELI PRZERWY
                Put_Line("Operator " & OperatorID'Img & " ma przerwę");
                delay 10.0;
                BreakAfter := Integer(Random(Gen) * 10.0 + 5.0);
            end if;
        end loop;
    end Operator;
    -- jakis task typu break manager

    Op1 : Operator(1);
    Op2 : Operator(2);


    task body Counter is
        Address : Sock_Addr_Type;
      Socket  : Socket_Type;
      Channel : Stream_Access;
    begin

--      Put_Line ("OK");

    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    Address.Port := 5875;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port => ("&Image(Address)&")");
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Connect_Socket (Socket, Address);

    Channel := Stream (Socket);

    Op1.Start;
    Op2.Start;

    loop
        NextInQueue := Integer'Input (Channel);
        Op1.TakeClient(NextInQueue);
        NextInQueue := Integer'Input (Channel);
        Op2.TakeClient(NextInQueue);
    end loop;

  end Counter;

--  begin
--      null;
end Bank_counter_task;
