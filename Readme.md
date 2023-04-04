# Reentrancy Attack Proof of Concept

## Setup

Generate an Ethereum RPC URL and add it to the `.env` file.

```bash
export FORK_ETH_RPC_URL=ALCHEMY_URL
export FORK_BLOCK_NUMBER=16974245
export ETH_RPC_URL="http://127.0.0.1:8545"
```

Keep `FORK_BLOCK_NUMBER` and `ETH_RPC_URL` unchanged.

After adding the Ethereum RPC URL, make sure to load the environment variables.

```bash
source .env
```

## Run

Start anvil forking the mainnet.

```bash
make fork
```

This will use the environment variables defined above and start a fork of the mainnet.

In another terminal, run the exploit.

```bash
make test-fork
```

This will use the environment variables defined above and run the exploit.

You should see an output saying how many tokens were extracted and how many times the exploit re-entered the contract.
