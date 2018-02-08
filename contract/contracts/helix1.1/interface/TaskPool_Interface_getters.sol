pragma solidity ^0.4.18;

interface TaskPoolInterfaceGetter {
    //getter
    function get_task(address _task)
    view public returns (uint256 _app_id, string _name, string _data, string _script, string _output, string _params);

    function get_status(address _task)
    view public returns (uint _create_time, uint _dispatch_time, uint _start_time, uint _complete_time, uint _cancel_time, uint _error_time);

    function get_worker(address _task) view public returns (address);

    function get_owner(address _task) view public returns (address);


    function get_error_msg(address _task) view public returns (string);

    function get_fees(address _task) view public returns (uint256 _fee, uint256 _completion_fee);
}