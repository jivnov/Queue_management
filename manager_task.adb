package body Manager_task is

    task body Terminal_Client is -- określenie ilości klientów w kolejce
    begin
        accept Start;
        loop
            select
                accept GetPositionInQueue do
                    Position := Position + 1; -- numer nowego klienta
                    Put_Line("Numer klenta: " & Position'Img); -- wypisywanie numera
                end GetPositionInQueue;
            or
                accept GetPositionInPriorityQueue do
                    PriorityPosition := PriorityPosition + 1; -- numer nowego prior. klienta
                    Put_Line("Numer klienta: " & PriorityPosition'Img);
                end GetPositionInPriorityQueue;
            or
                accept Finish;
                exit;
            end select;
        end loop;
    end Terminal_Client;


    task body Terminal_Manager is -- określenie pierwszego klienta w kolejkach
    begin
    accept Start;
        loop
            select
                accept TakeFromQueue do
                    QueueCounter := QueueCounter + 1; -- pierwzy numer w kolejce zwykłej
                end TakeFromQueue;
            or
                accept TakeFromPriorityQueue do
                    PriorityQueueCounter := PriorityQueueCounter + 1; -- pierwzy numer w kolejce prior.
                end TakeFromPriorityQueue;
            or
                accept Finish;
                exit;
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
            if ExitVar = 0 then -- wysyłanie żądania zakończenia programu
                Integer'Output(Channel_manager, ExitVar);
            end if;
            if Acception /= 0 then -- czekamy na zwolnienie operatora
                Acception := Integer'Input (Channel_manager);
            elsif Acception = 0 then -- jak dostaniemy 0 sprawdzamy czy są nowe osoby w kolejce prior.
                if PriorityPosition >= PriorityQueueCounter then
                    Terminal_Manager.TakeFromPriorityQueue; -- zmieniamy numer pierwszego klienta
                    Acception := Acception + 1; -- zmieniamy licznik po wysłaniu nowego numera klienta
                    Integer'Output(Channel_manager, PriorityQueueCounter-1); -- wysyłamy
                elsif Position >= QueueCounter then -- jak nie, to sprawdzamy czy są nowe osoby w kolejce zwykłej
                    Terminal_Manager.TakeFromQueue;
                    Acception := Acception + 1;
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
        Put_Line("Wprowadż liczbę żeby dostać numer w kolejce lub 0 żeby skończyć");
        Put_Line("1 - kolejka zwykła; 2 - kolejka dla osób upoważnionych:");
        Get(Get_number); -- wprowadzenie licczby od użytkownika

        if Get_number = 1 then
            Terminal_Client.GetPositionInQueue; -- zapisywanie do kolejki zwykłej
        elsif Get_number = 2 then
            Terminal_Client.GetPositionInPriorityQueue; -- zapisywanie do kolejki prior.
        elsif Get_number = 0 then -- zakończenie działanie programu jeżeli użytkownik wprowadzi 0
            ExitVar := 0;
            Put_Line ("Zakończenie");
            Terminal_Client.Finish;
            Terminal_Manager.Finish;
            exit;
        else
            Put_Line ("Nieznana liczba"); -- liczby poza 0,1,2 nie są przyjmowane
        end if;
    end loop;
end Manager_task;
