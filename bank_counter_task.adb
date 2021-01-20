package body Bank_counter_task is

    protected body Break_Manager is

        procedure Take_Break(Approved: out Boolean) is
            begin
                if (Count > 0) then
                    Approved := True; -- jeśli można pójść na przerwę, zwracamy Approved = True
                    Count := Count - 1; -- odejmujemy jedno z "miejsc" jezeli operator na przerwie
                else
                    Approved := False; -- jeśli 2 osoby już są na przerwie, to przerwa nie jest dozwolona: Approved == False
                end if;
        end Take_Break;

        procedure Back_To_Work is
            begin
                Count := Count + 1; -- dodajemy do licznika "miejsce" jak operator skońcy przerwę
        end Back_To_Work;

    end Break_Manager;

    S : Break_Manager (2); -- określamy ile operatorów może być na przerwie


    procedure ServeClient(K : Natural; Cl : Integer) is -- obsługa klienta
       DelayTime : Float := 1.0;
    begin
      Reset(Gen);
      DelayTime := Random(Gen) * 4.0 + 1.0; -- klient moze byc obslugiwany przez od 1 do 5 sekund
      Put_Line("Operator "& K'Img &", obsluguję klienta nr. " & Cl'Img);
      delay Standard.Duration(DelayTime);
      Put_Line("Operator "& K'Img &", wolny");
    end ServeClient;


    task body Operator is
        ClientID : Natural := 100500;
        BreakAfter: Integer := 20; -- ile może być klientów przed przerwą
        Approved : Boolean := False;
    begin
        accept Start do
            Put_Line("Operator " & OperatorID'Img & " rozpoczął pracę.");
        end Start;
        Reset(Gen);
        BreakAfter := Integer(Random(Gen) * 10.0 + 5.0);
        Counter.TakeNextClient(OperatorID); -- po starcie "zapraszamy" nowego klienta
        loop
            select
                accept TakeClient(Pos: in Integer) do -- przyjęcie klienta
                    BreakAfter := BreakAfter - 1; -- zmieniamy ilość klientów do przerwy
                    ClientID := Pos;
                end TakeClient;
                ServeClient(OperatorID, ClientID);
                delay 1.5;
                if BreakAfter = 0 then -- przerwa
                    S.Take_Break(Approved);
                    if (Approved = True) then -- jesli operator dostał pozwolenie żeby pojsc na przerwę
                        Put_Line("Operator " & OperatorID'Img & " ma przerwę");
                        delay 10.0;
                        S.Back_To_Work;
                    end if;
                    BreakAfter := Integer(Random(Gen) * 10.0 + 5.0); -- nowa ilość klientów przed przerwą
                end if;
                Counter.TakeNextClient(OperatorID); -- kolejny klient
            or
                accept Finish;
                exit;
            end select;            
        end loop;
    end Operator;

    Operators: array(1..5) of OperatorAccess; -- ilość operatorów

    task body Counter is
      Address : Sock_Addr_Type;
      Socket  : Socket_Type;
      Channel : Stream_Access;
    begin


    Address.Addr := Addresses (Get_Host_By_Name (Host_Name), 1);
    Address.Port := 5875;
    Put_Line("Host: "&Host_Name);
    Put_Line("Adres:port => ("&Image(Address)&")");
    Create_Socket (Socket);
    Set_Socket_Option (Socket, Socket_Level, (Reuse_Address, True));
    Connect_Socket (Socket, Address);

    Channel := Stream (Socket);

    for I in 1..5 loop -- start operatorów
        Operators(I) := new Operator(I);
        Operators(I).Start;
    end loop;

    loop
        accept TakeNextClient(OperatorID: Natural) do
            Integer'Output(Channel, 0); -- jak operator się zwolni wysyłamy zero żeby dostać kolejny numer klienta
            NextInQueue := Integer'Input (Channel);
            OpID := OperatorID;
        end TakeNextClient;
        if NextInQueue = 0 then -- jeżeli użytkownik chce skońcyć działanie programu to dostajemy 0 i przerywamy
            Put_Line("Manager nie działa");
            Operators(OpID).Finish;
            exit;
        end if;
        Operators(OpID).TakeClient(NextInQueue); -- wysyłamy klienta do oparatora
    end loop;

  end Counter;

end Bank_counter_task;