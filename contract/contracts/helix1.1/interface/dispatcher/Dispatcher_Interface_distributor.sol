pragma solidity ^0.4.18;

interface DispatcherInterfaceDistributor {

    function join_task_queue(address _task) public payable returns (bool);

    function leave_task_queue(address _task_address) public returns (bool);

    function rejoin(address _task, address _worker, uint8 _penalty) public returns (uint8);
}
