pragma solidity ^0.8.0;

contract Example { 
    uint256 public storedValue;
    // 39857 gas
    function ifdgekjhacb(uint256 value) external {
        // Logic: Store the value received in the state variable
        storedValue = value;
        
        // Emit an event to signal the value has been updated
        emit ValueUpdated(value);
    } 
    
    // 39857 gas
    function test(uint256 value) external {
        // Logic: Store the value received in the state variable
        storedValue = value;
        
        // Emit an event to signal the value has been updated
        emit ValueUpdated(value);
    } 

    function getSelector() public pure returns (bytes4) {
        return bytes4(keccak256("test(uint256)"));
    }
    
    // Event to log the updated value
    event ValueUpdated(uint256 newValue);

    // Function to demonstrate a low-level call using the known selector
    function callTestFunction(address target, bytes4 selector,uint256 value) external {
        // Using the known function selector for gdhabfkeicj(test(uint256))
        (bool success, ) = target.call(
            abi.encodeWithSelector(selector, value)
        );
        
        require(success, "Call to test function failed");
    }
}