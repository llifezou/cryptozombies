pragma solidity ^0.4.19;

import "./zombieFactory.sol";
// Create KittyInterface
//要是想调用第三方合约，需要先定义其接口
contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
  bool isGestating,
  bool isReady,
  uint256 cooldownIndex,
  uint256 nextActionAt,
  uint256 siringWithId,
  uint256 birthTime,
  uint256 matronId,
  uint256 sireId,
  uint256 generation,
  uint256 genes
  );
}
contract Zombiefeeding is ZombieFactory{
  //address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  // Initialize kittyContract here using `ckAddress` from above
  //KittyInterface kittyContract = KittyInterface(ckAddress);
  //声明接口
  KittyInterface kittyContract;
  //函数修饰符
  modifier onlyOwnerOf(uint _zombieId) {
    //msg.sender是调用者的地址
    require(msg.sender == zombieToOwner[_zombieId]);
    _;
  }
  //函数形式设定第三方合约地址，下边feedOnKitty用
  function setKittyContractAddress (address _address) external onlyOwner{
    kittyContract = KittyInterface(_address);
  }
  //now是取当时的时间，此时now应该是1551330529s
  function _triggerCooldown(Zombie storage _zombie) internal{
    _zombie.readyTime = uint32(now + cooldownTime);
  }
  function _isReady(Zombie storage _zombie) internal view returns(bool) {
    return (_zombie.readyTime <= now);
  }
  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal onlyOwnerOf(_zombieId) {
    //require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];//id对的上吗?
    require(_isReady(myZombie));

    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    //,,,,,是多个返回值时筛选有用的，,要数清楚了
    //kittyContract.getKitty就是应用接口调用其它合约
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
