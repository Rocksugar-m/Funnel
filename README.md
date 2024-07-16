# Funnel

# Getting Started

## Requirements

- Software
  - CUDA
  - Python >= 3.7
  - PyTorch <= 1.7.0
  - Transformers 4.7.0 (Make sure your terminal can access Huggingface)

- Hardware
  - Vitis 2022.2
  - Vivado 2022.2

## Installation

  1. Clone this repository
  2. Download the CLOTH dataset from [here](https://www.cs.cmu.edu/~glai1/data/cloth/) to `data/cloth` (Note: There is a problem with one piece of data in CLOTH). GELU and SQuAD v1.1 don't need to be downloaded manually.
  3. Create a virtual environment (recommendation: conda) with a Python version of at least 3.7.
  4. Install dependent Python packages: `pip install -r requirements.txt`
  5. Set relevant environment variables
     
     a. `export PROJ_ROOT=$PWD`
     
     b. `export WANDB_DISABLED=true` to disable wandb logging (optional)

# Experiment Workflow

## Software experiments

1. Evaluate Funnel Accuracy
   
   a. Train a origion model by scripts or download checkpoints from [here](https://drive.google.com/drive/folders/1sBln_hBajbF0NxKnfLxcnOFGlymQfJ-a?usp=sharing) (These checkpoints are all downloaded from [Huggingface](https://huggingface.co/models)).
   You should download and place them in `output` by dataset name like location mode in Google Driver.

   b. Evaluate the fine-tuned model by scripts.
