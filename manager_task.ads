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

package Manager_task is

    task Terminal_Client is
        entry Start;
        entry GetPositionInQueue;
        entry GetPositionInPriorityQueue;
    end Terminal_Client;

     task Terminal_Manager is
        entry Start;
        entry TakeFromQueue;
        entry TakeFromPriorityQueue;
    end Terminal_Manager;

    task Manage_Bank_Operators;

end Manager_task;