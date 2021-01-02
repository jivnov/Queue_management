with System;

package Manager_task is
--  type Int_Array is array (Integer range <>) of Integer;
--
--    task Management;

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