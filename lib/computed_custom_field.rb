module ComputedCustomField
  def self.patch_models
    CustomField.include(CustomFieldPatch) unless CustomField < CustomFieldPatch
    CustomFieldsHelper.include(CustomFieldsHelperPatch) unless CustomFieldsHelper < CustomFieldsHelperPatch
    Issue.prepend(IssuePatch) unless Issue < IssuePatch

    models = [
      Enumeration, Group, Issue, Project,
      TimeEntry, User, Version
    ]
    models.each do |model|
      if model.included_modules
              .exclude?(ComputedCustomField::ModelPatch)
        model.send :include, ComputedCustomField::ModelPatch
      end
    end
  end
end
