task_name=${1:-"cola"}
model_name=${2:-"bert-base-uncased"}
output_dir=${3:-"$PROJ_ROOT/outputs/glue"}

python run_glue.py \
  --is_sparse \
  --model_name_or_path $output_dir/$(basename $model_name)_$task_name \
  --task_name $task_name \
  --do_eval \
  --per_device_eval_batch_size 1 \
  --max_seq_length 128 \
  --eval_checkpoint $output_dir/$(basename $model_name)_$task_name/pytorch_model.bin \
  --output_dir $output_dir/$(basename $model_name)_$task_name \
  --report_to tensorboard
