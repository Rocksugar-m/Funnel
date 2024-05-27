task_name=${1:-"cola"}
model_name=${2:-"bert-base-uncased"}
output_dir=${3:-"$PROJ_ROOT/outputs/glue"}

python run_glue.py \
  --model_name_or_path bert-base-uncased \
  --task_name $task_name \
  --do_train \
  --do_eval \
  --max_seq_length 512 \
  --per_device_train_batch_size 8 \
  --learning_rate 2e-5 \
  --num_train_epochs 3 \
  --output_dir $output_dir/$(basename $model_name)_$task_name\
  --report_to tensorboard
