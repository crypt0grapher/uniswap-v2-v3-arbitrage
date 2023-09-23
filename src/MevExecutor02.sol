// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(address tokenA, address tokenB, uint24 fee) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1, "Invalid Pool Key");
        pool = address(uint256(keccak256(abi.encodePacked(hex'ff', factory, keccak256(abi.encode(key.token0, key.token1, key.fee)), POOL_INIT_CODE_HASH))));
    }
}

library CallbackValidation {
    address internal constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    function verifyCallback(address tokenA, address tokenB, uint24 fee) internal view returns (address pool) {
        pool = PoolAddress.computeAddress(FACTORY, PoolAddress.getPoolKey(tokenA, tokenB, fee));
        require(msg.sender == pool, "Invalid Callback");
    }
}

library TransferHelper {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");
    }
}

contract MevExecutor02 {
    address private immutable owner;
    address private immutable WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function withdraw_asset(uint amount, address payable asset, address payable destination_address) external onlyOwner payable {
        TransferHelper.safeTransfer(asset, destination_address, amount);
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        (address tokenIn, uint24 fee, address tokenOut, uint256 amount_min_out) = abi.decode(data, (address, uint24, address, uint256));
        CallbackValidation.verifyCallback(tokenIn, tokenOut, fee);

        address tokenToSend = tokenIn == WETH ? tokenIn : tokenOut;
        int256 amountDelta = amount0Delta > 0 ? amount0Delta : amount1Delta;

        (bool success,) = tokenToSend.call(abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, uint256(amountDelta)));
        require(success && uint256(-amountDelta) > amount_min_out, "Swap failed");
    }

    function executeCalls(address[] memory targets, bytes[] memory payloads) external onlyOwner payable {
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success,) = targets[i].call(payloads[i]);
            require(success, "Call failed");
        }
    }

    function executeCheckedCalls(address[] memory targets, bytes[] memory payloads, address assetOut, uint256 amountMin) external onlyOwner payable {
        uint256 startBalance = IERC20(assetOut).balanceOf(address(this));
        executeCalls(targets, payloads);
        require(IERC20(assetOut).balanceOf(address(this)) - startBalance > amountMin, "Minimum amount not received");
    }

    function call(address payable to, uint256 value, bytes calldata data) external onlyOwner payable returns (bytes memory result) {
        (bool success, bytes memory resultData) = to.call{value: value}(data);
        require(success, "External call failed");
        return resultData;
    }
}
