pragma solidity ^0.4.0;

contract EtherWalletRoulette {

	address[] players;
	mapping(address => bool) public returnFunds;

	address public receiver;
	uint public amount;

	bool rouletteEnded;

	function EtherWalletRoulette(
		address _receiver,
		uint _amount
	) {
		require(_receiver != address(0));
		assert(_amount > 0);

		receiver = _receiver;
		amount = _amount;
		rouletteEnded = false;
	}

	function joinRoulette() payable {
		require(!rouletteEnded);
		assert(msg.value == amount);
		for (uint i=0; i< players.length; i++) {
			if (players[i] == msg.sender) 
				revert();
		}

		players.push(msg.sender);
		returnFunds[msg.sender] = true;
	}

	function startRoulette() {
		rouletteEnded = true;

		// "random" generation relies on blockchain entropy
		// to randomize the most recent block number
		uint playerNo = uint(block.blockhash(block.number-1)) % uint(players.length);

		returnFunds[players[playerNo]] = false;

		receiver.transfer(amount);
	}

	// it is more secure to allow winners to retrieve funds
	// rather than to send back after Roulette
	function winnerRetrieve() {
		if (rouletteEnded && returnFunds[msg.sender]) {
			returnFunds[msg.sender] = false;

			if (!msg.sender.send(amount))
				returnFunds[msg.sender] = true;
		}
	}
}