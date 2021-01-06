with System;

package Bank_counter_task is

procedure ServeClient(K : Natural; Cl : Integer);

--    task Operator;
    task type Operator(OperatorID: Natural := 999) is
        entry Start;
        entry TakeClient(Pos: in Integer);
        entry Finish;
    end Operator;
    type OperatorAccess is access Operator;
    task Counter is
        entry TakeNextClient(OperatorID: Natural);
    end Counter;
end Bank_counter_task;