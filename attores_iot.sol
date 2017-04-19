pragma solidity ^0.4.2;
// Attores IOT Master Contract
// This contract has been created by Gaurang Torvekar, the co-founder and CTO of Attores, a Singaporean company which is creating a SaaS platform for Smart Contracts
// This contract will be the master contract for the IOT devices, which will accept the transactions incoming from the devices, and segragate them according to the validity

contract attores_iot{
	mapping(bytes32 => address) public registered_devices;
	mapping(bytes32 => address) public unregistered_devices;
	struct txn_log_entry{
	    bytes32 device_id;
	    uint timestamp;
	    address tx_origin;
	    bool flag;
	}
	uint public numTxn_logs;
	mapping(address => txn_log_entry[]) public txn_log;
	
	address public owner;
	address public owner1;
	address public valid = 0x8e9869e820a68eab13daf5b043083a1d270b36da;
	address public invalid = 0x8e9869e820a68eab13daf5b043083a1d270b36db;
	uint amountInContract;
	uint public constant WEI_PER_ETHER = 1000000000000000000;

	// This is the constructor, called while creating the contract
	function attores_iot(address _owner, address _owner1){
		owner = _owner;
		owner1 = _owner1;
		amountInContract += msg.value;
	}
	
	modifier ifOwner() { 
        if (owner != msg.sender){
            if (owner1 != msg.sender){
                throw;    
            } else {
                _;
            }
        } else {
            _;
        }
    }
    
    function register_device(bytes32 device_id) ifOwner{
        if (registered_devices[device_id] == address(0x0)){
            registered_devices[device_id] = msg.sender;
        }
    }
    
    function log_transaction(bytes32 device_id){
        numTxn_logs++;
        if (registered_devices[device_id] != address(0x0)){
            txn_log[valid].push(txn_log_entry(device_id, block.timestamp, msg.sender, false));
        } else {
            unregistered_devices[device_id] = msg.sender;
            txn_log[invalid].push(txn_log_entry(device_id, block.timestamp, msg.sender, true));
        }
    }
	
    // Fallback function which increases the variable 
    function(){
        amountInContract += msg.value;
    }
    
    // A withdraw function just in case someone sends Ether to this contract
    function withdraw() ifOwner{
        uint amountReturned = amountInContract - (WEI_PER_ETHER * 2/10);
        if (!owner.send(amountReturned)){
            throw;
        }
    }
}
