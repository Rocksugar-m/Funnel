import parser
import time
import math
import argparse
from typing import Optional, Tuple
from functools import partial

import numpy as np
import torch
import torch.nn as nn

class BertSelfAttention(nn.Module):
    def __init__(self, hidden_size, num_attention_heads, attention_probs_dropout_prob=0.1):
        super().__init__()
        if hidden_size % num_attention_heads != 0:
            raise ValueError(
                f"The hidden size ({hidden_size}) is not a multiple of the number of attention "
                f"heads ({num_attention_heads})"
            )

        self.num_attention_heads = num_attention_heads
        self.attention_head_size = int(hidden_size / num_attention_heads)
        self.all_head_size = self.num_attention_heads * self.attention_head_size

        self.query = nn.Linear(hidden_size, self.all_head_size)
        self.key = nn.Linear(hidden_size, self.all_head_size)
        self.value = nn.Linear(hidden_size, self.all_head_size)

        self.dropout = nn.Dropout(attention_probs_dropout_prob)

    def transpose_for_scores(self, x):
        new_x_shape = x.size()[:-1] + (self.num_attention_heads, self.attention_head_size)
        x = x.view(*new_x_shape)
        return x.permute(0, 2, 1, 3)

    def forward(
        self,
        hidden_states,
        attention_mask=None,
        head_mask=None,
        encoder_hidden_states=None,
        encoder_attention_mask=None,
        past_key_value=None,
        output_attentions=False,
    ):
        mixed_query_layer = self.query(hidden_states)

        # If this is instantiated as a cross-attention module, the keys
        # and values come from an encoder; the attention mask needs to be
        # such that the encoder's padding tokens are not attended to.
        is_cross_attention = encoder_hidden_states is not None

        if is_cross_attention and past_key_value is not None:
            # reuse k,v, cross_attentions
            key_layer = past_key_value[0]
            value_layer = past_key_value[1]
            attention_mask = encoder_attention_mask
        elif is_cross_attention:
            key_layer = self.transpose_for_scores(self.key(encoder_hidden_states))
            value_layer = self.transpose_for_scores(self.value(encoder_hidden_states))
            attention_mask = encoder_attention_mask
        elif past_key_value is not None:
            key_layer = self.transpose_for_scores(self.key(hidden_states))
            value_layer = self.transpose_for_scores(self.value(hidden_states))
            key_layer = torch.cat([past_key_value[0], key_layer], dim=2)
            value_layer = torch.cat([past_key_value[1], value_layer], dim=2)
        else:
            key_layer = self.transpose_for_scores(self.key(hidden_states))
            value_layer = self.transpose_for_scores(self.value(hidden_states))

        query_layer = self.transpose_for_scores(mixed_query_layer)

        # Take the dot product between "query" and "key" to get the raw attention scores.
        attention_scores = torch.matmul(query_layer, key_layer.transpose(-1, -2))

        attention_scores = attention_scores / math.sqrt(self.attention_head_size)
        if attention_mask is not None:
            # Apply the attention mask is (precomputed for all layers in BertModel forward() function)
            attention_scores = attention_scores + attention_mask

        # Normalize the attention scores to probabilities.
        attention_probs = nn.Softmax(dim=-1)(attention_scores)

        # This is actually dropping out entire tokens to attend to, which might
        # seem a bit unusual, but is taken from the original Transformer paper.
        attention_probs = self.dropout(attention_probs)

        # Mask heads if we want to
        if head_mask is not None:
            attention_probs = attention_probs * head_mask

        context_layer = torch.matmul(attention_probs, value_layer)

        context_layer = context_layer.permute(0, 2, 1, 3).contiguous()
        new_context_layer_shape = context_layer.size()[:-2] + (self.all_head_size,)
        context_layer = context_layer.view(*new_context_layer_shape)

        outputs = (context_layer, attention_probs) if output_attentions else (context_layer,)

        return outputs
    

def build_bert_model_and_input(batch_size=1, seq_len=512, use_large=False, cuda=True, fp16=False):
    if not use_large:
        hidden_size, num_heads = 768, 12
    else:
        hidden_size, num_heads = 1024, 16

    model = BertSelfAttention(hidden_size, num_heads).eval()
    hidden_state = torch.randn(batch_size, seq_len, hidden_size)

    if fp16:
        model = model.half()
        hidden_state = hidden_state.half()

    attn_mask = torch.zeros(batch_size, 1, 1, seq_len).long()
    
    if cuda:
        model = model.cuda()
        hidden_state = hidden_state.cuda()
        attn_mask = attn_mask.cuda()
    
    return model, (hidden_state, attn_mask)


def bench_dense_attn_cpu(run_func, number=10, repeats=10):
    run_func()
    bench_res = []
    
    for i in range(repeats):
        time_record = []
        
        for j in range(number):
            tic = time.time()
            run_func()
            toc = time.time()
            time_record.append(1000 * (toc - tic))

        bench_res.append(np.mean(time_record))
    
    return bench_res


def bench_dense_attn_gpu(run_func, number=100, repeats=10):
    run_func()
    bench_res = []

    for i in range(repeats):
        time_record = []
        
        for j in range(number):
            torch.cuda.synchronize()
            
            tic = torch.cuda.Event(enable_timing=True)
            toc = torch.cuda.Event(enable_timing=True)
            
            tic.record()
            
            run_func()

            toc.record()
            torch.cuda.synchronize()

            elapsed = tic.elapsed_time(toc)
            time_record.append(elapsed)
        
        avg_time = np.mean(time_record)
        bench_res.append(avg_time)

    return bench_res


def run_dense_attn(dense_attn, inputs):
    with torch.no_grad():
        output = dense_attn(*inputs)


def run_bert_benchmark(batch_size=1, seq_len=512, use_large=False, cuda=True, fp16=False):
    dense_attn, inputs = build_bert_model_and_input(batch_size=batch_size, seq_len=seq_len, use_large=use_large, cuda=cuda, fp16=fp16)
    run_func = partial(run_dense_attn, dense_attn=dense_attn, inputs=inputs)
    if cuda:
        bench_res = bench_dense_attn_gpu(run_func)
    else:
        bench_res = bench_dense_attn_cpu(run_func)
    print(f"Benchmark result ({'bert-large' if use_large else 'bert-base'}, {'GPU' if cuda else 'CPU'}, {'TC' if fp16 else 'NTC'}, {seq_len})")
    print(bench_res)
    print(f"mean: {np.mean(bench_res)}, std: {np.std(bench_res)}")
    return np.mean(bench_res)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch_size", default=1, type=int)
    parser.add_argument("--seq_len", default=512, type=int, help="The maximum total input sequence length")
    parser.add_argument("--cuda", default=False, action='store_true', help="Use GPU or not")
    parser.add_argument("--fp16", default=False, action='store_true', help="Enable half precision inference")
    args = parser.parse_args()

    avg_lat = run_bert_benchmark(batch_size=args.batch_size, seq_len=args.seq_len, use_large=False, cuda=args.cuda, fp16=args.fp16)


if __name__ == '__main__':
    main()