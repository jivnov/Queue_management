with System;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_Io;
with GNAT.OS_Lib;

package Bank_counter_task is

procedure ServeClient(K : Natural; Cl : Integer);

    NextInQueue : Natural := 0;
    Gen: Generator;
    OpID : Natural := 0;

    protected type Semaphore_Int (Init_Sem : Integer) is -- counting semaphore
       entry Take_Break;
       procedure Back_To_Work;
    private
       Count : Integer := Init_Sem;
    end Semaphore_Int;

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