with System;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with GNAT.Sockets; use GNAT.Sockets;

package Manager_task is

    QueueCounter         : Natural := 1;
    PriorityQueueCounter : Natural := 1001;
    Position             : Natural := 0;
    PriorityPosition     : Natural := 1000;
    GetNumber            : Integer := -1;
    Acception            : Integer := 1;
    ExitVar              : Integer := 1;

    task Terminal_Client is
        entry Start;
        entry GetPositionInQueue;
        entry GetPositionInPriorityQueue;
        entry Finish;
    end Terminal_Client;

    task Terminal_Manager is
        entry Start;
        entry TakeFromQueue;
        entry TakeFromPriorityQueue;
        entry Finish;
    end Terminal_Manager;

    task Manage_Bank_Operators;

end Manager_task;