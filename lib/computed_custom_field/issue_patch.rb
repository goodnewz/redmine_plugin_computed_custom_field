module ComputedCustomField
  module IssuePatch
    def read_only_attribute_names(user = nil)
      cf_ids = CustomField.where(is_computed: true).pluck(:id).map(&:to_s)
      attributes = super(user)
      (attributes + cf_ids).uniq
    end
  end
end
