# CryptoZoo (ERC-721)

ESILV coursework: an ERC-721 contract (OpenZeppelin 5, Enumerable) where registered breeders mint, sell, breed and burn animal NFTs.

- **Code:** `src/MyCryptoZoo.sol`, plus `script/Solve.s.sol`, which deploys it and submits it to the course evaluators
- **Chain:** Ethereum Sepolia testnet
- **Build:** `git submodule update --init && forge build`
- **Deploy:** set `PRIVATE_KEY`, then `forge script script/Solve.s.sol --rpc-url <sepolia-rpc> --broadcast`
