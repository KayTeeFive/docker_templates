#  AMD Radeon Instinct MI25 (Pro WX 9100) / Vulkan API / TENSOR split mode

> llama.cpp, build: 86b94708f (9843)

## gpt-oss-20b-mxfp4.gguf
| MODEL   | Processing type | SM: None, t/s | SM: layer, t/s | SM: tensor, t/s | Split penalty: layer/tensor | SM tensor boost (cmp to layer) |   
|---------|-----------------|---------------|----------------|-----------------|-----------------------------|--------------------------------|
| GPT-OSS | pp128           | 400           | 383            | 580             | -5%  / +45%                 | +51%                           |
| GPT-OSS | pp512           | 717           | 709            | 842             | -1%  / +17%                 | +18%                           |
| GPT-OSS | pp2048          | 696           | 999            | 810             | +43% / +16%                 | -19%                           |
| GPT-OSS | tg128           | 83            | 30             | 74              | -64% / -10%                 | +146%                          |
| GPT-OSS | tg512           | 82            | 30             | 74              | -64% / -10%                 | +146%                          |

## Qwen3-Coder-30B-A3B-Instruct-Q6_K.gguf
| MODEL                 | Processing type | SM: None, t/s | SM: layer, t/s | SM: tensor, t/s | SM tensor boost (cmp to layer) |   
|-----------------------|-----------------|---------------|----------------|-----------------|--------------------------------|
| qwen3moe 30B.A3B Q6_K | pp128           | n/a           | 248            | 301             | +21%                           |
| qwen3moe 30B.A3B Q6_K | pp512           | n/a           | 494            | 337             | -32%                           |
| qwen3moe 30B.A3B Q6_K | pp2048          | n/a           | 677            | 355             | -47%                           |
| qwen3moe 30B.A3B Q6_K | tg128           | n/a           | 29             | 39              | +34%                           |
| qwen3moe 30B.A3B Q6_K | tg512           | n/a           | 29             | 39              | +34%                           |

## Qwen3-Coder-30B-A3B-Instruct-Q4_K_M.gguf
| MODEL                          | Processing type | SM: None, t/s | SM: layer, t/s | SM: tensor, t/s | SM tensor boost (cmp to layer) |   
|--------------------------------|-----------------|---------------|----------------|-----------------|--------------------------------|
| qwen3moe 30B.A3B Q4_K - Medium | pp128           | n/a           | 271            | 314             | +15%                           |
| qwen3moe 30B.A3B Q4_K - Medium | pp512           | n/a           | 538            | 379             | -30%                           |
| qwen3moe 30B.A3B Q4_K - Medium | pp2048          | n/a           | 728            | 396             | -49%                           |
| qwen3moe 30B.A3B Q4_K - Medium | tg128           | n/a           | 32             | 40              | +25%                           |
| qwen3moe 30B.A3B Q4_K - Medium | tg512           | n/a           | 32             | 40              | +25%                           |

## gemma-4-31B-it-Q6_K.gguf
| MODEL           | Processing type | SM: None, t/s | SM: layer, t/s | SM: tensor, t/s | SM tensor boost (cmp to layer) |   
|-----------------|-----------------|---------------|----------------|-----------------|--------------------------------|
| gemma4 31B Q6_K | pp128           | n/a           | 86             | 123             | +43%                           |
| gemma4 31B Q6_K | pp512           | n/a           | 94             | 134             | +42%                           |
| gemma4 31B Q6_K | pp2048          | n/a           | 138            | 128             | -8%                            |
| gemma4 31B Q6_K | tg128           | n/a           | 8              | 14              | +75%                           |
| gemma4 31B Q6_K | tg512           | n/a           | 8              | 14              | +75%                           |

## Qwen3.6-27B-Q6_K.gguf
| MODEL           | Processing type | SM: None, t/s | SM: layer, t/s | SM: tensor, t/s | SM tensor boost (cmp to layer) |
|-----------------|-----------------|---------------|----------------|-----------------|--------------------------------|
| qwen35 27B Q6_K | pp128           | n/a           | 86             | 127             | +47%                           |
| qwen35 27B Q6_K | pp512           | n/a           | 103            | 148             | +43%                           |
| qwen35 27B Q6_K | pp2048          | n/a           | 158            | 144             | -9%                            |
| qwen35 27B Q6_K | tg128           | n/a           | 9              | 16              | +77%                           |
| qwen35 27B Q6_K | tg512           | n/a           | 9              | 16              | +77%                           |


## Qwen3.6-27B-Q8_0.gguf
| MODEL           | Processing type | SM: None, t/s | SM: layer, t/s | SM: tensor, t/s | SM tensor boost (cmp to layer) |
|-----------------|-----------------|---------------|----------------|-----------------|--------------------------------|
| qwen35 27B Q8_0 | pp128           | n/a           | 104            | 138             | +32%                           |
| qwen35 27B Q8_0 | pp512           | n/a           | 124            | 163             | +31%                           |
| qwen35 27B Q8_0 | pp2048          | n/a           | 188            | 160             | -15%                           |
| qwen35 27B Q8_0 | tg128           | n/a           | 8              | 15              | +87%                           |
| qwen35 27B Q8_0 | tg512           | n/a           | 8              | 15              | +87%                           |
