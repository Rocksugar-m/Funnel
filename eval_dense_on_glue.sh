task_name=${1:-"stsb"}
model_name=${2:-"bert-base-uncased"}
output_dir=${3:-"$PROJ_ROOT/outputs/glue"}

python run_glue.py \
  --model_name_or_path $output_dir/$(basename $model_name)_$task_name \
  --task_name $task_name \
  --do_eval \
  --max_seq_length 512 \
  --eval_checkpoint $output_dir/$(basename $model_name)_$task_name/pytorch_model.bin \
  --output_dir $output_dir/$(basename $model_name)_$task_name \
  --report_to tensorboard
