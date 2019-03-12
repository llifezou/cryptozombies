pragma solidity ^0.4.19;

import "./zombieattack.sol";
import "./erc721.sol";
//实现ERC721代币
contract ZombieOwnership is ZombieAttack, ERC721 {
  //又来个映射，键uint，值address
  mapping (uint => address) zombieApprovals;

  function balanceOf(address _owner) public view returns (uint256 _balance) {
    return ownerZombieCount[_owner];
  }
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    return zombieToOwner[_tokenId];
  }
  //重构，相同的逻辑，减少重复代码
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerZombieCount[_from] = ownerZombieCount[_from].add(1);
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
    zombieToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }
  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId){
    _transfer(msg.sender, _to, _tokenId);
  }
  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId){
    zombieApprovals[_tokenId] = _to;
    emit Approval(msg.sender, _to, _tokenId);
  }
  function takeOwnership(uint256 _tokenId) public {
    require(zombieApprovals[_tokenId] == msg.sender);
    _transfer(ownerOf(_tokenId), msg.sender, _tokenId);
  }
}
