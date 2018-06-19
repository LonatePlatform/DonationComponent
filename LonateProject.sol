pragma solidity ^0.4.4;

contract LonateProject {

    address public project;
    string public projectName;

    uint256 public openingTime;
    uint256 public closingTime;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public balance;

    bool paused;

    event Lonated(address indexed lonator, uint256 amount);

    function LonateProject(address _project, string _projectName, uint256 _openingTime, uint256 _closingTime, uint256 _softCap, uint256 _hardCap) public {

        require(_project != address(0));
        require(_closingTime > _openingTime);
        require(_softCap > 0);
        require(_hardCap > _softCap);

        project = _project;
        projectName = _projectName;
        openingTime = _openingTime;
        closingTime = _closingTime;
        softCap = _softCap;
        hardCap = _hardCap;
        balance = 0;

    }


    function () external payable {
        lonate(msg.sender);
    }
    

    function lonate(address _lonator) public payable {

        _preValidateLonate(_lonator, msg.value);

        uint GAS_LIMIT = 4000000;
        project.call.value(msg.value).gas(GAS_LIMIT)();

        Lonated(msg.sender, msg.value);
    }

    function setOpeningClosingTimes(uint256 _openingTime, uint256 _closingTime) external {

        require (_closingTime>_openingTime);
        openingTime = _openingTime;
        
    }


    function pause() external {

        require (!paused);
        paused = true;
        
    }

    function unpause() external {

        require (paused);
        paused = false;
        
    }

    function _preValidateLonate(address _lonator, uint256 _weiAmount) internal {
        
        require(now >= openingTime && now <= closingTime);
        require(!paused);
        require (_lonator != address(0));
        require (softCap <= _weiAmount && _weiAmount <= hardCap);
        
    }
    

}