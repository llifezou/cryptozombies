pragma solidity ^0.4.19;
//导入合约，导入后便可继承使用非private修饰符修饰的函数
import "./ownable.sol";
import "./safemath.sol";
//继承的方式
contract ZombieFactory is Ownable {
  //for后边的类型便可以使用继承合约的方法
  using SafeMath for uint256;
  using SafeMath16 for uint16;
  using SafeMath32 for uint32;
  //事件，方便前端获得消息
  event NewZombie(uint zombieId, string name, uint dna);
  //定义的变量，uint是uint256简写
  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;
  //结构体，结构体当其成员如uint32，uint16会打包，节省存储空间
  struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
  }
  //定义个动态数组
  Zombie[] public zombies;
  //映射，存储，相当于键值对
  //键uint，值address
  mapping(uint => address) public zombieToOwner;
  //键address，值uint
  mapping(address => uint) public ownerZombieCount;
  //一般内部函数名前加_，良好的习惯
  function _createZombie(string _name, uint _dna) internal {
      //向数组里push数据
      uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
      //向映射里存储数据集，有没有很像数组的感觉
      zombieToOwner[id] = msg.sender;
      //就是加法，使用安全库放溢出的add形式
      ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
      emit NewZombie(id, _name, _dna);
  }
  function _generateRandomDna(string _str) private view returns (uint){
    //keccak256散列函数，需配合abi.encodePacked使用
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    //求余运算
    return rand % dnaModulus;
  }
  //外部函数了，被public修饰，没_
  function createRandomZombie(string _name) public {
    //require也是个修饰符，判断是否符合约束条件
    require(ownerZombieCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }
}
