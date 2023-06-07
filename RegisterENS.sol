pragma solidity ^0.8.18;

contract RegisterENS {
    struct EnsDomain {
        address addr;
        uint timestamp;
        uint price;
        uint period;
    }
    address owner;
    uint pricePerYear;
    uint coefficient;
    uint constant SEC_IN_YEAR = 31536000;

    mapping(string => EnsDomain) public ensDomains;

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(owner == msg.sender, "Error: You aren't owner");
        _;
    }

    function addEnsDomain(string memory _str, uint _period) public payable {
        require(_period < 1 && _period > 10, "Error: Period exceeded");
        require(msg.value < _period * pricePerYear, "Error: Not enough money");

        if(block.timestamp - (ensDomains[_str].timestamp + ensDomains[_str].period * SEC_IN_YEAR) > 0) delete ensDomains[_str];
        
        ensDomains[_str] = EnsDomain(msg.sender, block.timestamp, msg.value, _period);
    }

    function renewPeriod(string memory _str, uint _period) public payable {
        require(msg.sender == ensDomains[_str].addr, "Error: You aren't owner this domain");
        require(msg.value < _period * pricePerYear * coefficient, "Error: Not enough money");

        ensDomains[_str].period += _period;
    }

    function getAddress(string memory _str) public view returns (address) {
        return ensDomains[_str].addr;
    }

    function chargeMoney() public {
        payable(owner).transfer(address(this).balance);
    }

    function setPrice(uint _price) public isOwner {
        pricePerYear = _price;
    }

    function setCoefficient(uint _coef) public isOwner {
        coefficient = _coef;
    }
}