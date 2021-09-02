# ID of producer controlled by this node (e.g. inita; may specify multiple times) (eosio::producer_plugin)
# producer-name =

# the location of the state-history directory (absolute path or relative to application data dir) (eosio::state_history_plugin)
#state-history-dir = "/home/gcpbp/.local/share/eosio/nodeos/data/snapshots"
#PUT IN STATE HISTORY DIRECTORY"state-history"

# Maximum size (in MiB) of the chain state database (eosio::chain_plugin)
chain-state-db-size-mb = 32384
# IS IT OK FOR ME TO PUT SUPER LARGE NUMBER HERE
# https://github.com/EOSIO/eos/issues/4937

# An externally accessible host:port for identifying this node. Defaults to p2p-listen-endpoint. (eosio::net_plugin)
p2p-server-address = ${peer_ip_address}:80

# The local IP and port to listen for incoming http connections; set blank to disable. (eosio::http_plugin)
http-server-address = 0.0.0.0:8888

# The actual host:port used to listen for incoming p2p connections. (eosio::net_plugin)
p2p-listen-endpoint = 0.0.0.0:9876

# Key=Value pairs in the form <public-key>=<provider-spec>
# Where:
#    <public-key>    	is a string form of a vaild EOSIO public key
#
#    <provider-spec> 	is a string in the form <provider-type>:<data>
#
#    <provider-type> 	is KEY, or KEOSD
#
#    KEY:<data>      	is a string form of a valid EOSIO private key which maps to the provided public key
#
#    KEOSD:<data>    	is the URL where keosd is available and the approptiate wallet(s) are unlocked (eosio::producer_plugin)
# signature-provider = EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV=KEY:5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

# The name supplied to identify this node amongst the peers. (eosio::net_plugin)
agent-name = "mandar-chainnodetest"

# Plugin(s) to enable, may be specified multiple times
# plugin 4 every node type
plugin = eosio::chain_plugin
plugin = eosio::producer_plugin
plugin = eosio::producer_api_plugin
plugin = eosio::net_plugin
plugin = eosio::net_api_plugin
plugin = eosio::db_size_api_plugin
#plugin = eosio::state_history_plugin --disable-replay-opts

# uncomment for chain node only
plugin = eosio::chain_api_plugin
plugin = eosio::http_plugin

# the location of the blocks directory (absolute path or relative to application data dir) (eosio::chain_plugin)
blocks-dir = "blocks"

# the location of the protocol_features directory (absolute path or relative to application config dir) (eosio::chain_plugin)
# protocol-features-dir = "protocol_features"

# Pairs of [BLOCK_NUM,BLOCK_ID] that should be enforced as checkpoints. (eosio::chain_plugin)
# checkpoint =

# Override default WASM runtime ( "wabt",  "eos-vm-jit", "eos-vm")
# "wabt" : The WebAssembly Binary Toolkit.
# "eos-vm-jit" : A WebAssembly runtime that compiles WebAssembly code to native x86 code prior to execution.
# "eos-vm" : A WebAssembly interpreter.
#  (eosio::chain_plugin)
# wasm-runtime = wabt https://github.com/atticlab/eos-bp-performance
# OR TRY THE FOLLOWING BELOW:
wasm-runtime = eos-vm-jit
eos-vm-oc-compile-threads = 4
eos-vm-oc-enable = 1

# Override default maximum ABI serialization time allowed in ms (eosio::chain_plugin)
# abi-serializer-max-time-ms = 3000

# Safely shut down node when free space remaining in the chain state database drops below this size (in MiB). (eosio::chain_plugin)
# chain-state-db-guard-size-mb = 128

# Maximum size (in MiB) of the reversible blocks database (eosio::chain_plugin)
reversible-blocks-db-size-mb = 1024

# Safely shut down node when free space remaining in the reversible blocks database drops below this size (in MiB). (eosio::chain_plugin)
# reversible-blocks-db-guard-size-mb = 2

# Percentage of actual signature recovery cpu to bill. Whole number percentages, e.g. 50 for 50% (eosio::chain_plugin)
# signature-cpu-billable-pct = 50

# Number of worker threads in controller thread pool (eosio::chain_plugin)
chain-threads = 8

# print contract's output to console (eosio::chain_plugin)
contracts-console = false
#prints print statements in any contract from a tx, so setting to false for now.

# Account added to actor whitelist (may specify multiple times) (eosio::chain_plugin)
# actor-whitelist =

# Account added to actor banned list (may specify multiple times) (eosio::chain_plugin)
# actor-blacklist =

# Contract account added to contract whitelist (may specify multiple times) (eosio::chain_plugin)
# contract-whitelist =

# Contract account added to contract banned list (may specify multiple times) (eosio::chain_plugin)
# contract-blacklist =

# Action (in the form code::action) added to action banned list (may specify multiple times) (eosio::chain_plugin)
# action-blacklist =

# Public key added to banned list of keys that should not be included in authorities (may specify multiple times) (eosio::chain_plugin)
# key-blacklist =

# Deferred transactions sent by accounts in this list do not have any of the subjective allowed/blocked lists checks applied to them (may specify multiple times) (eosio::chain_plugin)
# sender-bypass-whiteblacklist =

# Database read mode ("speculative", "head", "read-only", "irreversible").
# In "speculative" mode: database contains state changes by transactions in the blockchain up to the head block as well as some transactions not yet included in the blockchain.
# In "head" mode: database contains state changes by only transactions in the blockchain up to the head block; transactions received by the node are relayed if valid.
# In "read-only" mode: (DEPRECATED: see p2p-accept-transactions & api-accept-transactions) database contains state changes by only transactions in the blockchain up to the head block; transactions received via the P2P network are not relayed and transactions cannot be pushed via the chain API.
# In "irreversible" mode: database contains state changes by only transactions in the blockchain up to the last irreversible block; transactions received via the P2P network are not relayed and transactions cannot be pushed via the chain API.
#  (eosio::chain_plugin)
# read-mode = speculative

# Allow API transactions to be evaluated and relayed if valid. (eosio::chain_plugin)
# api-accept-transactions = true

# Chain validation mode ("full" or "light").
# In "full" mode all incoming blocks will be fully validated.
# In "light" mode all incoming blocks headers will be fully validated; transactions in those validated blocks will be trusted
#  (eosio::chain_plugin)
validation-mode = full
# signing node and peer node should be full, chain api can be 'light'

# Disable the check which subjectively fails a transaction if a contract bills more RAM to another account within the context of a notification handler (i.e. when the receiver is not the code of the action). (eosio::chain_plugin)
# disable-ram-billing-notify-checks = false

# Subjectively limit the maximum length of variable components in a variable legnth signature to this size in bytes (eosio::chain_plugin)
# maximum-variable-signature-length = 16384

# Indicate a producer whose blocks headers signed by it will be fully validated, but transactions in those validated blocks will be trusted. (eosio::chain_plugin)
# trusted-producer =

# Database map mode ("mapped", "heap", or "locked").
# In "mapped" mode database is memory mapped as a file.
# In "heap" mode database is preloaded in to swappable memory.
# In "locked" mode database is preloaded, locked in to memory, and optionally can use huge pages.
#  (eosio::chain_plugin)
# database-map-mode = mapped
# play around later

# Optional path for database hugepages when in "locked" mode (may specify multiple times) (eosio::chain_plugin)
# database-hugepage-path =

# Maximum size (in MiB) of the EOS VM OC code cache (eosio::chain_plugin)
# eos-vm-oc-cache-size-mb = 1024

# Enable EOS VM OC tier-up runtime (eosio::chain_plugin)
#eos-vm-oc-enable = true
# DO WE NEED??

# enable queries to find accounts by various metadata. (eosio::chain_plugin)
# enable-account-queries = false

# maximum allowed size (in bytes) of an inline action for a nonprivileged account (eosio::chain_plugin)
# max-nonprivileged-inline-action-size = 4096

# Track actions which match receiver:action:actor. Actor may be blank to include all. Action and Actor both blank allows all from Recieiver. Receiver may not be blank. (eosio::history_plugin)
# filter-on =

# Do not track actions which match receiver:action:actor. Action and Actor both blank excludes all from Reciever. Actor blank excludes all from reciever:action. Receiver may not be blank. (eosio::history_plugin)
# filter-out =

# PEM encoded trusted root certificate (or path to file containing one) used to validate any TLS connections made.  (may specify multiple times)
#  (eosio::http_client_plugin)
# https-client-root-cert =

# true: validate that the peer certificates are valid and trusted, false: ignore cert errors (eosio::http_client_plugin)
# https-client-validate-peers = true

# The filename (relative to data-dir) to create a unix socket for HTTP RPC; set blank to disable. (eosio::http_plugin)
# unix-socket-path =

# The local IP and port to listen for incoming https connections; leave blank to disable. (eosio::http_plugin)
# https-server-address =

# Filename with the certificate chain to present on https connections. PEM format. Required for https. (eosio::http_plugin)
# https-certificate-chain-file =

# Filename with https private key in PEM format. Required for https (eosio::http_plugin)
# https-private-key-file =

# Configure https ECDH curve to use: secp384r1 or prime256v1 (eosio::http_plugin)
# https-ecdh-curve = secp384r1

# Specify the Access-Control-Allow-Origin to be returned on each request. (eosio::http_plugin)
access-control-allow-origin = *

# Specify the Access-Control-Allow-Headers to be returned on each request. (eosio::http_plugin)
access-control-allow-headers = *

# Specify the Access-Control-Max-Age to be returned on each request. (eosio::http_plugin)
# access-control-max-age =

# Specify if Access-Control-Allow-Credentials: true should be returned on each request. (eosio::http_plugin)
access-control-allow-credentials = false

# The maximum body size in bytes allowed for incoming RPC requests (eosio::http_plugin)
# max-body-size = 1048576

# Maximum size in megabytes http_plugin should use for processing http requests. 503 error response when exceeded. (eosio::http_plugin)
# http-max-bytes-in-flight-mb = 500

# Maximum time for processing a request. (eosio::http_plugin)
http-max-response-time-ms = 500

# Append the error log to HTTP responses (eosio::http_plugin)
verbose-http-errors = true

# If set to false, then any incoming "Host" header is considered valid (eosio::http_plugin)
http-validate-host = false
# WHY?? What defines valid? https://docs.liquidapps.io/en/stable/dsps/eosio-node.html has it as false

# Additionaly acceptable values for the "Host" header of incoming HTTP requests, can be specified multiple times.  Includes http/s_server_address by default. (eosio::http_plugin)
# http-alias =

# Number of worker threads in http thread pool (eosio::http_plugin)
http-threads = 8

# The maximum number of pending login requests (eosio::login_plugin)
# max-login-requests = 1000000

# The maximum timeout for pending login requests (in seconds) (eosio::login_plugin)
# max-login-timeout = 60

# The target queue size between nodeos and MongoDB plugin thread. (eosio::mongo_db_plugin)

# The maximum size of the abi cache for serializing data. (eosio::mongo_db_plugin)
# mongodb-abi-cache-size = 2048

# Required with --replay-blockchain, --hard-replay-blockchain, or --delete-all-blocks to wipe mongo db.This option required to prevent accidental wipe of mongo db. (eosio::mongo_db_plugin)
# mongodb-wipe = false

# If specified then only abi data pushed to mongodb until specified block is reached. (eosio::mongo_db_plugin)
# mongodb-block-start = 0

# MongoDB URI connection string, see: https://docs.mongodb.com/master/reference/connection-string/. If not specified then plugin is disabled. Default database 'EOS' is used if not specified in URI. Example: mongodb://127.0.0.1:27017/EOS (eosio::mongo_db_plugin)
# mongodb-uri =

# Update blocks/block_state with latest via block number so that duplicates are overwritten. (eosio::mongo_db_plugin)
# mongodb-update-via-block-num = false

# Enables storing blocks in mongodb. (eosio::mongo_db_plugin)
# mongodb-store-blocks = true

# Enables storing block state in mongodb. (eosio::mongo_db_plugin)
# mongodb-store-block-states = true

# Enables storing transactions in mongodb. (eosio::mongo_db_plugin)
# mongodb-store-transactions = true

# Enables storing transaction traces in mongodb. (eosio::mongo_db_plugin)
# mongodb-store-transaction-traces = true

# Enables storing action traces in mongodb. (eosio::mongo_db_plugin)
# mongodb-store-action-traces = true

# Enables expiring data in mongodb after a specified number of seconds. (eosio::mongo_db_plugin)
# mongodb-expire-after-seconds = 0

# Track actions which match receiver:action:actor. Receiver, Action, & Actor may be blank to include all. i.e. eosio:: or :transfer:  Use * or leave unspecified to include all. (eosio::mongo_db_plugin)
# mongodb-filter-on =

# Do not track actions which match receiver:action:actor. Receiver, Action, & Actor may be blank to exclude all. (eosio::mongo_db_plugin)
# mongodb-filter-out =

# The public endpoint of a peer node to connect to. Use multiple p2p-peer-address options as needed to compose a network.
#   Syntax: host:port[:<trx>|<blk>]
#   The optional 'trx' and 'blk' indicates to node that only transactions 'trx' or blocks 'blk' should be sent.  Examples:
#     p2p.eos.io:9876
#     p2p.trx.eos.io:9876:trx
#     p2p.blk.eos.io:9876:blk
#  (eosio::net_plugin)
# FROM https://validate.eosnation.io/eos/reports/config.html
# Endpoints config.ini
# Network: EOS
# Validator last update: 2020-09-25 17:28 UTC
# For details on how this is generated see https://validate.eosnation.io/about/

# ==== p2p ====

p2p-peer-address = p2p.eoseoul.io:9876
p2p-peer-address = peer.eosn.io:9876
p2p-peer-address = eosbp-0.atticlab.net:9876
p2p-peer-address = p2p.starteos.io:9876
p2p-peer-address = eos.infstones.io:9876
p2p-peer-address = eosnode.b1.run:9876
p2p-peer-address = 47.91.245.50:9876
p2p-peer-address = fullnode.eoslaomao.com:443
p2p-peer-address = mainnet.eoslaomao.com:443
p2p-peer-address = p2p.newdex.one:9876
p2p-peer-address = pubnode.eosrapid.com:9876
p2p-peer-address = peer1.mainnet.helloeos.com.cn:80
p2p-peer-address = p2p-eos.whaleex.com:9876
p2p-peer-address = peer1.eoshuobipool.com:18181
p2p-peer-address = peer2.eoshuobipool.com:18181
p2p-peer-address = eos.okpool.top:9876
p2p-peer-address = p2p.meet.one:9876
p2p-peer-address = node1.eoscannon.io:59876

# Maximum number of client nodes from any single IP address (eosio::net_plugin)
p2p-max-nodes-per-host = 1

# Allow transactions received over p2p network to be evaluated and relayed if valid. (eosio::net_plugin)
# p2p-accept-transactions = true

# Can be 'any' or 'producers' or 'specified' or 'none'. If 'specified', peer-key must be specified at least once. If only 'producers', peer-key is not required. 'producers' and 'specified' may be combined. (eosio::net_plugin)
allowed-connection = any

# Optional public key of peer allowed to connect.  May be used multiple times. (eosio::net_plugin)
# peer-key =

# Tuple of [PublicKey, WIF private key] (may specify multiple times) (eosio::net_plugin)
# peer-private-key =

# Maximum number of clients from which connections are accepted, use 0 for no limit (eosio::net_plugin)
max-clients = 100

# number of seconds to wait before cleaning up dead connections (eosio::net_plugin)
connection-cleanup-period = 30

# max connection cleanup time per cleanup call in millisec (eosio::net_plugin)
# max-cleanup-time-msec = 10

# Number of worker threads in net_plugin thread pool (eosio::net_plugin)
net-threads = 8

# number of blocks to retrieve in a chunk from any individual peer during synchronization (eosio::net_plugin)
sync-fetch-span = 1000

# Enable experimental socket read watermark optimization (eosio::net_plugin)
# use-socket-read-watermark = false

# The string used to format peers when logging messages about them.  Variables are escaped with $${<variable name>}.
# Available Variables:
#    _name  	self-reported name
#
#    _id    	self-reported ID (64 hex characters)
#
#    _sid   	first 8 characters of _peer.id
#
#    _ip    	remote IP address of peer
#
#    _port  	remote port number of peer
#
#    _lip   	local IP address connected to peer
#
#    _lport 	local port number connected to peer
#
#  (eosio::net_plugin)
# peer-log-format = ["$${_name}" $${_ip}:$${_port}]

# Enable block production, even if the chain is stale. (eosio::producer_plugin)
enable-stale-production = false

# Start this node in a state where production is paused (eosio::producer_plugin)
pause-on-startup = true

# Limits the maximum time (in milliseconds) that is allowed a pushed transaction's code to execute before being considered invalid (eosio::producer_plugin)
max-transaction-time = 150000

# Limits the maximum age (in seconds) of the DPOS Irreversible Block for a chain this node will produce blocks on (use negative value to indicate unlimited) (eosio::producer_plugin)
max-irreversible-block-age = -1

# Limits the maximum time (in milliseconds) that is allowed for sending blocks to a keosd provider for signing (eosio::producer_plugin)
# keosd-provider-timeout = 5

# account that can not access to extended CPU/NET virtual resources (eosio::producer_plugin)
# greylist-account =

# Limit (between 1 and 1000) on the multiple that CPU/NET virtual resources can extend during low usage (only enforced subjectively; use 1000 to not enforce any limit) (eosio::producer_plugin)
# greylist-limit = 1000

# Offset of non last block producing time in microseconds. Valid range 0 .. -block_time_interval. (eosio::producer_plugin)
# produce-time-offset-us = 0

# Offset of last block producing time in microseconds. Valid range 0 .. -block_time_interval. (eosio::producer_plugin)
# last-block-time-offset-us = -200000

# Percentage of cpu block production time used to produce block. Whole number percentages, e.g. 80 for 80% (eosio::producer_plugin)
# cpu-effort-percent = 80

# Percentage of cpu block production time used to produce last block. Whole number percentages, e.g. 80 for 80% (eosio::producer_plugin)
# last-block-cpu-effort-percent = 80

# Threshold of CPU block production to consider block full; when within threshold of max-block-cpu-usage block can be produced immediately (eosio::producer_plugin)
# max-block-cpu-usage-threshold-us = 5000

# Threshold of NET block production to consider block full; when within threshold of max-block-net-usage block can be produced immediately (eosio::producer_plugin)
# max-block-net-usage-threshold-bytes = 1024

# Maximum wall-clock time, in milliseconds, spent retiring scheduled transactions in any block before returning to normal transaction processing. (eosio::producer_plugin)
# max-scheduled-transaction-time-per-block-ms = 100

# Time in microseconds allowed for a transaction that starts with insufficient CPU quota to complete and cover its CPU usage. (eosio::producer_plugin)
# subjective-cpu-leeway-us = 31000

# ratio between incoming transactions and deferred transactions when both are queued for execution (eosio::producer_plugin)
# incoming-defer-ratio = 1

# Maximum size (in MiB) of the incoming transaction queue. Exceeding this value will subjectively drop transaction with resource exhaustion. (eosio::producer_plugin)
# incoming-transaction-queue-size-mb = 1024

# Number of worker threads in producer thread pool (eosio::producer_plugin)
# producer-threads = 2

# the location of the snapshots directory (absolute path or relative to application data dir) (eosio::producer_plugin)
# snapshots-dir = "snapshots"

# enable trace history (eosio::state_history_plugin)


# enable chain state history (eosio::state_history_plugin)
# chain-state-history = false

# the endpoint upon which to listen for incoming connections. Caution: only expose this port to your internal network. (eosio::state_history_plugin)
state-history-endpoint = 0.0.0.0:8887

# enable debug mode for trace history (eosio::state_history_plugin)


# the location of the trace directory (absolute path or relative to application data dir) (eosio::trace_api_plugin)
# trace-dir = "traces"

# the number of blocks each "slice" of trace data will contain on the filesystem (eosio::trace_api_plugin)
# trace-slice-stride = 10000

# Number of blocks to ensure are kept past LIB for retrieval before "slice" files can be automatically removed.
# A value of -1 indicates that automatic removal of "slice" files will be turned off. (eosio::trace_api_plugin)
# trace-minimum-irreversible-history-blocks = -1

# Number of blocks to ensure are uncompressed past LIB. Compressed "slice" files are still accessible but may carry a performance loss on retrieval
# A value of -1 indicates that automatic compression of "slice" files will be turned off. (eosio::trace_api_plugin)
# trace-minimum-uncompressed-irreversible-history-blocks = -1

# ABIs used when decoding trace RPC responses.
# There must be at least one ABI specified OR the flag trace-no-abis must be used.
# ABIs are specified as "Key=Value" pairs in the form <account-name>=<abi-def>
# Where <abi-def> can be:
#    an absolute path to a file containing a valid JSON-encoded ABI
#    a relative path from `data-dir` to a file containing a valid JSON-encoded ABI
#  (eosio::trace_api_plugin)
# trace-rpc-abi =

# Use to indicate that the RPC responses will not use ABIs.
# Failure to specify this option when there are no trace-rpc-abi configuations will result in an Error.
# This option is mutually exclusive with trace-rpc-api (eosio::trace_api_plugin)
# trace-no-abis =

# Lag in number of blocks from the head block when selecting the reference block for transactions (-1 means Last Irreversible Block) (eosio::txn_test_gen_plugin)
txn-reference-block-lag = 0

# Number of worker threads in txn_test_gen thread pool (eosio::txn_test_gen_plugin)
# txn-test-gen-threads = 2

# Prefix to use for accounts generated and used by this plugin (eosio::txn_test_gen_plugin)
# txn-test-gen-account-prefix = txn.test.
