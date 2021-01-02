with System;

package Bank_counter_task is

procedure ServeClient(K : Natural; Cl : Natural);

--    task Operator;
    task type Operator(OperatorID: Natural) is
        entry Start;
        entry TakeClient(Pos: Natural);
        entry Finish;
    end Operator;
    task Counter;
end Bank_counter_task;