package body Manager_task is
    QueueCounter         : Natural := 1;
    PriorityQueueCounter : Natural := 1001;
    Position             : Natural := 0;
    PriorityPosition     : Natural := 1000;
    Get_number           : Integer;
    Acception            : Integer;

    task body Terminal_Client is
    begin
        accept Start;
        loop
            select
                accept GetPositionInQueue do
                    Position := Position + 1; -- position in variable with queue
                    Put_Line("Numer klenta: " & Position'Img);
                end GetPositionInQueue;
                or
                accept GetPositionInPriorityQueue do
                    PriorityPosition := PriorityPosition + 1;
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
                end TakeFromQueue;
                or
                accept TakeFromPriorityQueue do
                    PriorityQueueCounter := PriorityQueueCounter + 1;
                end TakeFromPriorityQueue;
            end select;
        end loop;
    end Terminal_Manager;




    task body Manage_Bank_Operators is
        Address_manager  : Sock_Addr_Type;
        Server_manager   : Socket_Type;
        Socket_manager   : Socket_Type;
        Channel_manager  : Stream_Access;
    begin
        Address_manager.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
        Address_manager.Port := 5875;
        Put_Line("Host: "&Host_Name);
        Put_Line("Adres:port = ("&Image(Address_manager)&")");
        Create_Socket (Server_manager);
        Set_Socket_Option (Server_manager, Socket_Level, (Reuse_Address, True));
        Bind_Socket (Server_manager, Address_manager);
        Listen_Socket (Server_manager);
        Accept_Socket (Server_manager, Socket_manager, Address_manager);

        Channel_manager := Stream (Socket_manager);

        loop
            if Acception /= 0 then
                Acception := Integer'Input (Channel_manager);
            elsif Acception = 0 then
            if PriorityPosition >= PriorityQueueCounter then
                Terminal_Manager.TakeFromPriorityQueue;
                Acception := Acception +1;
                Integer'Output(Channel_manager, PriorityQueueCounter-1);
            elsif Position >= QueueCounter then
                Terminal_Manager.TakeFromQueue;
                Acception := Acception +1;
                Integer'Output(Channel_manager, QueueCounter-1);
            end if;
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
