with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Discrete_Random, Ada.Numerics.Float_Random, GNAT.Sockets;
use Ada.Text_IO, GNAT.Sockets, Ada.Numerics.Float_Random,  Ada.Integer_Text_IO;

package body Manager_task is
    QueueCounter         : Natural := 1;
    PriorityQueueCounter : Natural := 101;
    Position             : Natural := 0;
    PriorityPosition     : Natural := 100;
--      FirstInQueue         : Natural := 0;
--      FirstInPriorityQueue : Natural := 0;
    Get_number           : Integer;


    task body Terminal_Client is
    begin
        accept Start;
        loop
            select
                accept GetPositionInQueue do
                    Position := Position + 1; -- position in variable with queue
--                      QueueCounter := QueueCounter + 1; -- position in queue
                    Put_Line("Numer klenta: " & Position'Img);
                end GetPositionInQueue;
               or
                accept GetPositionInPriorityQueue do
                    PriorityPosition := PriorityPosition + 1;
--                      QueueCounter := QueueCounter + 1;
--                      Position := Position + 1;
                    Put_Line("Numer klienta: " & PriorityPosition'Img);
                end GetPositionInPriorityQueue;
            end select;
        end loop;
    end Terminal_Client;





    task body Terminal_Manager is
    begin
    accept Start;
        loop
            select
                accept TakeFromQueue do
                    QueueCounter := QueueCounter + 1;
--                      FirstInQueue := FirstInQueue + 1;
                end TakeFromQueue;
                or
                accept TakeFromPriorityQueue do
                    PriorityQueueCounter := PriorityQueueCounter + 1;
--                      FirstInPriorityQueue := FirstInPriorityQueue + 1;
                end TakeFromPriorityQueue;
            end select;
        end loop;
    end Terminal_Manager;




    task body Manage_Bank_Operators is
        Address_counter  : Sock_Addr_Type;
        Server_counter   : Socket_Type;
        Socket_counter   : Socket_Type;
        Channel_counter  : Stream_Access;
    begin
        Address_counter.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
        Address_counter.Port := 5875;
        Put_Line("Host: "&Host_Name);
        Put_Line("Adres:port = ("&Image(Address_counter)&")");
        Create_Socket (Server_counter);
        Set_Socket_Option (Server_counter, Socket_Level, (Reuse_Address, True));
        Bind_Socket (Server_counter, Address_counter);
        Listen_Socket (Server_counter);
        Accept_Socket (Server_counter, Socket_counter, Address_counter);

        Channel_counter := Stream (Socket_counter);


--          loop
--              if FirstInPriorityQueue /= 0 then
--                  Integer'Output(Channel_counter, FirstInPriorityQueue);
--              elsif FirstInQueue /= 0 then
--                  Integer'Output(Channel_counter, FirstInQueue);
--              end if;
--          end loop;
        loop
            if PriorityPosition = PriorityQueueCounter then
                Terminal_Manager.TakeFromPriorityQueue;
                Integer'Output(Channel_counter, PriorityPosition);
            elsif Position = QueueCounter then
                Terminal_Manager.TakeFromQueue;
                Integer'Output(Channel_counter, Position);
            end if;
        end loop;

    end Manage_Bank_Operators;

begin

    Terminal_Client.Start;
    Terminal_Manager.Start;
    delay 1.0;

    loop
        Put_Line("Wprowadż liczbę żeby dostać numer w kolejce");
        Put_Line("1 - kolejka zwykła; 2 - kolejka dla osób upoważnionych:");
        Get(Get_number);

        if Get_number = 1 then
            Terminal_Client.GetPositionInQueue;
        elsif Get_number = 2 then
            Terminal_Client.GetPositionInPriorityQueue;
        else
            Put_Line ("Nieznana liczba");
        end if;
    end loop;
end Manager_task;
