with System;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Text_IO; use Ada.Text_IO;

package Bank_counter_task is

procedure ServeClient(K : Natural; Cl : Integer);

    NextInQueue : Natural := 0;
    Gen: Generator;
    OpID : Natural := 0;

    protected type Break_Manager (Init_Sem : Integer) is -- counting semaphore
       procedure Take_Break(Approved: out Boolean);
       procedure Back_To_Work;
    private
       Count : Integer := Init_Sem;
    end Break_Manager;

    task type Operator(OperatorID: Natural) is
        entry Start;
        entry TakeClient(Pos: in Integer);
        entry Finish;
    end Operator;

    type OperatorAccess is access Operator;

    task Counter is
        entry TakeNextClient(OperatorID: Natural);
    end Counter;

end Bank_counter_task;