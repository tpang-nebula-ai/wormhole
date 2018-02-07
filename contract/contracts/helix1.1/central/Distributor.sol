pragma solidity ^0.4.18;

import "../misc/SafeMath.sol";
import "../ownership/Dispatchable.sol";
import "../interface/Dispatcher_Interface_distributor.sol";
import "../interface/TaskPool_Interface.sol";
import "../interface/Distributor_Interface_client.sol";
import "../interface/Distributor_Interface_miner.sol";
import "../interface/Distributor_Interface_dispatcher.sol";

//This layer is necessary for security and control reason
//Otherwise no way to control what are send to task queue while able to keep Task modular
contract Distributor is Dispatchable, DistributorInterfaceClient, DistributorInterfaceMiner, DistributorInterfaceNebula {
    using SafeMath for uint256;
    DispatcherInterfaceDistributor dispatcher_at;

    address public pool_address;
    TaskPoolInterface pool;
    bool public pool_ready;
    uint256 public minimal_fee;
    uint256 public MAX_WAITING_BLOCK_COUNT = 15;


    ///@dev used to store ALL submitted task
    function Distributor(uint256 _minimal_fee) public Dispatchable(msg.sender) {
        minimal_fee = _minimal_fee == 0 ? 5 ether : _minimal_fee;
    }

    modifier contract_ready(){
        require(pool_ready);
        _;
    }
    //@dev override
    function setDispatcher(address _dispatcher) ownerOnly public {
        super.setDispatcher(_dispatcher);
        dispatcher_at = DispatcherInterfaceDistributor(dispatcher);
    }

    function set_taskpool_contract(address _pool_address) ownerOnly public {
        require(_pool_address != 0);
        pool_address = _pool_address;
        pool = TaskPoolInterface(pool_address);
        pool_ready = true;
    }

    //modifiers
    modifier task_owner_only(address _task){
        require(pool.get_owner(_task) == msg.sender);
        _;
    }
    modifier miner_only(address _task){
        require(pool.get_worker(_task) == msg.sender);
        _;
    }

    //------------------------------------------------------------------------------------------------------------------
    //Client

    function create_task(uint256 _app_id, string _name, string _data, string _script, string _output, string _params)
    contract_ready public payable returns (address _task){
        //        require(app.valid_id(_app_id)) app_id needs to be valid , TODO a contract that keep tracks of the app id
        require(msg.value >= minimal_fee && _app_id != 0);
        _task = pool.create(_app_id, _name, _data, _script, _output, _params, msg.value, msg.sender);
    }

    function cancel_task(address _task) contract_ready public returns (bool){
        address _task_owner = pool.get_owner(_task);
        require(msg.sender == _task_owner);
        uint _create_time;
        uint _dispatch_time;
        (_create_time, _dispatch_time, ,,,) = pool.get_status(_task);

        require(_create_time != 0);
        //task existed

        if (_dispatch_time != 0) return false;
        //task dispatched cannot cancel
        else {
            if (dispatcher_at.cancel(_task)) {
                //in queue can be cancelled
                uint256 _fee;
                (_fee,) = pool.get_fees(_task);
                if (pool.set_fee(_task, 0)) {
                    _task_owner.transfer(_fee);
                } else return false;
            } else return false;
        }
    }

    function reassignable(address _task) task_owner_only(_task) view public returns (bool){
        uint _create_time;
        uint _dispatch_time;
        (_create_time, _dispatch_time, ,,,) = pool.get_status(_task);
        require(_create_time != 0 && _dispatch_time != 0);
        return block.number - _dispatch_time > MAX_WAITING_BLOCK_COUNT;
    }

    function reassign_task_request(address _task) task_owner_only(_task) public returns (bool){
        if (reassignable(_task)) {
            dispatcher_at.rejoin(_task);
            return true;
        } else return false;
    }
    //------------------------------------------------------------------------------------------------------------------
    //Miner


    function report_start(address _task) miner_only(_task) public returns (bool){


    }

    function report_finish(address _task, uint256 _complete_fee) miner_only(_task) public {

    }

    function report_error(address _task, string _error_msg) miner_only(_task) public {

    }

    function forfeit(address _task) miner_only(_task) public {

    }

    //------------------------------------------------------------------------------------------------------------------
    //Dispatcher
    function dispatch_task(address _task, address _worker) public {

    }

    //------------------------------------------------------------------------------------------------------------------
    //getters
    function get_task(address _task)
    view public returns (uint256 _app_id, string _name, string _data, string _script, string _output, string _params){

    }

    function get_status(address _task)
    view public returns (uint _create_time, uint dispatch_time, uint start_time, uint complete_time, uint _cancel_time, uint _error_time){

    }

    function get_worker(address _task) view public returns (address){

    }

    function get_error_msg(address _task) view public returns (string){

    }

    function get_fees(address _task) view public returns (uint256 _fee, uint256 _completion_fee){

    }
}