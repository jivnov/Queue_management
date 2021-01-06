with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_Io;

package body Bank_counter_task is
    NextInQueue : Natural := 0;
    Gen: Generator;
    OpID : Natural := 0;

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

    S : Semaphore_Int (1);


    procedure ServeClient(K : Natural; Cl : Integer) is
       DelayTime : Float := 1.0;
    begin
      Reset(Gen);
      DelayTime := Random(Gen) * 4.0 + 1.0; -- klient moze byc obslugiwany przez od 1 do 5 sekund
      --S.Take_place;
      Put_Line("Operator "& K'Img &", obsluguję klienta nr. " & Cl'Img);
      delay Standard.Duration(DelayTime);
      Put_Line("Operator "& K'Img &", wolny");
      --S.Free_place;
    end ServeClient;


    task body Operator is
        ClientID : Natural := 100500;
        BreakAfter: Integer := 20;
        isFree : Boolean := True;
    begin
        accept Start do
            Put_Line("Operator " & OperatorID'Img & " rozpoczął pracę.");
        end Start;
        Reset(Gen);
        BreakAfter := Integer(Random(Gen) * 10.0 + 5.0);
        Counter.TakeNextClient(OperatorID);
        loop
            if BreakAfter > 0 then
                select
                    accept TakeClient(Pos: in Integer) do
                        BreakAfter := BreakAfter - 1;
                        ClientID := Pos;
                    end TakeClient;
                    ServeClient(OperatorID, ClientID);
                    delay 1.5;
                    Counter.TakeNextClient(OperatorID);
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

    Operators: array(1..2) of OperatorAccess;

    task body Counter is
      Address : Sock_Addr_Type;
      Socket  : Socket_Type;
      Channel : Stream_Access;
    begin

    Put_Line ("OK");

    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    Address.Port := 5875;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port => ("&Image(Address)&")");
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Connect_Socket (Socket, Address);

    Channel := Stream (Socket);

    for I in 1..2 loop
        Operators(I) := new Operator(I);
        Operators(I).Start;
    end loop;

    loop
        accept TakeNextClient(OperatorID: Natural) do
            NextInQueue := Integer'Input (Channel);
            OpID := OperatorID;
        end TakeNextClient;
        Operators(OpID).TakeClient(NextInQueue);
    end loop;

  end Counter;

end Bank_counter_task;
