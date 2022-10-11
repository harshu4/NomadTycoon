pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dollarino is ERC20 {
       address public  owner;
      modifier onlyOwner(){
            require(msg.sender == owner);
            _;
    }
    event Rand(uint num);

    constructor() ERC20("Dollarino", "Dollarino") {
        owner=tx.origin;
    }
    
    function mintnew(uint256 amount,address to) onlyOwner external{
          _mint(to, amount);
    }

    function changeowner(address newowner) onlyOwner public{
        owner = newowner;
    }

    function subtract(address owner,uint256 amount) onlyOwner external{
        _burn(owner,amount);
    }
     function burn(address owner,uint256 amount) onlyOwner external{
        _burn(owner,amount);
    }

    function minto(uint256 amount)  external{
        
        _mint(tx.origin,amount);
        
    }

    function burnto(uint256 amount) external{
        require(balanceOf(tx.origin) > amount);
        _burn(tx.origin,amount);
    }

    function getRand() public returns(uint) {
        require(balanceOf(tx.origin) > 100);
        _burn(tx.origin,100);
        uint rand =  uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))%98;
        if(rand%14 == 0){
          _mint(tx.origin,400);  
        }
        else if(rand%3 ==0){
            
          _mint(tx.origin,150);  
        
        } 

        else{
            _mint(tx.origin,40);
        }
        emit Rand(rand);
        return rand;       
        
    }

}
