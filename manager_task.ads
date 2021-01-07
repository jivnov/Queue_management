with System;
with Ada.Text_IO,
Ada.Integer_Text_IO,
Ada.Numerics.Discrete_Random,
Ada.Numerics.Float_Random,
GNAT.Sockets;
use Ada.Text_IO,
GNAT.Sockets,
Ada.Numerics.Float_Random,
Ada.Integer_Text_IO;
with GNAT.OS_Lib;

package Manager_task is

    QueueCounter         : Natural := 1;
    PriorityQueueCounter : Natural := 1001;
    Position             : Natural := 0;
    PriorityPosition     : Natural := 1000;
    Get_number           : Integer := -1;
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