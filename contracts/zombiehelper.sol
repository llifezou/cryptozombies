pragma solidity ^0.4.19;
import "./zombiefeeding.sol";

contract ZombieHelper is Zombiefeeding {
  uint levelUpFee = 0.001 ether;
  //函数修饰符
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    //必不可少
    _;
  }

  function withdraw() external onlyOwner {
    //取得收益
    owner.transfer(address(this).balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    //函数设置levelUpFee，这里边是收费标准
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);

    zombies[_zombieId].level++;
  }

  function changename(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    //require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    //require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
  }
  function getZombiesByOwner (address _owner) external view returns (uint []) {
    //动态数组
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for(uint i = 0; i< zombies.length; i++) {
      if(zombieToOwner[i] == _owner){
        result[counter] = i;
        counter ++;
      }
    }
    return result;
  }
}
