# Intel Arc Pro B50 16GB

**PC HW**
```text
       _,met$$$$$gg.          root@test-pc.lan 
    ,g$$$$$$$$$$$$$$$P.       ---------------- 
  ,g$$P"     """Y$$.".        OS: Debian GNU/Linux forky/sid x86_64 
 ,$$P'              `$$$.     Host: B550M Pro4 
',$$P       ,ggs.     `$$b:   Kernel: 7.1.8+deb14-amd64 
`d$$'     ,$P"'   .    $$$    Uptime: 20 mins 
 $$P      d$'     ,    $$P    Packages: 3708 (dpkg) 
 $$:      $$.   -    ,d$$'    Shell: zsh 5.9.2 
 $$;      Y$b._   _,d$P'      Resolution: 1920x1080 
 Y$$.    `.`"Y$$$$P"'         Terminal: /dev/pts/4 
 `$$b      "-.__              CPU: AMD Ryzen 7 3800XT (16) @ 4.726GHz 
  `Y$$                        GPU: Intel Battlemage G21 [Arc Pro B50] 
   `Y$$.                      Memory: 1726MiB / 32020MiB 
     `$$b.
       `Y$$b.                                         
          `"Y$b._                                     
              `"""
```

## 2026-08-16

Debian GNU/Linux forky/sid
Kernel: 7.1.8+deb14-amd64
mesa-vulkan-drivers: 26.1.5-1
llama.cpp build: ece963f41 (10450)

### llama.cpp-Vulkan
| model                          |       size |     params | backend    | ngl | type_k | type_v |     sm |  fa | dev          |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | -----: | -----: | -----: | --: | ------------ | --------------: | -------------------: |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | Vulkan     |  99 |   q8_0 |   q8_0 |   none |   1 | Vulkan0      |           pp128 |        480.14 ± 7.37 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | Vulkan     |  99 |   q8_0 |   q8_0 |   none |   1 | Vulkan0      |           pp512 |        836.42 ± 6.13 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | Vulkan     |  99 |   q8_0 |   q8_0 |   none |   1 | Vulkan0      |          pp2048 |        697.73 ± 2.08 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | Vulkan     |  99 |   q8_0 |   q8_0 |   none |   1 | Vulkan0      |           tg128 |         19.90 ± 0.02 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | Vulkan     |  99 |   q8_0 |   q8_0 |   none |   1 | Vulkan0      |           tg512 |         19.51 ± 0.05 |


### llama.cpp-SYCL
| model                          |       size |     params | backend    | ngl | type_k | type_v |     sm |  fa | dev          |            test |                  t/s |
| ------------------------------ | ---------: | ---------: | ---------- | --: | -----: | -----: | -----: | --: | ------------ | --------------: | -------------------: |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | SYCL       |  99 |   q8_0 |   q8_0 |   none |   1 | SYCL0        |           pp128 |        272.79 ± 7.03 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | SYCL       |  99 |   q8_0 |   q8_0 |   none |   1 | SYCL0        |           pp512 |       640.10 ± 11.80 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | SYCL       |  99 |   q8_0 |   q8_0 |   none |   1 | SYCL0        |          pp2048 |        630.04 ± 4.82 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | SYCL       |  99 |   q8_0 |   q8_0 |   none |   1 | SYCL0        |           tg128 |         21.88 ± 0.15 |
| gpt-oss 20B MXFP4 MoE          |  11.27 GiB |    20.91 B | SYCL       |  99 |   q8_0 |   q8_0 |   none |   1 | SYCL0        |           tg512 |         21.35 ± 0.12 |
