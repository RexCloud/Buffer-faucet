pragma solidity ^0.8.0;

interface IFaucet {
    function claim() external payable;
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Claimer {

    address private owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function."); 
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function claimTokens() public onlyOwner {
        IFaucet(0x554398d290e957C4EdD5EC2b59a1D70A0b0d833f).claim{value:10**17}();
    }

    function transferTokens(address _owner) public onlyOwner {
        IERC20(0x5E351f387F790815e1874da4e2C669fC0Aa66C75).transfer(_owner, 500*10**18);
    }

    function transferEther(address _owner) public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

}

contract ClaimerFactory {

    address private owner;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function."); 
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    Claimer[] private claimerArray;

    function deployContracts(uint256 _amount) public onlyOwner {
        for(uint i = 0; i < _amount; i++) {
            Claimer claimer = new Claimer();
            claimerArray.push(claimer);
        }
    }

    function deposit() public payable {
        require(claimerArray.length > 0, "Deploy contracts first.");
         for(uint i = 0; i < claimerArray.length; i++) {
             payable(claimerArray[i]).transfer(msg.value / claimerArray.length);
         }
    }

    function withdraw() public onlyOwner {
        for(uint i = 0; i < claimerArray.length; i++) {
            claimerArray[i].transferEther(owner);
        }
    }

    function executeClaims() public onlyOwner {
        for(uint i = 0; i < claimerArray.length; i++) {
            claimerArray[i].claimTokens();
            claimerArray[i].transferTokens(owner);
        }
        delete claimerArray;
    }

}
