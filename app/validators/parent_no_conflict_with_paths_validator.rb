class ParentNoConflictWithPathsValidator < ActiveModel::Validator
  def validate(record)
    if record.parent && record.relative_path.present?
      if record.parent.relative_path != record.relative_path.dirname
        record.errors.add :relative_path, "('#{record.relative_path}') is supposed to be covered by '#{record.parent.relative_path}'"
      end
    end
  end
end
