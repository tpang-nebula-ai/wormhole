pragma solidity ^0.4.18;

interface DistributorInterfaceNebula {

    //Task Dispatcher
    function dispatch_task(address _task, address _worker) public;
}
