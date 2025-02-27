# Benchmarking

The goal of this chapter is not to do benchmark to compare differents platforms,
but to measure some metrics to be able to detect a performance regression
after an update.

The most interesting metrics to measure are CPU computation, memory and cache
performances, and the most important for a router, the network performances.

The tools iperf3 and stress-ng were selected to make these measurements. These
tools are pre-installed in the demo profiles.

## Stress-ng

The stress-ng tool includes lots of tests, and in particular some network tests.
The following tests were selected.

It's not an exhaustive list, and you are free to run other tests.

|Tests|Description|
|-----|-----------|
|cpu|exercise the CPUs using different CPU stress methods|
|matrix|perform various matrix operations on floating point values (good way to exercise CPU fp operations, memory and cache)|
|fp|perform floating point math ops|
|crypt|perform password encryption|
|goto|perform forward/backward branches (exercises branch prediction logic)|
|bigheap|grow the heap by reallocating memory|
|malloc|perform memory allocations (malloc, calloc, realloc, free...)|
|memcpy|perform memory copies|
|bsearch|perform binary search (exercise random access of memory and processor cache)|
|hsearch|perform hashtable searching (exercise memory access and processor cache)|
|msg|send and receive messages using System V message IPC|
|getrandom|get random bytes from the /dev/urandom pool using getrandom|
|hrtimers|exercise high resolution times at a high frequency|
|daemon|put pressure on init (procd) to do rapid child reaping|
|fork|perform forks|
|netdev|exercise various netdevice ioctl commands across all the available network devices|
|rawpkt|send and receive ethernet packets using raw packets on the localhost via lo device|
|rawsock|send and receive packet data using raw sockets on the localhost|
|rawudp|send and receive UDP packets using raw sockets on the localhost|
|sock|perform various socket stress activity|
|sockfd|pass file descriptors over a UNIX domain socket using the CMSG ancillary data mechanism|
|sockmany|open as many as 100000 TCP/IP socket connections to a server|
|udp|perform udp transfers|

To get more details about these tests, please refer to the [stress-ng project](https://github.com/ColinIanKing/stress-ng)

The command used to run these tests is:

```bash
root@OpenWrt:~# stress-ng -Y stress-ng.yml \
--metrics --sequential 0 --oom-avoid-bytes 20% -t 60 \
--cpu 0 --matrix 0 --fp 0 --crypt 0 --goto 0 \
--cache 0 --cache-enable-all \
--bigheap 0 --malloc 0 --memcpy 0 \
--bsearch 0 --hsearch 0 \
--msg 0 \
--getrandom 0 \
--hrtimers 0 \
--daemon 0 \
--fork 0 \
--netdev 0 --rawpkt 0 --rawsock 0 --rawudp 0 --sock 0 --sockfd 0 --sockmany 0 --udp 0 \
```

The stress-ng tool has a verbose output. For each test, the most interesting
metric (to compare with previous sessions) is the `bogo ops/s (usr+sys time)`.

Note that `bogo op` depends on the stressor being run, and are not comparable
between different stressors.

```bash
106 stress-ng: metrc: [1892] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s CPU used per       RSS Max
107 stress-ng: metrc: [1892]                           (secs)    (secs)    (secs)   (real time) (usr+sys time) instance (%)          (KB)
108 stress-ng: metrc: [1892] cpu                8569     60.01     59.74      0.01       142.79         143.41        99.57          2540
109 stress-ng: metrc: [1892] matrix            12122     60.03     59.74      0.02       201.94         202.83        99.56          1684
```

Some tests have miscellaneous metrics which can be also compared.

```bash
169 stress-ng: metrc: [1892] crypt              20138.58 MD5 encrypts per sec (harmonic mean of 1 instance)
170 stress-ng: metrc: [1892] crypt                276.60 NT encrypts per sec (harmonic mean of 1 instance)
171 stress-ng: metrc: [1892] crypt              19584.92 SHA-1 encrypts per sec (harmonic mean of 1 instance)
172 stress-ng: metrc: [1892] crypt              20022.30 SHA-256 encrypts per sec (harmonic mean of 1 instance)
```

A yaml file, containing all results, is also generated. It can be used to easily
compare the results with other sessions.

## Iperf3

Iperf3 is a network bandwidth measurement tool that support UDP and TCP network
protocols.
It will be used to measure the bandwidth of all network interfaces (to detect
performance regression), and validate that the hardware is functional.

For the wifi tests, they are only run in access point mode.

Iperf3 tests will also be run on the loopback interface. These tests are used to
stress as much as possible cpu, memory, cache and network stack.
The values can be used to detect a performance regression, but they don't
correspond to a reachable bandwidth. The bandwidth of the board will be limited
by the hardware interfaces.

Note that wifi tests are very sensitive to the test environment (hardware used
as wifi client, distance between client and access point, other wireless
networks, ...).

Some of the bandwidths may not be optimal, they can be improved with very fine
tuning. But it's not the goal of this part. The goal is to do basic tests with
the default configuration (which can be reproduced easily), to validate the
hardware and detect performance regression for the default setup.

### Procedure

* Start wifi access point (SSID: OpenWrt, no password)
```bash
root@OpenWrt:~# uci set wireless.radio0.disabled='0'
root@OpenWrt:~# uci commit
```
* Move eth1 interface in the lan network (only for STM32MP135F-DK)
```bash
root@OpenWrt:~# uci delete network.wan.device
root@OpenWrt:~# uci delete network.wan6.device
root@OpenWrt:~# uci commit
root@OpenWrt:~# uci add_list network.@device[0].ports='eth1'
root@OpenWrt:~# uci commit
```
* Restart network service
```bash
root@OpenWrt:/# /etc/init.d/network restart
```
* Start iperf3 in the background (all tests results will be available in
  /tmp/iperf3.log).
```bash
root@OpenWrt:~# iperf3 -s > /tmp/iperf3.log &
```
* Connect your laptop (to the Ethernet interface or to the wifi network)
* From the laptop start the following tests
```
# loopback, TCP
$ iperf3 -O 5 -Z -c 127.0.0.1 -t 300

# loopback, TCP, bidir
$ iperf3 -O 5 -Z -c 127.0.0.1 -t 300 --bidir

# loopback, UDP
$ iperf3 -O 5 -Z -c 127.0.0.1 -t 300 -u -b0

# loopback, UDP, bidir
$ iperf3 -O 5 -Z -c 127.0.0.1 -t 300 -u -b0 --bidir


# (eth0, eth1, or wifi), TCP, RX
$ iperf3 -O 5 -Z -c 192.168.1.1 -t 300

# (eth0i, eth1, or wifi), TCP, TX
$ iperf3 -O 5 -Z -c 192.168.1.1 -t 300 --reverse

# (eth0, eth1, or wifi), TCP, bidir
$ iperf3 -O 5 -Z -c 192.168.1.1 -t 300 --bidir
```

## Results

### Stress-ng

#### STM32MP157F-DK2

[Results (yaml format)](stress-ng-stm32mp157f-dk2.yml)

```
stress-ng: info:  [1892] setting to a 1 min, 0 secs run per stressor
stress-ng: info:  [1892] dispatching hogs: 2 cpu, 2 matrix, 2 fp, 2 crypt, 2 goto, 2 cache, 2 bigheap, 2 malloc, 2 memcpy, 2 bsearch, 2 hsearch, 2 msg, 2 getrandom, 2 hrtimers, 2 daemon, 2 fork, 2 netdev, 2 rawpkt, 2 rawsock, 2 rawudp, 2 sock, 2 sockfd, 2 sockmany, 2 udp
stress-ng: info:  [1904] cache: sfence is not available, ignoring this option
stress-ng: info:  [1904] cache: cldemote is not available, ignoring this option
stress-ng: info:  [1904] cache: clflush is not available, ignoring this option
stress-ng: info:  [1904] cache: clflushopt is not available, ignoring this option
stress-ng: info:  [1904] cache: clwb is not available, ignoring this option
stress-ng: info:  [1904] cache: cache flags used: prefetch fence
stress-ng: metrc: [1892] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s CPU used per       RSS Max
stress-ng: metrc: [1892]                           (secs)    (secs)    (secs)   (real time) (usr+sys time) instance (%)          (KB)
stress-ng: metrc: [1892] cpu               15672     60.01    119.73      0.00       261.16         130.89        99.76          2512
stress-ng: metrc: [1892] matrix            19034     60.02    119.75      0.01       317.12         158.93        99.77          1684
stress-ng: metrc: [1892] fp                12078     60.00    119.85      0.02       201.30         100.76        99.89          1360
stress-ng: metrc: [1892] crypt              6948     60.04    119.95      0.00       115.72          57.92        99.89          1372
stress-ng: metrc: [1892] goto            8405096     60.00    119.87      0.00    140084.79       70120.94        99.89          1392
stress-ng: metrc: [1892] cache            584508     60.00     60.82      0.22      9741.29        9575.43        50.87          3412
stress-ng: metrc: [1892] bigheap          401175     60.01      5.56    113.98      6685.54        3355.95        99.61        144812
stress-ng: metrc: [1892] malloc          2520005     60.19     23.68     93.06     41870.67       21585.90        96.99        144008
stress-ng: metrc: [1892] memcpy             2091     60.01    119.90      0.00        34.85          17.44        99.91          1276
stress-ng: metrc: [1892] bsearch            3115     60.02    119.77      0.00        51.90          26.01        99.77          1580
stress-ng: metrc: [1892] hsearch           48411     60.00    119.63      0.03       806.81         404.57        99.71          1624
stress-ng: metrc: [1892] msg            14640524     60.01      8.60    110.95    243984.92      122458.94        99.62          1392
stress-ng: metrc: [1892] getrandom        400381     60.00      0.29    119.59      6672.98        3339.89        99.90          1384
stress-ng: metrc: [1892] hrtimers        4571535     60.01      6.83    113.02     76179.06       38141.49        99.86          1264
stress-ng: metrc: [1892] daemon            55857     60.00      0.28      2.15       930.95       23068.01         2.02          1208
stress-ng: metrc: [1892] fork              52950     60.00     57.16     61.03       882.49         447.99        98.49          1392
stress-ng: metrc: [1892] netdev          2778515     60.00     25.45     94.40     46308.54       23183.32        99.87          1200
stress-ng: metrc: [1892] rawpkt          2962641     60.08      6.58    113.27     49314.19       24719.53        99.75          1260
stress-ng: metrc: [1892] rawsock         2699706     61.50      4.24    115.99     43897.23       22454.47        97.75          1312
stress-ng: metrc: [1892] rawudp           555086     60.00      5.16    109.81      9251.24        4827.92        95.81          1532
stress-ng: metrc: [1892] sock               8355     60.01      3.53    116.03       139.22          69.88        99.60          1620
stress-ng: metrc: [1892] sockfd          1768848     60.01      8.10    109.96     29475.63       14983.06        98.36          1448
stress-ng: metrc: [1892] sockmany         123328     60.04      2.09    114.15      2054.12        1060.99        96.80          1700
stress-ng: metrc: [1892] udp             1574891     60.00      3.41    114.53     26247.53       13353.79        98.28          1312
stress-ng: metrc: [1892] miscellaneous metrics:
stress-ng: metrc: [1892] matrix              3353.20 add matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix             13260.09 copy matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              2606.15 div matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              4792.89 frobenius matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              5262.60 hadamard matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix             11461.46 identity matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              5034.98 mean matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              9197.61 mult matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              9566.44 negate matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix                22.90 prod matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              3746.88 sub matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix                23.66 square matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix              3051.91 trans matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] matrix             13606.64 zero matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   797.47 Mfp-ops per sec, float64 add          (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   797.08 Mfp-ops per sec, float32 add          (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   749.24 Mfp-ops per sec, float add            (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   797.41 Mfp-ops per sec, double add           (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   797.31 Mfp-ops per sec, long double add      (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   199.34 Mfp-ops per sec, float64 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   796.45 Mfp-ops per sec, float32 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   748.59 Mfp-ops per sec, float multiply       (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   199.34 Mfp-ops per sec, double multiply      (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                   199.44 Mfp-ops per sec, long double multiply (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                    27.51 Mfp-ops per sec, float64 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                    53.21 Mfp-ops per sec, float32 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                    53.24 Mfp-ops per sec, float divide         (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                    27.54 Mfp-ops per sec, double divide        (harmonic mean of 2 instances)
stress-ng: metrc: [1892] fp                    27.54 Mfp-ops per sec, long double divide   (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt              16064.35 MD5 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt                222.51 NT encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt              15969.82 SHA-1 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt              16189.32 SHA-256 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt                 21.68 SHA-512 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt                 11.46 scrypt encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt              15632.08 SunMD5 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] crypt              16115.86 yescrypt encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] goto                  71.72 million gotos per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] cache            3558855.28 cache ops per second (harmonic mean of 2 instances)
stress-ng: metrc: [1892] cache           11629268.96 shared cache reads per second (harmonic mean of 2 instances)
stress-ng: metrc: [1892] cache           14228787.28 shared cache writes per second (harmonic mean of 2 instances)
stress-ng: metrc: [1892] bigheap            20705.72 realloc calls per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] bsearch         25825900.14 bsearch comparisons per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] bsearch               15.00 bsearch comparisons per item (harmonic mean of 2 instances)
stress-ng: metrc: [1892] getrandom      218709430.23 getrandom bits per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] hrtimers           38094.09 hrtimer signals per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] rawpkt                 0.99 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] rawsock                0.60 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] rawudp                 0.14 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] rawudp              4625.83 packets (32 bytes) received per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] sock               35572.11 messages sent per sec (harmonic mean of 2 instances)
stress-ng: metrc: [1892] sock             2136608.77 byte average out queue length (harmonic mean of 2 instances)
stress-ng: info:  [1892] skipped: 0
stress-ng: info:  [1892] passed: 48: cpu (2) matrix (2) fp (2) crypt (2) goto (2) cache (2) bigheap (2) malloc (2) memcpy (2) bsearch (2) hsearch (2) msg (2) getrandom (2) hrtimers (2) daemon (2) fork (2) netdev (2) rawpkt (2) rawsock (2) rawudp (2) sock (2) sockfd (2) sockmany (2) )
stress-ng: info:  [1892] failed: 0
stress-ng: info:  [1892] metrics untrustworthy: 0
stress-ng: info:  [1892] successful run completed in 24 mins, 2.17 secs
```

#### STM32MP135F-DK

[Results (yaml format)](stress-ng-stm32mp135f-dk.yml)

```
stress-ng: info:  [2203] setting to a 1 min, 0 secs run per stressor
stress-ng: info:  [2203] dispatching hogs: 1 cpu, 1 matrix, 1 fp, 1 crypt, 1 goto, 1 cache, 1 bigheap, 1 malloc, 1 memcpy, 1 bsearch, 1 hsearch, 1 msg, 1 getrandom, 1 hrtimers, 1 daemon, 1 fork, 1 netdev, 1 rawpkt, 1 rawsock, 1 rawudp, 1 sock, 1 sockfd, 1 sockmany, 1 udp
stress-ng: info:  [2210] cache: sfence is not available, ignoring this option
stress-ng: info:  [2210] cache: cldemote is not available, ignoring this option
stress-ng: info:  [2210] cache: clflush is not available, ignoring this option
stress-ng: info:  [2210] cache: clflushopt is not available, ignoring this option
stress-ng: info:  [2210] cache: clwb is not available, ignoring this option
stress-ng: info:  [2210] cache: cache flags used: prefetch fence
[  827.328445] hrtimer: interrupt took 33166 ns
stress-ng: metrc: [2203] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s CPU used per       RSS Max
stress-ng: metrc: [2203]                           (secs)    (secs)    (secs)   (real time) (usr+sys time) instance (%)          (KB)
stress-ng: metrc: [2203] cpu                8581     60.09     59.78      0.02       142.80         143.49        99.52          2512
stress-ng: metrc: [2203] matrix            12108     60.02     59.71      0.02       201.75         202.72        99.52          1656
stress-ng: metrc: [2203] fp                 7533     60.00     59.83      0.01       125.54         125.89        99.73          1360
stress-ng: metrc: [2203] crypt              4350     60.05     59.86      0.02        72.45          72.64        99.73          1428
stress-ng: metrc: [2203] goto            5241093     60.00     59.84      0.00     87351.50       87579.27        99.74          1392
stress-ng: metrc: [2203] cache            639412     60.00     59.45      0.25     10656.68       10710.21        99.50          3416
stress-ng: metrc: [2203] bigheap          261588     60.09      3.12     56.61      4353.48        4379.71        99.40        326380
stress-ng: metrc: [2203] malloc          6205777     60.32     32.79     27.18    102879.17      103486.79        99.41        283600
stress-ng: metrc: [2203] memcpy             1301     60.00     59.85      0.00        21.68          21.74        99.75          1276
stress-ng: metrc: [2203] bsearch            1887     60.01     59.70      0.04        31.45          31.59        99.55          1580
stress-ng: metrc: [2203] hsearch           29060     60.00     59.66      0.02       484.31         486.94        99.46          1624
stress-ng: metrc: [2203] msg             8968742     60.01      4.84     54.89    149463.59      150157.42        99.54          1396
stress-ng: metrc: [2203] getrandom        249677     60.00      0.14     59.71      4161.28        4171.97        99.74          1384
stress-ng: metrc: [2203] hrtimers        2656423     60.01      4.02     55.80     44266.67       44406.90        99.68          1264
stress-ng: metrc: [2203] daemon            29237     60.00      0.16      1.20       487.28       21404.09         2.28          1204
stress-ng: metrc: [2203] fork              31772     60.00     27.39     30.94       529.52         544.73        97.21          1392
stress-ng: metrc: [2203] netdev          1744232     60.00     12.40     47.43     29070.51       29152.51        99.72          1200
stress-ng: metrc: [2203] rawpkt          2100536     60.05      2.38     57.39     34977.26       35142.23        99.53          1260
stress-ng: metrc: [2203] rawsock          882494     61.50      1.98     57.59     14349.37       14815.96        96.85          1332
stress-ng: metrc: [2203] rawudp           231961     60.00      3.39     54.57      3865.94        4002.01        96.60          1552
stress-ng: metrc: [2203] sock               5054     60.06      1.67     58.03        84.14          84.66        99.38          1600
stress-ng: metrc: [2203] sockfd           994916     60.01      3.96     54.98     16580.10       16880.91        98.22          1464
stress-ng: metrc: [2203] sockmany          48915     60.54      1.38     56.47       807.99         845.54        95.56          1720
stress-ng: metrc: [2203] udp              814769     60.00      1.54     57.07     13579.16       13901.49        97.68          1332
stress-ng: metrc: [2203] miscellaneous metrics:
stress-ng: metrc: [2203] matrix              3476.09 add matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix             15180.29 copy matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix              3236.29 div matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix              4604.17 frobenius matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix              5000.42 hadamard matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix             14254.85 identity matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix              5291.31 mean matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix              9949.52 mult matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix             10009.25 negate matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix                29.34 prod matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix              4187.66 sub matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix                30.17 square matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix              3727.09 trans matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] matrix             14713.93 zero matrix ops per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   993.80 Mfp-ops per sec, float64 add          (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   995.54 Mfp-ops per sec, float32 add          (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   936.41 Mfp-ops per sec, float add            (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   988.37 Mfp-ops per sec, double add           (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   993.70 Mfp-ops per sec, long double add      (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   248.80 Mfp-ops per sec, float64 multiply     (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   993.88 Mfp-ops per sec, float32 multiply     (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   935.93 Mfp-ops per sec, float multiply       (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   248.46 Mfp-ops per sec, double multiply      (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                   248.70 Mfp-ops per sec, long double multiply (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                    34.34 Mfp-ops per sec, float64 divide       (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                    66.43 Mfp-ops per sec, float32 divide       (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                    66.39 Mfp-ops per sec, float divide         (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                    34.35 Mfp-ops per sec, double divide        (harmonic mean of 1 instance)
stress-ng: metrc: [2203] fp                    34.33 Mfp-ops per sec, long double divide   (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt              20111.07 MD5 encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt                277.17 NT encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt              19780.17 SHA-1 encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt              20211.72 SHA-256 encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt                 27.36 SHA-512 encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt                 14.29 scrypt encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt              17953.48 SunMD5 encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] crypt              20164.39 yescrypt encrypts per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] goto                  89.45 million gotos per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] cache            7576762.85 cache ops per second (harmonic mean of 1 instance)
stress-ng: metrc: [2203] cache           26383201.82 shared cache reads per second (harmonic mean of 1 instance)
stress-ng: metrc: [2203] cache           30908027.72 shared cache writes per second (harmonic mean of 1 instance)
stress-ng: metrc: [2203] bigheap            23559.72 realloc calls per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] bsearch         31296018.62 bsearch comparisons per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] bsearch               15.00 bsearch comparisons per item (harmonic mean of 1 instance)
stress-ng: metrc: [2203] getrandom      272784006.70 getrandom bits per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] hrtimers           44272.67 hrtimer signals per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] rawpkt                 1.40 MB recv'd per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] rawsock                0.39 MB recv'd per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] rawudp                 0.12 MB recv'd per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] rawudp              3866.10 packets (32 bytes) received per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] sock               42999.43 messages sent per sec (harmonic mean of 1 instance)
stress-ng: metrc: [2203] sock             2740715.00 byte average out queue length (harmonic mean of 1 instance)
stress-ng: metrc: [2203] sock             3217445.85 byte average in queue length (geometric mean of 1 instance)
stress-ng: info:  [2203] skipped: 0
stress-ng: info:  [2203] passed: 24: cpu (1) matrix (1) fp (1) crypt (1) goto (1) cache (1) bigheap (1) malloc (1) memcpy (1) bsearch (1) hsearch (1) msg (1) getrandom (1) hrtimers (1) daemon (1) fork (1) netdev (1) rawpkt (1) rawsock (1) rawudp (1) sock (1) sockfd (1) sockmany (1) )
stress-ng: info:  [2203] failed: 0
stress-ng: info:  [2203] metrics untrustworthy: 0
stress-ng: info:  [2203] successful run completed in 24 mins, 2.88 secs
```

#### STM32MP257F-EV1

[Results (yaml format)](stress-ng-stm32mp257f-ev1.yml)

```
stress-ng: info:  [2718] setting to a 1 min, 0 secs run per stressor
stress-ng: info:  [2718] dispatching hogs: 2 cpu, 2 matrix, 2 fp,[  193.246367] spectre-v4 mitigation disabled by command-line option  2 crypt, 2 goto, 2 cache, 2 bigheap, 2 malloc, 2 memcpy, 2 bsearch, 2 hsearch, 2 msg, 2 getrandom, 2 hrtimers, 2 daemon, 2 fork, 2 netdev, 2p
stress-ng: info:  [2731] cache: cache flags used: prefetch fence
stress-ng: info:  [2731] cache: unavailable unused cache flags: clflush sfence clflushopt cldemote clwb
[  976.280658] hrtimer: interrupt took 10750 ns
stress-ng: metrc: [2718] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s CPU used per       RSS Max
stress-ng: metrc: [2718]                           (secs)    (secs)    (secs)   (real time) (usr+sys time) instance (%)          (KB)
stress-ng: metrc: [2718] cpu                6932     60.02    119.78      0.00       115.49          57.87        99.78          4344
stress-ng: metrc: [2718] matrix            39068     60.01    119.82      0.01       651.04         326.02        99.85          3740
stress-ng: metrc: [2718] fp                 2412     60.03    119.98      0.00        40.18          20.10        99.92          3576
stress-ng: metrc: [2718] crypt             17820     60.01    119.93      0.00       296.96         148.59        99.93          4344
stress-ng: metrc: [2718] goto           17397928     60.00    119.91      0.00    289965.15      145094.38        99.92          2296
stress-ng: metrc: [2718] cache           2181096     60.00     73.58      0.09     36350.39       29607.92        61.39          7428
stress-ng: metrc: [2718] bigheap         1242786     60.13      8.73    110.90     20668.60       10389.28        99.47       1530060
stress-ng: metrc: [2718] malloc         27665546     60.14     61.34     58.23    460046.58      231378.48        99.41        251112
stress-ng: metrc: [2718] memcpy             2938     60.08    120.03      0.02        48.90          24.47        99.91          3380
stress-ng: metrc: [2718] bsearch            6217     60.01    119.83      0.02       103.59          51.87        99.85          3544
stress-ng: metrc: [2718] hsearch           85813     60.00    119.63      0.00      1430.19         717.30        99.69          3892
stress-ng: metrc: [2718] msg            31433557     60.00     17.18    101.82    523853.82      264135.16        99.16          3440
stress-ng: metrc: [2718] getrandom        905232     60.00      0.67    119.16     15087.18        7554.29        99.86          2296
stress-ng: metrc: [2718] hrtimers        6102343     60.04      4.54     96.68    101642.40       60285.33        84.30          3440
stress-ng: metrc: [2718] daemon           161011     60.00      0.64      1.94      2683.51       62425.54         2.15          2296
stress-ng: metrc: [2718] fork             129643     60.00     61.33     56.22      2160.71        1102.96        97.95          3544
stress-ng: metrc: [2718] netdev          3664683     60.00     23.46     96.43     61077.95       30567.25        99.91          2296
stress-ng: metrc: [2718] rawpkt          5794964     60.10      7.47     90.58     96416.86       59101.34        81.57          3016
stress-ng: metrc: [2718] rawsock         6012015     61.50      3.24     76.23     97755.76       75647.33        64.61          3404
stress-ng: metrc: [2718] rawudp          1484589     60.00      2.37     58.89     24742.83       24232.88        51.05          3704
stress-ng: metrc: [2718] sock              20552     60.02      5.29     97.58       342.43         199.79        85.70          5408
stress-ng: metrc: [2718] sockfd          3496967     60.01     10.52    106.88     58277.88       29787.52        97.82          3576
stress-ng: metrc: [2718] sockmany         387469     60.08      1.63     70.31      6449.14        5385.56        59.87          3900
stress-ng: metrc: [2718] udp             3451324     60.00      2.32     86.55     57521.42       38833.29        74.06          2300
stress-ng: metrc: [2718] miscellaneous metrics:
stress-ng: metrc: [2718] matrix             23404.89 add matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             66353.95 copy matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             12647.06 div matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             17740.87 frobenius matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             25869.77 hadamard matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             22553.08 identity matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             19056.83 mean matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             35078.27 mult matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             35033.45 negate matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix                46.71 prod matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix             25139.17 sub matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix                47.65 square matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix              5754.42 trans matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] matrix            120714.03 zero matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                    15.76 Mfp-ops per sec, float128 add         (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1331.61 Mfp-ops per sec, float64 add          (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1331.76 Mfp-ops per sec, float32 add          (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                   479.27 Mfp-ops per sec, float16 add          (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1330.91 Mfp-ops per sec, float add            (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1331.93 Mfp-ops per sec, double add           (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                    15.78 Mfp-ops per sec, long double add      (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                     6.88 Mfp-ops per sec, float128 multiply    (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1331.04 Mfp-ops per sec, float64 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1331.34 Mfp-ops per sec, float32 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                   479.64 Mfp-ops per sec, float16 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1331.35 Mfp-ops per sec, float multiply       (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                  1332.15 Mfp-ops per sec, double multiply      (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                     6.88 Mfp-ops per sec, long double multiply (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                     5.25 Mfp-ops per sec, float128 divide      (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                    79.19 Mfp-ops per sec, float64 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                   150.45 Mfp-ops per sec, float32 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                   139.06 Mfp-ops per sec, float16 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                   150.45 Mfp-ops per sec, float divide         (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                    79.17 Mfp-ops per sec, double divide        (harmonic mean of 2 instances)
stress-ng: metrc: [2718] fp                     5.25 Mfp-ops per sec, long double divide   (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt              25294.59 MD5 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt                465.70 NT encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt              25260.33 SHA-1 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt              25345.15 SHA-256 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt                 33.22 SHA-512 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt                 46.70 scrypt encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt              24831.90 SunMD5 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] crypt              25286.33 yescrypt encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] goto                 148.46 million gotos per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] cache           18674022.41 cache ops per second (harmonic mean of 2 instances)
stress-ng: metrc: [2718] cache           40210301.72 shared cache reads per second (harmonic mean of 2 instances)
stress-ng: metrc: [2718] cache           37430960.80 shared cache writes per second (harmonic mean of 2 instances)
stress-ng: metrc: [2718] bigheap            72274.02 realloc calls per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] bsearch         51724584.93 bsearch comparisons per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] bsearch               15.00 bsearch comparisons per item (harmonic mean of 2 instances)
stress-ng: metrc: [2718] getrandom      494449223.57 getrandom bits per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] hrtimers           50823.55 hrtimer signals per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] rawpkt                 1.93 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] rawpkt           5794964.00 packets sent (total of 2 instances)
stress-ng: metrc: [2718] rawpkt          10878341.00 packets received (total of 2 instances)
stress-ng: metrc: [2718] rawsock                1.34 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] rawudp                 0.38 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] rawudp             12358.51 packets (32 bytes) received per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] sock               87483.86 messages sent per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2718] sock             2834389.48 byte average out queue length (harmonic mean of 2 instances)
stress-ng: metrc: [2718] sock             5722518.63 byte average in queue length (geometric mean of 2 instances)
stress-ng: info:  [2718] skipped: 0
stress-ng: info:  [2718] passed: 48: cpu (2) matrix (2) fp (2) crypt (2) goto (2) cache (2) bigheap (2) malloc (2) memcpy (2) bsearch (2) hse)
stress-ng: info:  [2718] failed: 0
stress-ng: info:  [2718] metrics untrustworthy: 0
stress-ng: info:  [2718] successful run completed in 24 mins, 2.38 secs
```

#### STM32MP257F-DK

[Results (yaml format)](stress-ng-stm32mp257f-dk.yml)

```
stress-ng: info:  [2930] setting to a 1 min run per stressor
stress-ng: info:  [2930] dispatching hogs: 2 cpu, 2 matrix, 2 fp, 2 crypt, 2 goto, 2 cache, 2 bigheap, 2 malloc, 2 memcpy, 2 bsearch, 2 hsearch, 2 msg, 2 getrandom, 2 hrtimers, 2 daemon, 2 fop
stress-ng: info:  [2941] cache: cache flags used: prefetch fence
stress-ng: info:  [2941] cache: unavailable unused cache flags: flush sfence clflushopt cldemote clwb
[ 4195.042468] hrtimer: interrupt took 10400 ns
stress-ng: metrc: [2930] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s CPU used per       RSS Max
stress-ng: metrc: [2930]                           (secs)    (secs)    (secs)   (real time) (usr+sys time) instance (%)          (KB)
stress-ng: metrc: [2930] cpu                7032     60.29    120.49      0.00       116.64          58.36        99.93          5464
stress-ng: metrc: [2930] matrix            36968     60.01    119.94      0.00       616.01         308.23        99.93          3496
stress-ng: metrc: [2930] fp                 1980     60.14    120.25      0.00        32.92          16.47        99.98          3368
stress-ng: metrc: [2930] crypt             18234     60.02    120.00      0.00       303.80         151.95        99.97          5420
stress-ng: metrc: [2930] goto           17437645     60.00    119.95      0.01    290627.07      145356.71        99.97          3368
stress-ng: metrc: [2930] cache           2295280     60.00     75.31      0.14     38253.65       30422.68        62.87          7640
stress-ng: metrc: [2930] bigheap         1096106     60.09      6.10    113.92     18240.00        9132.50        99.86       1522392
stress-ng: metrc: [2930] malloc         30309325     60.14     63.12     56.91    503990.30      252511.42        99.80        245396
stress-ng: metrc: [2930] memcpy             2636     60.01    119.97      0.00        43.93          21.97        99.96          3240
stress-ng: metrc: [2930] bsearch            6148     60.02    119.91      0.00       102.43          51.27        99.90          3624
stress-ng: metrc: [2930] hsearch           87367     60.00    119.91      0.00      1456.08         728.61        99.92          3752
stress-ng: metrc: [2930] msg            33618690     60.00     15.02    101.50    560270.42      288520.07        97.09          3368
stress-ng: metrc: [2930] getrandom        999560     60.00      0.56    119.40     16659.31        8332.34        99.97          3368
stress-ng: metrc: [2930] hrtimers        7837239     60.01      8.31    111.65    130607.97       65335.78        99.95          3240
stress-ng: metrc: [2930] daemon           129801     60.00      0.34      2.38      2163.34       47873.96         2.26          3240
stress-ng: metrc: [2930] fork             113069     60.00     58.67     60.66      1884.46         947.49        99.45          3368
stress-ng: metrc: [2930] netdev          4460041     60.00     24.55     95.41     74333.93       37178.88        99.97          3240
stress-ng: metrc: [2930] rawpkt          4284830     60.07      7.35    112.63     71328.94       35712.49        99.87          3496
stress-ng: metrc: [2930] rawsock         5389123     61.50      4.81    114.62     87627.35       45122.93        97.10          3368
stress-ng: metrc: [2930] rawudp          1360024     60.00      4.57    107.06     22665.46       12183.05        93.02          3624
stress-ng: metrc: [2930] sock              16856     60.01      5.09    114.74       280.89         140.66        99.84          5400
stress-ng: metrc: [2930] sockfd          3887709     60.00      9.61    108.13     64792.43       33017.95        98.12          3368
stress-ng: metrc: [2930] sockmany         341639     60.20      2.16    113.50      5675.51        2954.06        96.06          3752
stress-ng: metrc: [2930] udp             2788801     60.00      4.26    113.12     46478.39       23759.45        97.81          3368
stress-ng: metrc: [2930] miscellaneous metrics:
stress-ng: metrc: [2930] matrix             23660.89 add matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             61771.37 copy matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             12805.97 div matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             18338.96 frobenius matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             25769.10 hadamard matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             22288.74 identity matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             18904.21 mean matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             34783.81 mult matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             34851.91 negate matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix                44.35 prod matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix             25021.82 sub matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix                44.89 square matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix              5399.78 trans matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] matrix            120701.58 zero matrix ops per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                    16.10 Mfp-ops per sec, float128 add         (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1330.25 Mfp-ops per sec, float64 add          (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1332.12 Mfp-ops per sec, float32 add          (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                    12.87 Mfp-ops per sec, bf16 add             (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                   479.47 Mfp-ops per sec, float16 add          (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1330.85 Mfp-ops per sec, float add            (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1332.27 Mfp-ops per sec, double add           (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                    16.12 Mfp-ops per sec, long double add      (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                     6.90 Mfp-ops per sec, float128 multiply    (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1331.78 Mfp-ops per sec, float64 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1331.96 Mfp-ops per sec, float32 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                    17.10 Mfp-ops per sec, bf16 multiply        (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                   479.55 Mfp-ops per sec, float16 multiply     (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1331.34 Mfp-ops per sec, float multiply       (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                  1331.57 Mfp-ops per sec, double multiply      (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                     6.90 Mfp-ops per sec, long double multiply (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                     5.30 Mfp-ops per sec, float128 divide      (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                    79.59 Mfp-ops per sec, float64 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                   151.24 Mfp-ops per sec, float32 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                    16.54 Mfp-ops per sec, bf16 divide          (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                   139.87 Mfp-ops per sec, float16 divide       (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                   151.22 Mfp-ops per sec, float divide         (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                    79.60 Mfp-ops per sec, double divide        (harmonic mean of 2 instances)
stress-ng: metrc: [2930] fp                     5.32 Mfp-ops per sec, long double divide   (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt              25365.21 MD5 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt                466.76 NT encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt              25255.68 SHA-1 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt              25335.91 SHA-256 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt                 34.54 SHA-512 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt                 46.79 scrypt encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt              24837.08 SunMD5 encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] crypt              25320.26 yescrypt encrypts per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] goto                 148.80 million gotos per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] cache           19877996.51 cache ops per second (harmonic mean of 2 instances)
stress-ng: metrc: [2930] cache           45494229.02 shared cache reads per second (harmonic mean of 2 instances)
stress-ng: metrc: [2930] cache           37160494.29 shared cache writes per second (harmonic mean of 2 instances)
stress-ng: metrc: [2930] bigheap            71507.12 realloc calls per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] bsearch         51120616.77 bsearch comparisons per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] bsearch               15.00 bsearch comparisons per item (harmonic mean of 2 instances)
stress-ng: metrc: [2930] getrandom      545978272.90 getrandom bits per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] hrtimers           65317.43 hrtimer signals per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] rawpkt                 1.43 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] rawpkt           4284830.00 packets sent (total of 2 instances)
stress-ng: metrc: [2930] rawpkt          10642199.00 packets received (total of 2 instances)
stress-ng: metrc: [2930] rawsock                1.20 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] rawudp                 0.35 MB recv'd per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] rawudp             11334.14 packets (32 bytes) received per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] sock               71775.10 messages sent per sec (harmonic mean of 2 instances)
stress-ng: metrc: [2930] sock              323426.96 byte average out queue length (harmonic mean of 2 instances)
stress-ng: metrc: [2930] sock             1535166.41 byte average in queue length (geometric mean of 2 instances)
stress-ng: info:  [2930] skipped: 0
stress-ng: info:  [2930] passed: 48: cpu (2) matrix (2) fp (2) crypt (2) goto (2) cache (2) bigheap (2) malloc (2) memcpy (2) bsearch (2) hsearch (2) msg (2) getrandom (2) hrtimers (2) daemon)
stress-ng: info:  [2930] failed: 0
stress-ng: info:  [2930] metrics untrustworthy: 0
stress-ng: info:  [2930] successful run completed in 24 mins, 2.77 secs
```

### Iperf3

#### STM32MP157F-DK2

|Interface|Protocol|Bandwidth: RX, TX, Bidir (RX + TX)|
|---------|--------|----------------------------------|
|loopback|TCP|2.31 Gbits/sec, 2.31 Gbits/sec, 1.39 Gbits/sec + 1.41 Gbits/sec|
|loopback|UDP|1.71 Gbits/sec, 1.71 Gbits/sec, 871 Mbits/sec + 870 Mbits/sec|
|eth0|TCP|746 Mbits/sec, 940 Mbits/sec, 259 Mbits/sec + 722 Mbits/sec|
|wifi|TCP|52.1 Mbits/sec, 38.2 Mbits/sec, 50.8 Mbits/sec + 1.69 Mbits/sec|

#### STM32MP135F-DK

|Interface|Protocol|Bandwidth: RX, TX, Bidir (RX + TX)|
|---------|--------|----------------------------------|
|loopback|TCP|793 Mbits/sec, 793 Mbits/sec, 481 Mbits/sec + 611 Mbits/sec|
|loopback|UDP|794 Mbits/sec, 794 Mbits/sec, 333 Mbits/sec + 344 Mbits/sec|
|eth0|TCP|94.1 Mbits/sec, 94.2 Mbits/sec, 91.4 Mbits/sec + 91.8 Mbits/sec|
|eth1|TCP|94.2 Mbits/sec, 94.1 Mbits/sec, 91.4 Mbits/sec + 91.5 Mbits/sec|
|wifi|TCP|49.7 Mbits/sec, 36.3 Mbits/sec, 43.3 Mbits/sec + 6.33 Mbits/sec|

#### STM32MP257F-EV1

|Interface|Protocol|Bandwidth: RX, TX, Bidir (RX + TX)|
|---------|--------|----------------------------------|
|loopback|TCP|8.77 Gbits/sec, 8.77 Gbits/sec, 4.38 Gbits/sec + 4.40 Gbits/sec|
|loopback|UDP|4.40 Gbits/sec, 4.40 Gbits/sec, 4.09 Gbits/sec + 4.04 Gbits/sec|
|eth0|TCP|942 Mbits/sec, 942 Mbits/sec, 927 Mbits/sec + 939 Mbits/sec|
|eth1|TCP|942 Mbits/sec, 491 Mbits/sec, 927 Mbits/sec + 939 Mbits/sec|

#### STM32MP257F-DK

|Interface|Protocol|Bandwidth: RX, TX, Bidir (RX + TX)|
|---------|--------|----------------------------------|
|loopback|TCP|7.17 Gbits/sec, 7.17 Gbits/sec, 6.04 Gbits/sec + 5.96 Gbits/sec
|loopback|UDP|8.09 Gbits/sec, 7.58 Gbits/sec, 4.52 Gbits/sec + 5.46 Gbits/sec
|eth0|TCP|941 Mbits/sec, 941 Mbits/sec, 939 Mbits/sec + 925 Mbits/sec
|wifi|TCP|48.0 Mbits/sec, 45.4 Mbits/sec 34.9 Mbits/sec, 16.7 Mbits/sec
