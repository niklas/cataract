ActiveSupport.on_load(:active_model_serializers) do
  # for emu
  ActiveModel::ArraySerializer.root = false
end
